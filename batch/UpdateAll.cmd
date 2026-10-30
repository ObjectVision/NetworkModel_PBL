@echo off
setlocal EnableDelayedExpansion
REM ---------------------------------------------------------------------------------------------
REM UpdateAll.cmd: calculates the variant of ModelParameters with GeoDmsRun: the caches, the output of every component
REM of the variant, and their merge. Each step is a separate GeoDmsRun call, so that memory is freed between the steps,
REM and the script stops at an error. Logs in batch\log\UpdateAll_<step>[_<component>].log, the console output of
REM GeoDmsRun in UpdateAll_<step>[_<component>].txt; at an error the console also shows the error messages of GeoDmsRun
REM (ShowGeoDmsErrors.ps1). Every step writes a line with its start, end and duration to the console and to
REM batch\log\UpdateAll_status.txt.
REM
REM The variant (ModelParameters, group 2) is every combination of a pre-transport type that is on with a post-transport
REM type that is on, plus the direct trips that are on (WW, CC, Car), #117. The script first checks the settings
REM (ChecksBeforeRunning/Report, written to batch\log\checks.txt) and stops at a FAIL, with the message of the model. Then
REM it calculates the components one after the other, each in its own GeoDmsRun steps: it sets the component in the
REM environment variable GEODMS_Overridable_RunComponent, which the model reads as ConfigSettings/Overridable/RunComponent.
REM A component whose output is complete (NetworkSetup/GenerateOutput/IsComplete: the signature of the current settings
REM and the counts of all blocks) is skipped, so a run that stopped continues with the next component when started again.
REM With ModelParameters/Merge the merge of the components follows, as the last component, Merged.
REM
REM   UpdateAll.cmd                 all sections: sources, then per component cars, chains, legs and output, then the merge
REM   UpdateAll.cmd all -nosources  everything except the named sections: -nosources, -nocars, -nochains, -nolegs, -nooutput
REM   UpdateAll.cmd sources         the OSM network and GTFS caches (only needed for a new edition; about 15 min). The car on
REM                                 the TomTom network reads the four TomTom caches as source data from
REM                                 NetworkModel_PrivDir\TomTom\<edition>; UpdateAll does not make them.
REM   UpdateAll.cmd checks          only the checks of the settings and the list of components (batch\log\components.txt)
REM   UpdateAll.cmd cars [moment..] the caches of the direct car trip per departure moment, for the component Car
REM                                 (PublicTransport_Prep/Direct/CarPerMoment/<moment>/Write_Car); without moments the
REM                                 moments the model reads (MakeUnlinkedData/Step4_DirectCar/Moments); with moments, for
REM                                 example MorningRush NoonRush LateEveningRush and Freeflow (TomTom) or MaxSpeed (OSM);
REM                                 about 40 min per moment with a scalar search, longer with ParetoLegs_Car
REM   UpdateAll.cmd chains          the public transport chain cache per stop block (WriteChainBlocks.ps1; with the
REM                                 environment variable CHAINCACHE_SINGLE the single cache of
REM                                 PublicTransport_Prep/ChainGeneration_Single/Write), after the pre-check of the stop
REM                                 blocks and the price coverage; takes hours and much memory. The chain cache does not
REM                                 depend on the pre- and post-transport, so the first public transport component makes
REM                                 it and the others find it.
REM   UpdateAll.cmd legs            the caches of the pre- and post-transport connections of the public transport
REM                                 components: the base sets without a cache (PublicTransport_Prep/Write_PrePostTransport);
REM                                 writes only with ModelParameters/Advanced/PrePostTransportDecoupled (on by default)
REM   UpdateAll.cmd output          the output of every component that is not complete: a file per origin block and
REM                                 departure moment in %LocalDataProjDir%\Output\<Analysis_date>_<OutputLabel>_<component>[_fb]\PerBlock
REM                                 (_fb: a component on the cycling network with CyclingNetwork 'Fietsersbond'), with the
REM                                 chain cache of the departure moments of PartOfDay, and then the merge. The step first
REM                                 writes the missing pre- and post-transport caches, as legs does, and empties the output
REM                                 folder of the component (#118), removing only the files of the model: tt_*.csv,
REM                                 tt_*.parquet and tt_*.xml, signature.txt/.xml, the counts od_tellingen.csv and
REM                                 unieke_od_tellingen.csv (with .xml) and Tellingen\tellingen_*.*. It runs in portions of
REM                                 blocks (WriteOutputBlocks.ps1, a GeoDmsRun per portion, then the counts with
REM                                 OdTellingen.py); blocks per portion per component in Classifications/Components/
REM                                 BlocksPerPortion, or set with OUTPUT_BATCHSIZE; with OUTPUT_SINGLE in one request.
REM   UpdateAll.cmd merge           only the merge of the components of the variant (their output must be complete)
REM   ... -component <name>         only that component of the variant, for example -component C_PT_OVf_C, or Merged
REM Run one UpdateAll at a time, not two at the same time: the output step of a component can need more than 100 GB of
REM memory, and two at once make the machine page.
REM ---------------------------------------------------------------------------------------------
REM Engine. The model asks for the pareto epsilon and the bool criteria of pareto_optimal_eps, which older versions of
REM GeoDMS do not know; GEODMS_VERSION is the version it was tested with. GeoDmsRun.exe comes from, in this order:
REM the environment variable GEODMS_EXE (another engine, for example a test build); the local build in
REM C:\dev\GeoDMS_2026; the installed GEODMS_VERSION, flavor m or c, in the folder that the installer writes to the
REM registry (by default C:\Program Files\ObjectVision\GeoDms<version>.<flavor>).
set GEODMS_VERSION=20.27.0
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
set "STATUS=%LOGDIR%\UpdateAll_status.txt"
set PREP=/NetworkSetup/PublicTransport_Prep

set SECTION=%~1
if "%SECTION%"=="" set SECTION=all
REM The arguments after the section: -no<section> skips a section, -component <name> chooses one component, the others
REM are moments for cars. (shift leaves %* unchanged, so the script collects them itself.)
set MOMENTS=
set ONLY=
set SKIP_SOURCES=0
set SKIP_CARS=0
set SKIP_CHAINS=0
set SKIP_LEGS=0
set SKIP_OUTPUT=0
:args
shift
if "%~1"=="" goto argsdone
if /I "%~1"=="-component" (
  set "ONLY=%~2"
  shift
  goto args
)
if /I "%~1"=="-nosources" (set SKIP_SOURCES=1) else if /I "%~1"=="-nocars" (set SKIP_CARS=1) else if /I "%~1"=="-nochains" (set SKIP_CHAINS=1) else if /I "%~1"=="-nolegs" (set SKIP_LEGS=1) else if /I "%~1"=="-nooutput" (set SKIP_OUTPUT=1) else set MOMENTS=!MOMENTS! %~1
goto args
:argsdone

set "WHAT=UpdateAll %SECTION%%MOMENTS%"
if defined ONLY set "WHAT=%WHAT% -component %ONLY%"
call :say "%WHAT% started"
call :say "engine: %EXE%"
set COMP=
set CTAG=
set GEODMS_Overridable_RunComponent=

set KNOWN=0
for %%S in (all sources checks cars chains legs output merge) do if /I "%SECTION%"=="%%S" set KNOWN=1
if "%KNOWN%"=="0" (
  echo Unknown section "%SECTION%": choose all, sources, checks, cars, chains, legs, output or merge.
  exit /b 1
)

REM First the checks of the settings alone (ChecksBeforeRunning/Report_Settings), so that a wrong setting stops the run with a
REM message before the sources step; then the sources, the OSM network and the GTFS cache that every component reads; then
REM the checks of the settings and the caches (ChecksBeforeRunning/Report) and the list of components.
call :checkstep checks_settings checks_settings.txt /ChecksBeforeRunning/Report_Settings
if not "!RC!"=="0" goto failed
if /I "%SECTION%"=="sources" goto sources
if /I "%SECTION%"=="all" if not "%SKIP_SOURCES%"=="1" goto sources
goto checks
:sources
call :say "=== sources: OSM network cache ==="
call :run osm_network /SourceData/Infrastructure/OSM/Make_Final_Network
if not "!RC!"=="0" goto failed
call :say "=== sources: GTFS cache of the feed of the analysis moment ==="
call :run gtfs /SourceData/Infrastructure/GTFS/LoadFeeds/Write
if not "!RC!"=="0" goto failed
if /I "%SECTION%"=="sources" goto done

:checks
call :checkstep checks checks.txt /ChecksBeforeRunning/Report /ChecksBeforeRunning/Components
if not "!RC!"=="0" goto failed
if /I "%SECTION%"=="checks" goto done
set NCOMP=0
for /f "usebackq tokens=1 delims=;" %%A in ("%LOGDIR%\components.txt") do set /a NCOMP+=1
set ICOMP=0
if defined ONLY (
  findstr /B /I /C:"%ONLY%;" "%LOGDIR%\components.txt" >nul
  if errorlevel 1 (
    call :say "ABORT: %ONLY% is not a component of the variant; the variant has:"
    type "%LOGDIR%\components.txt"
    set STEP=checks
    set RC=1
    goto failed
  )
)

REM The components of the variant, one after the other; components.txt has per line the name, whether it uses public
REM transport (chains and legs) and whether it uses the car caches, and as the last line Merged when Merge is on.
for /f "usebackq tokens=1-3 delims=;" %%A in ("%LOGDIR%\components.txt") do (
  set /a ICOMP+=1
  call :component %%A %%B %%C
  if not "!RC!"=="0" goto failed
)
goto done

REM ---------------------------------------------------------------------------------------------
:checkstep
REM %1 = step name, %2 = the file in batch\log with one check per line, %3.. = the items. Writes and shows the checks and
REM stops (RC 1) at a line with FAIL. The step runs as the merge (Merged), which has all departure moments of the part of
REM the day and so the widest analysis window, whatever GuiComponent is.
set "CHECKFILE=%LOGDIR%\%~2"
call :say "=== %~1: ChecksBeforeRunning ==="
if exist "%CHECKFILE%" del "%CHECKFILE%"
if exist "%LOGDIR%\components.txt" del "%LOGDIR%\components.txt"
set GEODMS_Overridable_RunComponent=Merged
call :run %~1 %3 %4
set GEODMS_Overridable_RunComponent=
if not "!RC!"=="0" exit /b !RC!
if not exist "%CHECKFILE%" (
  call :say "ABORT: the checks were not written (%CHECKFILE%)"
  set RC=1
  exit /b 1
)
type "%CHECKFILE%"
type "%CHECKFILE%" >> "%STATUS%"
findstr /B /C:"FAIL" "%CHECKFILE%" >nul
if not errorlevel 1 (
  call :say "ABORT: a check failed, see the FAIL lines above; change ModelParameters, or run the sources step, and start again"
  set RC=1
  exit /b 1
)
exit /b 0

REM ---------------------------------------------------------------------------------------------
:component
REM %1 = component, %2 = 1 when it uses public transport, %3 = 1 when it uses the car caches. RC holds the exit code.
set RC=0
if defined ONLY if /I not "%~1"=="%ONLY%" exit /b 0
set "COMP=%~1"
set "CTAG=_%~1"
set "GEODMS_Overridable_RunComponent=%~1"
call :say "=== component %ICOMP% of %NCOMP%: %~1 ==="
if /I "%~1"=="Merged" (
  if /I "%SECTION%"=="all" if not "%SKIP_OUTPUT%"=="1" call :output_comp
  if /I "%SECTION%"=="output" call :output_comp
  if /I "%SECTION%"=="merge" call :output_comp
  exit /b !RC!
)
if /I "%SECTION%"=="merge" exit /b 0
if "%~3"=="1" (
  if /I "%SECTION%"=="cars" call :cars_comp
  if /I "%SECTION%"=="all" if not "%SKIP_CARS%"=="1" call :cars_comp
  if not "!RC!"=="0" exit /b !RC!
)
if "%~2"=="1" (
  if /I "%SECTION%"=="chains" call :chains_comp
  if /I "%SECTION%"=="all" if not "%SKIP_CHAINS%"=="1" call :chains_comp
  if not "!RC!"=="0" exit /b !RC!
  if /I "%SECTION%"=="legs" call :legs_write
  if /I "%SECTION%"=="all" if not "%SKIP_LEGS%"=="1" call :legs_write
  if not "!RC!"=="0" exit /b !RC!
)
if /I "%SECTION%"=="output" call :output_comp
if /I "%SECTION%"=="all" if not "%SKIP_OUTPUT%"=="1" call :output_comp
exit /b !RC!

:cars_comp
if "%MOMENTS%"=="" (
  call :run car_moments /MakeUnlinkedData/Step4_DirectCar/Moments
  if not "!RC!"=="0" exit /b !RC!
  set /p MOMENTS=<"%LOGDIR%\car_moments.txt"
)
for %%M in (%MOMENTS%) do (
  call :say "--- direct car trip: cache for %%M ---"
  call :run car_%%M %PREP%/Direct/CarPerMoment/%%M/Write_Car
  if not "!RC!"=="0" exit /b !RC!
)
exit /b 0

:chains_comp
call :say "--- chains: pre-check of the stop blocks and the price coverage ---"
call :run chains_precheck /ChecksBeforeRunning/PT_CheckBlocks /SourceData/Infrastructure/OVprijzen/PriceCoverage/Table_OK_DOVA
if not "!RC!"=="0" exit /b !RC!
findstr /R "^Minimum.1" "%LOGDIR%\UpdateAll_chains_precheck%CTAG%.txt" >nul
if errorlevel 1 (
  call :say "ABORT: the price coverage is not OK, see %LOGDIR%\UpdateAll_chains_precheck%CTAG%.txt"
  set STEP=chains_precheck
  set RC=1
  exit /b 1
)
if defined CHAINCACHE_SINGLE (
  call :say "--- chains: ChainGeneration_Single/Write, one cache for all blocks (CHAINCACHE_SINGLE; also set PT_Chains_PerBlock to FALSE) ---"
  call :run chains %PREP%/ChainGeneration_Single/Write
  exit /b !RC!
)
call :say "--- chains: the stop blocks without a cache, in portions (WriteChainBlocks.ps1) ---"
set STEP=chains
powershell -NoProfile -ExecutionPolicy Bypass -File "%BATCHDIR%WriteChainBlocks.ps1" -Exe "%EXE%" -Cfg "%CFG%" -LogDir "%LOGDIR%" -Tag "%CTAG%" -Status "%STATUS%"
set RC=!ERRORLEVEL!
exit /b !RC!

:legs_write
REM Writes the caches of the base sets of pre- and post-transport of the component that have none with the current
REM signature (PublicTransport_Prep/Write_PrePostTransport); nothing without ModelParameters/Advanced/PrePostTransportDecoupled.
call :say "--- legs: the caches of the base sets without one (parquet in IntermediateResults) ---"
call :run legs %PREP%/Write_PrePostTransport
exit /b !RC!

:output_comp
REM Pause before the output step: as long as batch\pause_before_output.flag exists, the output step waits without a
REM calculation process, for example to free the machine for performance tests; removing the flag lets it start.
set "PAUSEFLAG=%BATCHDIR%pause_before_output.flag"
if exist "%PAUSEFLAG%" call :say "pause before the output step: waiting until %PAUSEFLAG% is gone"
:output_wait
if exist "%PAUSEFLAG%" (
  ping -n 61 127.0.0.1 >nul
  goto output_wait
)
REM The output folder of the component (NetworkSetup/GenerateOutput/OutputDir_ForBatch, written to batch\log\output_dir.txt),
REM the check of the longest path (Output_Sig/PathGate), and whether the output is complete (IsComplete, written to
REM batch\log\output_complete.txt).
for %%F in (output_dir.txt output_complete.txt) do if exist "%LOGDIR%\%%F" del "%LOGDIR%\%%F"
call :run output_dir /NetworkSetup/GenerateOutput/OutputDir_ForBatch /NetworkSetup/GenerateOutput/Output_Sig/PathGate /NetworkSetup/GenerateOutput/ForBatch/IsComplete
if not "!RC!"=="0" exit /b !RC!
set OUTDIR=
set /p OUTDIR=<"%LOGDIR%\output_dir.txt"
if not defined OUTDIR (
  call :say "ABORT: no output folder in %LOGDIR%\output_dir.txt"
  set STEP=output_dir
  set RC=1
  exit /b 1
)
set OUTSTATE=
set /p OUTSTATE=<"%LOGDIR%\output_complete.txt"
if /I "!OUTSTATE!"=="complete" (
  call :say "--- output of %COMP% is complete in !OUTDIR!, skipped ---"
  exit /b 0
)
REM Every portion reads the pre- and post-transport connections from their caches (ModelParameters/Advanced/PrePostTransportDecoupled),
REM so the base sets without a cache are written first, once; with section all the legs step has done that already.
if /I "%SECTION%"=="output" if not "%SKIP_LEGS%"=="1" if /I not "%COMP%"=="Merged" (
  call :legs_write
  if not "!RC!"=="0" exit /b !RC!
)
REM Empty the output folder (NetworkModel_PBL#118): the file names carry only the moment and the block, and the parameters
REM are in signature.txt in the folder, so without emptying a run after a code change would put its blocks next to those
REM of the previous run. Only the files the model writes there are removed, and only if the folder lies under a folder
REM Output. Does the path contain \Output\, or \Output_ of an OD pair (Output_<O>_<D>, #129)? Replacing it by nothing then
REM makes the string shorter; cmd replaces case-insensitively.
set OUTOK=
if not "!OUTDIR:\Output\=!"=="!OUTDIR!" set OUTOK=1
if not "!OUTDIR:\Output_=!"=="!OUTDIR!" set OUTOK=1
if not defined OUTOK (
  call :say "ABORT: the output folder !OUTDIR! is not under a folder Output or Output_O_D of an OD pair"
  set STEP=output_dir
  set RC=1
  exit /b 1
)
if exist "!OUTDIR!\" (
  call :say "emptying the output folder: !OUTDIR!"
  del /q "!OUTDIR!\PerBlock\tt_*.csv" "!OUTDIR!\PerBlock\tt_*.xml" "!OUTDIR!\Mediaan\tt_*.csv" "!OUTDIR!\Mediaan\tt_*.xml" "!OUTDIR!\tt_*.csv" "!OUTDIR!\tt_*.xml" "!OUTDIR!\signature.txt" "!OUTDIR!\signature.xml" "!OUTDIR!\od_tellingen.*" "!OUTDIR!\unieke_od_tellingen.*" "!OUTDIR!\PerBlock\tt_*.parquet" "!OUTDIR!\Mediaan\tt_*.parquet" "!OUTDIR!\Tellingen\tellingen_*.*" 2>nul
)
REM The output runs in portions of origin blocks, each in its own GeoDmsRun, followed by the counts with OdTellingen.py
REM (WriteOutputBlocks.ps1). Blocks per portion: Classifications/Components/BlocksPerPortion of the component,
REM or the environment variable OUTPUT_BATCHSIZE; OUTPUT_MAXBLOCKS calculates at most that many blocks (for testing).
REM The environment variable OUTPUT_SINGLE runs one request for all blocks, with the counts included
REM (NetworkSetup/GenerateOutput/Generate_Output). The merge (Merged) also runs per block in portions (ComponentMerge/PerBlock).
if defined OUTPUT_SINGLE (
  call :say "--- output of %COMP%: a file per origin block and departure moment, one request (OUTPUT_SINGLE) ---"
  call :run output /NetworkSetup/GenerateOutput/Generate_Output
  exit /b !RC!
)
call :say "--- output of %COMP%: a file per origin block and departure moment, in portions (WriteOutputBlocks.ps1) ---"
set STEP=output
set "OUTBS="
if defined OUTPUT_BATCHSIZE set "OUTBS=-BatchSize %OUTPUT_BATCHSIZE%"
if defined OUTPUT_MAXBLOCKS set "OUTBS=!OUTBS! -MaxBlocks %OUTPUT_MAXBLOCKS%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%BATCHDIR%WriteOutputBlocks.ps1" -Exe "%EXE%" -Cfg "%CFG%" -LogDir "%LOGDIR%" -OutDir "!OUTDIR!" -Tag "%CTAG%" -Status "%STATUS%" !OUTBS!
set RC=!ERRORLEVEL!
exit /b !RC!

REM ---------------------------------------------------------------------------------------------
:say
REM %1 = a line for the console and batch\log\UpdateAll_status.txt, with the date and time in front.
echo %DATE% %TIME:~0,8% %~1
>> "%STATUS%" echo %DATE% %TIME:~0,8% %~1
exit /b 0

:run
REM %1 = step name, %2.. = items; each GeoDmsRun call requests the items with @statistics, which
REM for a cache holder writes the whole cache. RC holds the exit code (also a negative one, for an
REM aborted process; "if errorlevel 1" does not see that). The log and console files carry the component (CTAG).
set STEP=%1
set ITEMS=
:runargs
shift
if "%~1"=="" goto runexec
set ITEMS=!ITEMS! @statistics %~1
goto runargs
:runexec
for /f %%T in ('powershell -NoProfile -Command "[DateTimeOffset]::Now.ToUnixTimeSeconds()"') do set T0=%%T
call :say "%COMP% %STEP%: start"
"%EXE%" "/L%LOGDIR%\UpdateAll_%STEP%%CTAG%.log" "%CFG%" %ITEMS% > "%LOGDIR%\UpdateAll_%STEP%%CTAG%.txt" 2>&1
set RC=%ERRORLEVEL%
for /f %%T in ('powershell -NoProfile -Command "[DateTimeOffset]::Now.ToUnixTimeSeconds()"') do set T1=%%T
set /a DT=T1-T0
set /a DH=DT/3600, DM=(DT%%3600)/60, DS=DT%%60
if %DM% LSS 10 set DM=0%DM%
if %DS% LSS 10 set DS=0%DS%
call :say "%COMP% %STEP%: exit %RC% after %DH%:%DM%:%DS%"
REM At an error the messages of GeoDmsRun go to the console as well. A syntax error in the configuration stops the first
REM step of a section, whatever that step makes, and without them the console shows only the exit code of that step.
if not "%RC%"=="0" powershell -NoProfile -ExecutionPolicy Bypass -File "%BATCHDIR%ShowGeoDmsErrors.ps1" -Path "%LOGDIR%\UpdateAll_%STEP%%CTAG%.txt"
exit /b %RC%

:failed
call :say "%WHAT% FAILED at step %STEP% of %COMP% (exit %RC%)"
exit /b 1

:done
call :say "%WHAT% done"
exit /b 0
