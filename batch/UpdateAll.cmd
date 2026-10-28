@echo off
setlocal EnableDelayedExpansion
REM ---------------------------------------------------------------------------------------------
REM UpdateAll.cmd: updates the caches of NetworkModel_PBL with GeoDmsRun, in the order in which they depend on
REM each other. Each step is a separate GeoDmsRun call, so that memory is freed between the steps, and the script
REM stops at an error. Logs in batch\log\UpdateAll_<step>.log.
REM
REM   UpdateAll.cmd                 all sections (sources, cars, chains, legs, output); expect more than a night
REM   UpdateAll.cmd all -nosources  everything except the named sections: -nosources, -nocars, -nochains, -nolegs, -nooutput
REM   UpdateAll.cmd sources         the OSM network and GTFS caches (only needed for a new edition; about 15 min). The car on
REM                                 the TomTom network reads the four TomTom caches as source data from
REM                                 NetworkModel_PrivDir\TomTom\<edition>; UpdateAll does not make them.
REM   UpdateAll.cmd cars [moment..] the caches of the direct car trip per departure moment
REM                                 (PublicTransport_Prep/Direct/CarPerMoment/<moment>/Write_Car); without moments the
REM                                 moments the model reads (MakeUnlinkedData/Step4_DirectCar/Moments); with moments, for
REM                                 example MorningRush NoonRush LateEveningRush and Freeflow (TomTom) or MaxSpeed (OSM);
REM                                 about 40 min per moment with a scalar search, longer with ParetoLegs_Car
REM   UpdateAll.cmd chains          the public transport chain cache per stop block (WriteChainBlocks.ps1; with the
REM                                 environment variable CHAINCACHE_SINGLE the single cache of
REM                                 PublicTransport_Prep/ChainGeneration_Single/Write), after the pre-check of the stop
REM                                 blocks and the price coverage; takes hours and much memory
REM   UpdateAll.cmd legs            the caches of the pre- and post-transport connections: the base sets without a cache,
REM                                 walking and cycling to and from every stop (PublicTransport_Prep/Write_PrePostTransport);
REM                                 writes only with ModelParameters/Advanced/PrePostTransportDecoupled (on by default)
REM   UpdateAll.cmd output          the public transport output: a file per origin block and departure moment in
REM                                 %LocalDataProjDir%\Output\<Analysis_date>_<OutputLabel><_component>[_fb]\PerBlock
REM                                 (_fb: a component on the cycling network with CyclingNetwork 'Fietsersbond')
REM                                 (ConfigurationPerBlock/Generate_Output), with the chain cache of the departure moments
REM                                 in PT_DepartureHours/Minutes. The step first writes the missing pre- and post-transport
REM                                 caches, as legs does, and empties that folder (#118), removing only
REM                                 the files of the model: tt_*.csv, tt_*.parquet and tt_*.xml, also the merged ones,
REM                                 signature.txt/.xml, the counts od_tellingen.csv and unieke_od_tellingen.csv (with .xml)
REM                                 and Tellingen\tellingen_*.*. With ModelParameters/OutputFormat 'parquet' the output is
REM                                 parquet instead of csv; the counts per block go to Tellingen (tellingen_*.csv).
REM                                 The step runs in portions of blocks (WriteOutputBlocks.ps1, a GeoDmsRun per portion,
REM                                 then the counts with OdTellingen.py); blocks per portion per component in
REM                                 ModelParameters/Advanced/Components/BlocksPerPortion, or set with OUTPUT_BATCHSIZE;
REM                                 with OUTPUT_SINGLE in one request.
REM A run calculates one component (ModelParameters/Component, #117): cars skips the car caches when the component has
REM no direct car trip (everything except Car), chains skips the chain cache when public transport is not part of it
REM (WW, CC, Car, MergeOutput), and with MergeOutput, output merges the output of the Components in MergeComponents.
REM Run the output steps of the components one after the other, not at the same time: each needs up to about 100 GB of
REM memory, and two at once make the machine page.
REM ---------------------------------------------------------------------------------------------
REM Engine. The model asks for the pareto epsilon and the bool criteria of pareto_optimal_eps, which older versions of
REM GeoDMS do not know; GEODMS_VERSION is the version it was tested with. GeoDmsRun.exe comes from, in this order:
REM the environment variable GEODMS_EXE (another engine, for example a test build); the local build in
REM C:\dev\GeoDMS_2026; the installed GEODMS_VERSION, flavor m or c, in the folder that the installer writes to the
REM registry (by default C:\Program Files\ObjectVision\GeoDms<version>.<flavor>).
set GEODMS_VERSION=20.26.0
set "EXE="
if defined GEODMS_EXE set "EXE=%GEODMS_EXE%"
if not defined EXE if exist "C:\dev\GeoDMS_2026\bin\Release\x64\GeoDmsRun.exe" set "EXE=C:\dev\GeoDMS_2026\bin\Release\x64\GeoDmsRun.exe"
if not defined EXE for %%F in (m c) do if not defined EXE (
  for /f "tokens=2,*" %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\GeoDms%GEODMS_VERSION%.%%F" /v InstallLocation /reg:64 2^>nul ^| findstr /i InstallLocation') do if exist "%%B\GeoDmsRun.exe" set "EXE=%%B\GeoDmsRun.exe"
  if not defined EXE if exist "%ProgramW6432%\ObjectVision\GeoDms%GEODMS_VERSION%.%%F\GeoDmsRun.exe" set "EXE=%ProgramW6432%\ObjectVision\GeoDms%GEODMS_VERSION%.%%F\GeoDmsRun.exe"
)
if not defined EXE (
  echo ABORT: no GeoDmsRun.exe found. Install GeoDMS %GEODMS_VERSION%, or set GEODMS_EXE to the full path of GeoDmsRun.exe.
  exit /b 1
)
REM The full path name without "..": GeoDMS derives %LocalDataProjDir% from the name of the folder above cfg, and
REM with batch\..\cfg\main.dms that name is "..", which puts the caches in C:\LocalData\..\IntermediateResults, that is C:\.
for %%I in ("%~dp0..\cfg\main.dms") do set CFG=%%~fI
REM Store the batch folder for the argument loop: after shift, %~dp0 no longer points to this folder.
set "BATCHDIR=%~dp0"
set LOGDIR=%~dp0log
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set PREP=/NetworkSetup/PublicTransport_Prep

set SECTION=%~1
if "%SECTION%"=="" set SECTION=all
REM The arguments after the section: -no<section> skips a section, the others are moments for cars.
REM (shift leaves %* unchanged, so the script collects them itself.)
set MOMENTS=
set SKIP_SOURCES=0
set SKIP_CARS=0
set SKIP_CHAINS=0
set SKIP_LEGS=0
set SKIP_OUTPUT=0
:args
shift
if "%~1"=="" goto argsdone
if /I "%~1"=="-nosources" (set SKIP_SOURCES=1) else if /I "%~1"=="-nocars" (set SKIP_CARS=1) else if /I "%~1"=="-nochains" (set SKIP_CHAINS=1) else if /I "%~1"=="-nolegs" (set SKIP_LEGS=1) else if /I "%~1"=="-nooutput" (set SKIP_OUTPUT=1) else set MOMENTS=!MOMENTS! %~1
goto args
:argsdone

echo UpdateAll %SECTION%%MOMENTS% started %DATE% %TIME%
echo engine: %EXE%

if /I "%SECTION%"=="all"     goto sources
if /I "%SECTION%"=="sources" goto sources
if /I "%SECTION%"=="cars"    goto cars
if /I "%SECTION%"=="chains"  goto chains
if /I "%SECTION%"=="legs"    goto legs
if /I "%SECTION%"=="output"  goto output
echo Unknown section "%SECTION%": choose all, sources, cars, chains, legs or output.
exit /b 1

:sources
if "%SKIP_SOURCES%"=="1" goto sources_done
echo === sources: OSM network cache ===
call :run osm_network /SourceData/Infrastructure/OSM/Make_Final_Network
if not "!RC!"=="0" goto failed
echo === sources: GTFS cache of the feed GTFS_file_date ===
call :run gtfs /SourceData/Infrastructure/GTFS/LoadFeeds/Write
if not "!RC!"=="0" goto failed
:sources_done
if /I not "%SECTION%"=="all" goto done

:cars
if "%SKIP_CARS%"=="1" goto cars_done
REM Without a direct car trip (AllowDirectCar FALSE: every component except Car, #117) there are no car caches.
call :run cars_check /ModelParameters/Impl/AllowDirectCar
if not "!RC!"=="0" goto failed
findstr /R "^Minimum.0" "%LOGDIR%\UpdateAll_cars_check.txt" >nul
if not errorlevel 1 (
  echo === direct car trip: AllowDirectCar is FALSE for this component, no car caches ===
  goto cars_done
)
if "%MOMENTS%"=="" (
  call :run car_moments /MakeUnlinkedData/Step4_DirectCar/Moments
  if not "!RC!"=="0" goto failed
  set /p MOMENTS=<"%LOGDIR%\car_moments.txt"
)
for %%M in (%MOMENTS%) do (
  echo === direct car trip: cache for %%M ===
  call :run car_%%M %PREP%/Direct/CarPerMoment/%%M/Write_Car
  if not "!RC!"=="0" goto failed
)
:cars_done
if /I not "%SECTION%"=="all" goto done

:chains
if "%SKIP_CHAINS%"=="1" goto chains_done
REM Without public transport (ModelParameters/Impl/WithPT FALSE: the direct trips WW, CC and Car, and MergeOutput, #117) there is no chain cache.
call :run chains_check /ModelParameters/Impl/WithPT
if not "!RC!"=="0" goto failed
findstr /R "^Minimum.0" "%LOGDIR%\UpdateAll_chains_check.txt" >nul
if not errorlevel 1 (
  echo === chains: public transport is not part of this component, no chain cache ===
  goto chains_done
)
echo === chains: pre-check of the stop blocks and the price coverage ===
call :run chains_precheck /ChecksBeforeRunning/PT_CheckBlocks /SourceData/Infrastructure/OVprijzen/PriceCoverage/Table_OK_DOVA
if not "!RC!"=="0" goto failed
findstr /R "^Minimum.1" "%LOGDIR%\UpdateAll_chains_precheck.txt" >nul
if errorlevel 1 (
  echo ABORT: the price coverage is not OK, see %LOGDIR%\UpdateAll_chains_precheck.txt
  goto failed
)
if defined CHAINCACHE_SINGLE goto chains_single
echo === chains: the stop blocks without a cache, in portions (WriteChainBlocks.ps1) ===
set STEP=chains
powershell -NoProfile -ExecutionPolicy Bypass -File "%BATCHDIR%WriteChainBlocks.ps1" -Exe "%EXE%" -Cfg "%CFG%" -LogDir "%LOGDIR%"
set RC=!ERRORLEVEL!
if not "!RC!"=="0" goto failed
goto chains_done
:chains_single
echo === chains: ChainGeneration_Single/Write, one cache for all blocks (CHAINCACHE_SINGLE; also set PT_Chains_PerBlock to FALSE) ===
call :run chains %PREP%/ChainGeneration_Single/Write
if not "!RC!"=="0" goto failed
:chains_done
if /I not "%SECTION%"=="all" goto done

:legs
if "%SKIP_LEGS%"=="1" goto legs_done
call :legs_write
if not "!RC!"=="0" goto failed
:legs_done
if /I not "%SECTION%"=="all" goto done

:output
if "%SKIP_OUTPUT%"=="1" goto done
REM Pause before the output step: as long as batch\pause_before_output.flag exists, the output step waits without a
REM calculation process, for example to free the machine for performance tests; removing the flag lets it start.
set "PAUSEFLAG=%BATCHDIR%pause_before_output.flag"
if not exist "%PAUSEFLAG%" goto output_go
echo %DATE% %TIME% pause before the output step: waiting until %PAUSEFLAG% is gone
:output_wait
ping -n 61 127.0.0.1 >nul
if exist "%PAUSEFLAG%" goto output_wait
echo %DATE% %TIME% pause over, the output step starts
:output_go
REM Every portion reads the pre- and post-transport connections from their caches (ModelParameters/Advanced/PrePostTransportDecoupled),
REM so the base sets without a cache are written first, once; with section all the legs section has done that already.
if /I not "%SECTION%"=="all" if not "%SKIP_LEGS%"=="1" (
  call :legs_write
  if not "!RC!"=="0" goto failed
)
REM Empty the output folder (NetworkModel_PBL#118): the file names carry only the moment and the block, and the parameters
REM are in signature.txt in the folder, so without emptying a run after a code change would put its blocks next to those
REM of the previous run. The model gives the folder (NetworkSetup/GenerateOutput/OutputDir_ForBatch, written to
REM batch\log\output_dir.txt); only the files the model writes there are removed, and only if the folder lies under a
REM folder Output. Output_Sig/PathGate fails beforehand if the longest output path is too long.
call :run output_dir /NetworkSetup/GenerateOutput/OutputDir_ForBatch /NetworkSetup/GenerateOutput/Output_Sig/PathGate
if not "!RC!"=="0" goto failed
set OUTDIR=
set /p OUTDIR=<"%LOGDIR%\output_dir.txt"
if not defined OUTDIR (
  echo ABORT: no output folder in %LOGDIR%\output_dir.txt
  set STEP=output_dir
  goto failed
)
REM Does the path contain \Output\, or \Output_ of an OD pair (Output_<O>_<D>, #129)? Replacing it by nothing then makes
REM the string shorter; cmd replaces case-insensitively.
set OUTOK=
if not "!OUTDIR:\Output\=!"=="!OUTDIR!" set OUTOK=1
if not "!OUTDIR:\Output_=!"=="!OUTDIR!" set OUTOK=1
if not defined OUTOK (
  echo ABORT: the output folder !OUTDIR! is not under a folder Output or Output_^<O^>_^<D^>
  set STEP=output_dir
  goto failed
)
if exist "!OUTDIR!\" (
  echo %DATE% %TIME% emptying the output folder: !OUTDIR!
  del /q "!OUTDIR!\PerBlock\tt_*.csv" "!OUTDIR!\PerBlock\tt_*.xml" "!OUTDIR!\Mediaan\tt_*.csv" "!OUTDIR!\Mediaan\tt_*.xml" "!OUTDIR!\tt_*.csv" "!OUTDIR!\tt_*.xml" "!OUTDIR!\signature.txt" "!OUTDIR!\signature.xml" "!OUTDIR!\od_tellingen.*" "!OUTDIR!\unieke_od_tellingen.*" "!OUTDIR!\PerBlock\tt_*.parquet" "!OUTDIR!\Mediaan\tt_*.parquet" "!OUTDIR!\Tellingen\tellingen_*.*" 2>nul
)
REM The output runs in portions of origin blocks, each in its own GeoDmsRun, followed by the counts with OdTellingen.py
REM (WriteOutputBlocks.ps1). Blocks per portion: ModelParameters/Advanced/Components/BlocksPerPortion of the component,
REM or the environment variable OUTPUT_BATCHSIZE; OUTPUT_MAXBLOCKS calculates at most that many blocks (for testing).
REM The environment variable OUTPUT_SINGLE runs one request for all blocks, with the counts included
REM (NetworkSetup/GenerateOutput/Generate_Output). With MergeOutput (#117) the merging of the Components also runs per
REM block in portions (ComponentMerge/PerBlock).
if defined OUTPUT_SINGLE goto output_single
echo === output: a file per origin block and departure moment, in portions (WriteOutputBlocks.ps1; hours) ===
set STEP=output
set "OUTBS="
if defined OUTPUT_BATCHSIZE set "OUTBS=-BatchSize %OUTPUT_BATCHSIZE%"
if defined OUTPUT_MAXBLOCKS set "OUTBS=!OUTBS! -MaxBlocks %OUTPUT_MAXBLOCKS%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%BATCHDIR%WriteOutputBlocks.ps1" -Exe "%EXE%" -Cfg "%CFG%" -LogDir "%LOGDIR%" -OutDir "!OUTDIR!" !OUTBS!
set RC=!ERRORLEVEL!
if not "!RC!"=="0" goto failed
goto done
:output_single
echo === output: a file per origin block and departure moment, one request (OUTPUT_SINGLE; hours) ===
call :run output /NetworkSetup/GenerateOutput/Generate_Output
if not "!RC!"=="0" goto failed
goto done

:legs_write
REM Writes the caches of the base sets of pre- and post-transport that have none with the current signature
REM (PublicTransport_Prep/Write_PrePostTransport); nothing without public transport (ModelParameters/Impl/WithPT FALSE)
REM or without ModelParameters/Advanced/PrePostTransportDecoupled. RC holds the exit code.
call :run legs_check /ModelParameters/Impl/WithPT
if not "!RC!"=="0" exit /b !RC!
findstr /R "^Minimum.0" "%LOGDIR%\UpdateAll_legs_check.txt" >nul
if not errorlevel 1 (
  echo === legs: public transport is not part of this component, no pre- and post-transport caches ===
  set RC=0
  exit /b 0
)
echo === legs: the caches of the base sets without one (parquet in IntermediateResults) ===
call :run legs %PREP%/Write_PrePostTransport
exit /b !RC!

:run
REM %1 = step name, %2.. = items; each GeoDmsRun call requests the items with @statistics, which
REM for a cache holder writes the whole cache. RC holds the exit code (also a negative one, for an
REM aborted process; "if errorlevel 1" does not see that).
set STEP=%1
set ITEMS=
:runargs
shift
if "%~1"=="" goto runexec
set ITEMS=!ITEMS! @statistics %~1
goto runargs
:runexec
echo %DATE% %TIME% %STEP%: %ITEMS%
"%EXE%" "/L%LOGDIR%\UpdateAll_%STEP%.log" "%CFG%" %ITEMS% > "%LOGDIR%\UpdateAll_%STEP%.txt" 2>&1
set RC=%ERRORLEVEL%
echo %DATE% %TIME% %STEP%: exit %RC%
exit /b %RC%

:failed
echo UpdateAll %SECTION% FAILED at step %STEP% (exit %RC%) %DATE% %TIME%
exit /b 1

:done
echo UpdateAll %SECTION% done %DATE% %TIME%
exit /b 0
