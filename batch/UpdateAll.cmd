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
REM (ChecksBeforeRunning/Report_Settings, written to batch\log\checks_settings.txt), makes the source caches that are
REM missing, and checks the settings and the caches (ChecksBeforeRunning/Report, batch\log\checks.txt); it stops at a FAIL,
REM with the message of the model. Then it calculates the components one after the other, each in its own GeoDmsRun steps:
REM it sets the component in the environment variable GEODMS_Overridable_RunComponent, which the model reads as
REM ConfigSettings/Overridable/RunComponent. Every step skips the work that is already there: a cache whose name and
REM signature match the current settings is read and not made again, and a component whose output is complete
REM (NetworkSetup/GenerateOutput/IsComplete: the signature of the current settings and the counts of all blocks) is
REM skipped with its cache steps. So a run that stopped continues where it stopped when it is started again, and after a
REM change of a setting only what depends on it is calculated. The chain cache that the public transport components share
REM is a step of its own, before the first public transport component (see chains below); the console numbers the
REM components and that step together, for example "step 4 of 11". With ModelParameters/Merge the merge of the components
REM follows, as the last component, Merged.
REM
REM   UpdateAll.cmd [all]           everything: the checks, the source caches, then per component the car caches, the pre-
REM                                 and post-transport caches and the output, with the chain cache before the first public
REM                                 transport component, and the merge. Also without arguments, for example after a
REM                                 double-click in Explorer; the script then waits for a key at the end
REM   UpdateAll.cmd sources         the source caches: the OSM network (SourceData/Infrastructure/OSM/CachePath, whose name
REM                                 holds a hash of OSM/Signature) and the GTFS cache of the feed of the analysis moment
REM                                 (GTFS/LoadFeeds/CachePath, named after the feed date), a few minutes each. A cache that
REM                                 exists is skipped (OSM/ForBatch/CacheState and GTFS/LoadFeeds/ForBatch/CacheState, written
REM                                 to batch\log\osm_cache.txt and gtfs_cache.txt); remove its folder to make it again, for
REM                                 example after a new delivery of a feed under the same date. The car on the TomTom network
REM                                 reads the four TomTom caches as source data from NetworkModel_PrivDir\TomTom\<edition>;
REM                                 UpdateAll does not make them.
REM   UpdateAll.cmd checks          only the checks of the settings and the caches, and the list of components
REM                                 (batch\log\components.txt)
REM   UpdateAll.cmd cars [moment..] the caches of the direct car trip per departure moment, for the component Car
REM                                 (PublicTransport_Prep/Direct/CarPerMoment/<moment>/Write_Car); without moments the
REM                                 moments the model reads (MakeUnlinkedData/Step4_DirectCar/Moments: TD07h00m and on with
REM                                 CarTimeDependent); with moments those, for example MorningRush NoonRush LateEveningRush
REM                                 and Freeflow (TomTom) or MaxSpeed (OSM). About 40 min per static moment with a scalar
REM                                 search, longer with ParetoLegs_Car, and about 3 hours per time-dependent departure moment.
REM                                 A moment whose cache exists with the current signature is skipped (CarPerMoment/<moment>/
REM                                 IsWritten); remove its folder in IntermediateResults to make it again
REM   UpdateAll.cmd chains          the public transport chain cache per stop block (WriteChainBlocks.ps1; with
REM                                 ModelParameters/Advanced/PT_Chains_PerBlock FALSE the one cache of
REM                                 PublicTransport_Prep/ChainGeneration_Single/Write), after the pre-check of the stop
REM                                 blocks and the price coverage; takes hours and much memory. The chain cache does not
REM                                 depend on the component, because its window follows the longest pre-transport of the
REM                                 variant (Impl/PT_Chains_Max_V_Time), so the public transport components share it:
REM                                 it is a step of its own before the first public transport component, with the
REM                                 settings of the first public transport component whose output is not complete, and with
REM                                 section all it is skipped when the output of every public transport component is
REM                                 complete. The signature (PT_Chains_Signature, as a hash in the name of the cache folder)
REM                                 is that of the whole cache and holds no component. The step calculates only the stop
REM                                 blocks that the cache with the current signature misses: all of them when there is no
REM                                 such cache yet (after a change of a setting in the signature), the rest after an
REM                                 interrupted run, none when it is complete, and then it takes seconds. Its logs carry no
REM                                 component: UpdateAll_chains_precheck, UpdateAll_chains_todo, UpdateAll_chains.
REM   UpdateAll.cmd legs            the caches of the pre- and post-transport connections of the public transport
REM                                 components: the base sets without a cache (PublicTransport_Prep/Write_PrePostTransport);
REM                                 writes only with ModelParameters/Advanced/PrePostTransportDecoupled (on by default)
REM   ... -component <name>         with all, cars, chains or legs: only that component of the variant, for example
REM                                 -component C_PT_ovfC; not Merged, because the merge is the last step of all
REM   ... -variant <name>           the merge variant <name>, a row of ModelParameters/MergeVariants: its components, merge
REM                                 criteria and number (Merged<n>) in place of the switches of ModelParameters, group 2, and
REM                                 of MergeCriteria and MergeRunNr. Repeated, or -variant all for every row, the script runs
REM                                 itself once per variant, one after the other, with the same section and options; a component
REM                                 that an earlier variant calculated is complete and skipped, so the next variants only merge
REM   ... -set <name> <value>       for this call, the setting <name> of ModelParameters gets <value>: AnalysisMoment, PartOfDay,
REM                                 Orgset, Destset, OutputLabel or Advanced/NS_TariffChoice, for example -set PartOfDay Middag
REM                                 -set OutputLabel b2025_middag; repeated for more settings
REM   Example: UpdateAll.cmd all -variant all -set PartOfDay Avond -set OutputLabel b2025_avond -set NS_TariffChoice Price_FullFare
REM The section comes first; cars takes moments, any other word or option stops the script before it starts. The variant and the
REM settings go to every GeoDmsRun step in the environment variables GEODMS_Overridable_Variant and GEODMS_Overridable_<name>
REM (ConfigSettings/Overridable, ModelParameters/Impl/Given), and the checks show them in their first line. A setting that the call
REM does not give gets the value ModelParameters, which means: the value in ModelParameters.dms. So only the options of the call
REM count, not those of an earlier call in the same window, nor a value of the same name in the registry.
REM
REM The output step of a component, with all after its cache steps: a file per origin block and departure moment in
REM %LocalDataProjDir%\Output\<Analysis_date>_<OutputLabel>_<component>[_fb]_<hash>\PerBlock (_fb: a component on the cycling
REM network with CyclingNetwork 'Fietsersbond'; <hash>: the hash of the signature of the output, NetworkModel_PBL#145), with
REM the chain cache of the departure moments of PartOfDay. The step
REM first empties the output folder of the component (#118), removing only the files of the model: tt_*.csv, tt_*.parquet
REM and tt_*.xml, signature.txt/.xml, the counts od_tellingen.csv and unieke_od_tellingen.csv (with .xml) and
REM Tellingen\tellingen_*.*. It runs in portions of blocks (WriteOutputBlocks.ps1, a GeoDmsRun per portion, then the
REM counts of all blocks in one more GeoDmsRun); blocks per portion per component in Classifications/Components/BlocksPerPortion, or set
REM with OUTPUT_BATCHSIZE; OUTPUT_MAXBLOCKS calculates at most that many blocks, for a test.
REM Run one UpdateAll at a time, not two at the same time: the output step of a component can need more than 100 GB of
REM memory, and two at once make the machine page.
REM ---------------------------------------------------------------------------------------------
REM The full path name without "..": GeoDMS derives %LocalDataProjDir% from the name of the folder above cfg, and
REM with batch\..\cfg\main.dms that name is "..", which puts the caches in C:\LocalData\..\IntermediateResults, that is C:\.
for %%I in ("%~dp0..\cfg\main.dms") do set CFG=%%~fI
REM Store the batch folder for the argument loop: after shift, %~dp0 no longer points to this folder.
set "BATCHDIR=%~dp0"
set LOGDIR=%~dp0log
set "STATUS=%LOGDIR%\UpdateAll_status.txt"
set PREP=/NetworkSetup/PublicTransport_Prep
REM The settings of ModelParameters that -set takes (ConfigSettings/Overridable).
set "SETNAMES=AnalysisMoment PartOfDay Orgset Destset OutputLabel NS_TariffChoice"

REM The arguments: the section, with cars the moments, and -component <name>. Anything else stops the script before it writes to
REM the status file, so that a typing error cannot start another run than the one meant.
set SECTION=%~1
REM Without arguments, as after a double-click in Explorer, the section is all, and the script waits for a key at the end:
REM the window closes when the script ends, and would otherwise not show how the run ended.
set PAUSE_END=
if "%SECTION%"=="" (
  set SECTION=all
  set PAUSE_END=1
)
if "%SECTION%"=="/?" goto usage_ok
for %%H in (-h -help --help help) do if /I "%SECTION%"=="%%H" goto usage_ok
set KNOWN=0
for %%S in (all sources checks cars chains legs) do if /I "%SECTION%"=="%%S" set KNOWN=1
if "%KNOWN%"=="0" (
  echo Unknown section "%SECTION%".
  goto usage
)
set MOMENTS=
set ONLY=
REM The variants of -variant. Only the options of this call count: every setting starts as not given (ModelParameters, see
REM ModelParameters/Impl/Given/NotGiven), whatever an earlier call in the same window, the call that runs this one per variant, or
REM the registry holds; -variant and -set then give their own.
for %%N in (Variant %SETNAMES%) do set GEODMS_Overridable_%%N=ModelParameters
set VARIANTS=
set NVARIANTS=0
set SETARGS=
:args
shift
set "ARG=%~1"
if not defined ARG goto argsdone
if /I "!ARG!"=="-variant" (
  set "VNAME=%~2"
  if not defined VNAME (
    echo -variant needs the name of a merge variant, or all.
    goto usage
  )
  if "!VNAME:~0,1!"=="-" (
    echo -variant needs the name of a merge variant, or all, not "!VNAME!".
    goto usage
  )
  set "VARIANTS=!VARIANTS! !VNAME!"
  set /a NVARIANTS+=1
  shift
  goto args
)
if /I "!ARG!"=="-set" (
  set "SNAME=%~2"
  set "SVALUE=%~3"
  set SKNOWN=
  if defined SNAME for %%N in (%SETNAMES%) do if /I "!SNAME!"=="%%N" set "SKNOWN=%%N"
  if not defined SKNOWN (
    echo -set takes one of %SETNAMES%, not "!SNAME!".
    goto usage
  )
  if not defined SVALUE (
    echo -set !SKNOWN! needs a value.
    goto usage
  )
  if "!SVALUE:~0,1!"=="-" (
    echo -set !SKNOWN! needs a value, not "!SVALUE!".
    goto usage
  )
  set "GEODMS_Overridable_!SKNOWN!=!SVALUE!"
  set "SETARGS=!SETARGS! -set !SKNOWN! !SVALUE!"
  shift
  shift
  goto args
)
if /I "!ARG!"=="-component" (
  set "ONLY=%~2"
  if not defined ONLY (
    echo -component needs the name of a component.
    goto usage
  )
  if "!ONLY:~0,1!"=="-" (
    echo -component needs the name of a component, not "!ONLY!".
    goto usage
  )
  if /I "!ONLY!"=="Merged" (
    echo -component takes a component, not Merged: the merge is the last step of all.
    goto usage
  )
  shift
  goto args
)
if "!ARG:~0,1!"=="-" (
  echo Unknown option "!ARG!".
  goto usage
)
if /I not "%SECTION%"=="cars" (
  echo The section %SECTION% takes no moments or other words: "!ARG!".
  goto usage
)
set "MOMENTS=!MOMENTS! !ARG!"
goto args
:argsdone
if defined ONLY for %%S in (sources checks) do if /I "%SECTION%"=="%%S" (
  echo The section %SECTION% takes no -component.
  goto usage
)
REM One merge variant goes to every step; more than one, or all, makes the script run itself once per variant (variants_loop).
set VARIANTLOOP=
if %NVARIANTS% GTR 1 set VARIANTLOOP=1
for %%V in (!VARIANTS!) do if /I "%%V"=="all" set VARIANTLOOP=1
if not defined VARIANTLOOP if defined VARIANTS set "GEODMS_Overridable_Variant=!VARIANTS:~1!"

REM Engine. The model asks for the pareto epsilon and the bool criteria of pareto_optimal_eps, which older versions of
REM GeoDMS do not know; GEODMS_VERSION is the version it was tested with. GeoDmsRun.exe comes from the environment
REM variable GEODMS_EXE (another engine, for example a test build), and otherwise from the installed GEODMS_VERSION,
REM flavor m or c, in the folder that the installer writes to the registry (by default
REM C:\Program Files\ObjectVision\GeoDms<version>.<flavor>).
set GEODMS_VERSION=20.28.0
set "EXE="
if defined GEODMS_EXE set "EXE=%GEODMS_EXE%"
if not defined EXE for %%F in (m c) do if not defined EXE (
  for /f "tokens=2,*" %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\GeoDms%GEODMS_VERSION%.%%F" /v InstallLocation /reg:64 2^>nul ^| findstr /i InstallLocation') do if exist "%%B\GeoDmsRun.exe" set "EXE=%%B\GeoDmsRun.exe"
  if not defined EXE if exist "%ProgramW6432%\ObjectVision\GeoDms%GEODMS_VERSION%.%%F\GeoDmsRun.exe" set "EXE=%ProgramW6432%\ObjectVision\GeoDms%GEODMS_VERSION%.%%F\GeoDmsRun.exe"
)
if not defined EXE (
  echo ABORT: no GeoDmsRun.exe found. Install GeoDMS %GEODMS_VERSION%, or set GEODMS_EXE to the full path of GeoDmsRun.exe.
  if defined PAUSE_END pause
  exit /b 1
)

if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set "PASSARGS=%MOMENTS%"
if defined ONLY set "PASSARGS=%PASSARGS% -component %ONLY%"
set "WHAT=UpdateAll %SECTION%%PASSARGS%"
for %%V in (!VARIANTS!) do set "WHAT=!WHAT! -variant %%V"
set "WHAT=!WHAT!!SETARGS!"
call :say "%WHAT% started"
call :say "engine: %EXE%"
set COMP=
set CTAG=
set OUTSTATE_OF=
set GEODMS_Overridable_RunComponent=
if defined VARIANTLOOP goto variants_loop

REM First the checks of the settings alone (ChecksBeforeRunning/Report_Settings), so that a wrong setting stops the run with a
REM message before the sources step; then the source caches that are missing, which every component reads; then the checks of
REM the settings and the caches (ChecksBeforeRunning/Report) and the list of components.
call :checkstep checks_settings checks_settings.txt /ChecksBeforeRunning/Report_Settings
if not "!RC!"=="0" goto failed
if /I "%SECTION%"=="sources" goto sources
if /I "%SECTION%"=="all" goto sources
goto checks
:sources
call :sources_step
if not "!RC!"=="0" goto failed
if /I "%SECTION%"=="sources" goto done

:checks
call :checkstep checks checks.txt /ChecksBeforeRunning/Report /ChecksBeforeRunning/Components
if not "!RC!"=="0" goto failed
if /I "%SECTION%"=="checks" goto done
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

REM Section chains: only the chain cache that the public transport components share.
if /I "%SECTION%"=="chains" (
  set STEPLABEL=
  call :chains_shared
  if not "!RC!"=="0" goto failed
  goto done
)

REM The steps: the components of the variant one after the other, and with section all, before the first public transport
REM component, the chain cache that they share; components.txt has per line the name, whether the component uses public
REM transport (the chain cache and legs) and whether it uses the car caches, and as the last line Merged when Merge is on.
REM NSTEP counts the steps that the section takes, for the numbering on the console.
set NSTEP=0
set CHAINSTEP=
for /f "usebackq tokens=1-3 delims=;" %%A in ("%LOGDIR%\components.txt") do call :count_step %%A %%B %%C
if defined CHAINSTEP set /a NSTEP+=1
if "%NSTEP%"=="0" (
  if /I "%SECTION%"=="cars" if defined ONLY call :say "--- cars: %ONLY% uses no car caches ---"
  if /I "%SECTION%"=="cars" if not defined ONLY call :say "--- cars: the variant has no direct car trip, no car caches ---"
  if /I "%SECTION%"=="legs" if defined ONLY call :say "--- legs: %ONLY% uses no public transport, no pre- and post-transport caches ---"
  if /I "%SECTION%"=="legs" if not defined ONLY call :say "--- legs: the variant has no public transport component, no pre- and post-transport caches ---"
  goto done
)
set ISTEP=0
for /f "usebackq tokens=1-3 delims=;" %%A in ("%LOGDIR%\components.txt") do (
  if "%%B"=="1" if defined CHAINSTEP (
    set CHAINSTEP=
    set /a ISTEP+=1
    set "STEPLABEL=step !ISTEP! of %NSTEP%: "
    call :chains_shared
    if not "!RC!"=="0" goto failed
  )
  call :component %%A %%B %%C
  if not "!RC!"=="0" goto failed
)
goto done

REM ---------------------------------------------------------------------------------------------
:variants_loop
REM More than one merge variant, or all: the script runs itself once per variant, with the same section, moments, -component and
REM -set, and stops at the first variant that fails. With all, the names come from ModelParameters/MergeVariants (variants.txt).
set "VLIST=!VARIANTS!"
for %%V in (!VARIANTS!) do if /I "%%V"=="all" set VLIST=
if not defined VLIST (
  if exist "%LOGDIR%\variants.txt" del "%LOGDIR%\variants.txt"
  call :run variants /ChecksBeforeRunning/Variants
  if not "!RC!"=="0" goto failed
  for /f "usebackq delims=" %%V in ("%LOGDIR%\variants.txt") do set "VLIST=!VLIST! %%V"
)
if not defined VLIST (
  call :say "ABORT: no merge variants in %LOGDIR%\variants.txt"
  set STEP=variants
  set RC=1
  goto failed
)
set NV=0
for %%V in (!VLIST!) do set /a NV+=1
set IV=0
for %%V in (!VLIST!) do (
  set /a IV+=1
  call :say "=== variant !IV! of !NV!: %%V ==="
  call "%BATCHDIR%UpdateAll.cmd" %SECTION%%PASSARGS% -variant %%V!SETARGS!
  set RC=!ERRORLEVEL!
  if not "!RC!"=="0" (
    set "STEP=variant %%V"
    goto failed
  )
)
goto done

REM ---------------------------------------------------------------------------------------------
:usage
call :usage_text
exit /b 1
:usage_ok
call :usage_text
exit /b 0
:usage_text
echo Usage: UpdateAll.cmd [^<section^> [-component ^<name^>] [-variant ^<name^> ...] [-set ^<name^> ^<value^> ...]]
echo   all                everything that is missing, then the merge; also without arguments
echo   sources            the OSM network cache and the GTFS cache, when they are missing
echo   checks             the checks of the settings and the caches, and the list of components
echo   cars [moment ...]  the car caches of the moments the model reads, or of the moments named
echo   chains             the public transport chain cache
echo   legs               the pre- and post-transport caches
echo   -component ^<name^>  with all, cars, chains or legs: only that component of the variant
echo   -variant ^<name^>    a merge variant of ModelParameters/MergeVariants; repeated, or all, one after the other
echo   -set ^<name^> ^<value^> for this call a setting of ModelParameters: %SETNAMES%
echo Example: UpdateAll.cmd all -variant all -set PartOfDay Middag -set OutputLabel b2025_middag
echo See the header of batch\UpdateAll.cmd and the wiki page How to run the model.
exit /b 0

REM ---------------------------------------------------------------------------------------------
:count_step
REM %1 = component, %2 = 1 when it uses public transport, %3 = 1 when it uses the car caches. Counts the component in NSTEP when
REM the section calculates it, and with section all sets CHAINSTEP for a public transport component.
if defined ONLY if /I not "%~1"=="%ONLY%" exit /b 0
if /I "%SECTION%"=="cars" if not "%~3"=="1" exit /b 0
if /I "%SECTION%"=="legs" if not "%~2"=="1" exit /b 0
set /a NSTEP+=1
if /I "%SECTION%"=="all" if "%~2"=="1" set CHAINSTEP=1
exit /b 0

REM ---------------------------------------------------------------------------------------------
:sources_step
REM The OSM network cache and the GTFS cache, each only when it is missing. Their names hold what they depend on (OSM/Signature,
REM the feed date), and their state follows from the dictionary of the mmd, which GeoDMS writes last, so a cache whose writing
REM was interrupted is made again.
set RC=0
for %%F in (osm_cache.txt gtfs_cache.txt) do if exist "%LOGDIR%\%%F" del "%LOGDIR%\%%F"
call :run sources_state /SourceData/Infrastructure/OSM/ForBatch/CacheState /SourceData/Infrastructure/GTFS/LoadFeeds/ForBatch/CacheState
if not "!RC!"=="0" exit /b !RC!
call :source_cache osm osm_network "OSM network cache" /SourceData/Infrastructure/OSM/Make_Final_Network
if not "!RC!"=="0" exit /b !RC!
call :source_cache gtfs gtfs "GTFS cache of the feed of the analysis moment" /SourceData/Infrastructure/GTFS/LoadFeeds/Write
exit /b !RC!

:source_cache
REM %1 = the state in batch\log\<%1>_cache.txt, %2 = step name, %3 = the cache, %4 = its writer.
set RC=0
set SRCSTATE=
if exist "%LOGDIR%\%~1_cache.txt" set /p SRCSTATE=<"%LOGDIR%\%~1_cache.txt"
if not defined SRCSTATE (
  call :say "ABORT: no state of the %~3 in %LOGDIR%\%~1_cache.txt"
  set STEP=sources_state
  set RC=1
  exit /b 1
)
if /I "%SRCSTATE%"=="written" (
  call :say "--- sources: the %~3 exists, skipped ---"
  exit /b 0
)
call :say "=== sources: %~3 ==="
call :run %~2 %~4
exit /b !RC!

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
if /I "%SECTION%"=="cars" if not "%~3"=="1" exit /b 0
if /I "%SECTION%"=="legs" if not "%~2"=="1" exit /b 0
set /a ISTEP+=1
set "COMP=%~1"
set "CTAG=_%~1"
set "GEODMS_Overridable_RunComponent=%~1"
call :say "=== step %ISTEP% of %NSTEP%: %~1 ==="
if /I "%~1"=="Merged" (
  call :output_comp
  exit /b !RC!
)
REM With section all, a component whose output is complete skips its cache steps as well: they serve only its output.
if /I "%SECTION%"=="all" (
  call :output_state
  if not "!RC!"=="0" exit /b !RC!
  if /I "!OUTSTATE!"=="complete" (
    call :say "--- output of %COMP% is complete in !OUTDIR!, skipped with its cache steps ---"
    exit /b 0
  )
)
if "%~3"=="1" if /I not "%SECTION%"=="legs" (
  call :cars_comp
  if not "!RC!"=="0" exit /b !RC!
)
REM The legs before the output: every portion of the output reads the pre- and post-transport connections from their caches
REM (ModelParameters/Advanced/PrePostTransportDecoupled), so the base sets without a cache are written first, once.
if "%~2"=="1" if /I not "%SECTION%"=="cars" (
  call :legs_write
  if not "!RC!"=="0" exit /b !RC!
)
if /I "%SECTION%"=="all" call :output_comp
exit /b !RC!

:cars_comp
if "%MOMENTS%"=="" (
  call :run car_moments /MakeUnlinkedData/Step4_DirectCar/Moments
  if not "!RC!"=="0" exit /b !RC!
  set /p MOMENTS=<"%LOGDIR%\car_moments.txt"
)
for %%M in (%MOMENTS%) do (
  call :car_moment %%M
  if not "!RC!"=="0" exit /b !RC!
)
exit /b 0

:car_moment
REM %1 = moment. Write_Car calculates on every request, so a moment whose cache exists with the signature of the current
REM settings is skipped, as the legs and the chain blocks are; CarPerMoment/<moment>/ForBatch/CacheState writes written
REM or missing to batch\log\car_cache_<moment>.txt.
set "CARSTATE_FILE=%LOGDIR%\car_cache_%~1.txt"
if exist "%CARSTATE_FILE%" del "%CARSTATE_FILE%"
call :run car_state_%~1 %PREP%/Direct/CarPerMoment/%~1/ForBatch/CacheState
if not "!RC!"=="0" exit /b !RC!
set CARSTATE=
if exist "%CARSTATE_FILE%" set /p CARSTATE=<"%CARSTATE_FILE%"
if not defined CARSTATE (
  call :say "ABORT: no state of the car cache of %~1 in %CARSTATE_FILE%"
  set STEP=car_state_%~1
  set RC=1
  exit /b 1
)
if /I "%CARSTATE%"=="written" (
  call :say "--- direct car trip: the cache for %~1 exists with the current signature, skipped ---"
  exit /b 0
)
call :say "--- direct car trip: cache for %~1 ---"
call :run car_%~1 %PREP%/Direct/CarPerMoment/%~1/Write_Car
exit /b !RC!

:chains_shared
REM The chain cache that the public transport components share, with STEPLABEL in front of its heading. CHAINCOMP is the
REM component whose settings the step uses: the first public transport component of the variant (with -component only
REM that one), and with section all the first whose output is not complete; with section all the step is skipped when
REM there is none. The step itself carries no component, so its logs and status lines do not either.
set RC=0
set CHAINCOMP=
for /f "usebackq tokens=1-2 delims=;" %%A in ("%LOGDIR%\components.txt") do call :chains_first %%A %%B
if not defined CHAINCOMP (
  if /I "%SECTION%"=="chains" if defined ONLY call :say "--- chains: %ONLY% uses no public transport, no chain cache ---"
  if /I "%SECTION%"=="chains" if not defined ONLY call :say "--- chains: the variant has no public transport component, no chain cache ---"
  exit /b 0
)
call :say "=== %STEPLABEL%chains, the cache that the public transport components share ==="
if /I "%SECTION%"=="all" (
  set CHAINCOMP=
  for /f "usebackq tokens=1-2 delims=;" %%A in ("%LOGDIR%\components.txt") do (
    call :chains_need %%A %%B
    if not "!RC!"=="0" exit /b !RC!
  )
  set COMP=
  set CTAG=
  set OUTSTATE_OF=
  set GEODMS_Overridable_RunComponent=
)
if not defined CHAINCOMP (
  if defined ONLY call :say "--- chains: the output of %ONLY% is complete, the chain cache is skipped ---"
  if not defined ONLY call :say "--- chains: the output of every public transport component is complete, the chain cache is skipped ---"
  exit /b 0
)
call :say "--- chains: with the settings of %CHAINCOMP% ---"
set "GEODMS_Overridable_RunComponent=%CHAINCOMP%"
call :chains_write
set GEODMS_Overridable_RunComponent=
exit /b !RC!

:chains_first
REM %1 = component, %2 = 1 when it uses public transport. Sets CHAINCOMP to the first public transport component (with
REM -component only that one).
if not "%~2"=="1" exit /b 0
if defined ONLY if /I not "%~1"=="%ONLY%" exit /b 0
if not defined CHAINCOMP set "CHAINCOMP=%~1"
exit /b 0

:chains_need
REM %1 = component, %2 = 1 when it uses public transport. Sets CHAINCOMP to the first public transport component (with
REM -component only that one) whose output is not complete (output_state).
set RC=0
if not "%~2"=="1" exit /b 0
if defined ONLY if /I not "%~1"=="%ONLY%" exit /b 0
if defined CHAINCOMP exit /b 0
set "COMP=%~1"
set "CTAG=_%~1"
set "GEODMS_Overridable_RunComponent=%~1"
call :output_state
if not "!RC!"=="0" exit /b !RC!
if /I not "!OUTSTATE!"=="complete" set "CHAINCOMP=%~1"
exit /b 0

:chains_write
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
call :say "--- chains: the stop blocks that the chain cache with the current signature misses, in portions (WriteChainBlocks.ps1) ---"
set STEP=chains
powershell -NoProfile -ExecutionPolicy Bypass -File "%BATCHDIR%WriteChainBlocks.ps1" -Exe "%EXE%" -Cfg "%CFG%" -LogDir "%LOGDIR%" -Status "%STATUS%"
set RC=!ERRORLEVEL!
exit /b !RC!

:legs_write
REM Writes the caches of the base sets of pre- and post-transport of the component that have none with the current
REM signature (PublicTransport_Prep/Write_PrePostTransport); nothing without ModelParameters/Advanced/PrePostTransportDecoupled.
call :say "--- legs: the caches of the base sets without one (parquet in IntermediateResults) ---"
call :run legs %PREP%/Write_PrePostTransport
exit /b !RC!

:output_state
REM The output folder of the component (NetworkSetup/GenerateOutput/OutputDir_ForBatch, written to batch\log\output_dir.txt),
REM the check of the longest path (Output_Sig/PathGate), and whether the output is complete (IsComplete, written to
REM batch\log\output_complete.txt), in OUTDIR and OUTSTATE; OUTSTATE_OF names the component they belong to. The signature
REM follows from the settings alone, so this step needs no cache.
set OUTDIR=
set OUTSTATE=
set OUTSTATE_OF=
for %%F in (output_dir.txt output_complete.txt) do if exist "%LOGDIR%\%%F" del "%LOGDIR%\%%F"
call :run output_dir /NetworkSetup/GenerateOutput/OutputDir_ForBatch /NetworkSetup/GenerateOutput/Output_Sig/PathGate /NetworkSetup/GenerateOutput/ForBatch/IsComplete
if not "!RC!"=="0" exit /b !RC!
set /p OUTDIR=<"%LOGDIR%\output_dir.txt"
if not defined OUTDIR (
  call :say "ABORT: no output folder in %LOGDIR%\output_dir.txt"
  set STEP=output_dir
  set RC=1
  exit /b 1
)
set /p OUTSTATE=<"%LOGDIR%\output_complete.txt"
set "OUTSTATE_OF=%COMP%"
exit /b 0

:output_comp
REM The state of the output, unless the component step determined it already.
if /I not "!OUTSTATE_OF!"=="%COMP%" (
  call :output_state
  if not "!RC!"=="0" exit /b !RC!
)
if /I "!OUTSTATE!"=="complete" (
  call :say "--- output of %COMP% is complete in !OUTDIR!, skipped ---"
  exit /b 0
)
REM Empty the output folder (NetworkModel_PBL#118): the file names carry only the moment and the block, and the folder name
REM only the hash of the signature (#145), so without emptying a run would put its blocks next to those of an earlier run
REM with the same signature: one that was stopped, or one before a code change that left the signature as it was. Only the files the model writes there are removed, and only if the folder lies under a folder
REM Output. Does the path contain \Output\, or \Output_ of an OD pair (Output_<O>_<D>, #129)? Replacing it by nothing then
REM makes the string shorter; cmd replaces case-insensitively. An empty OUTDIR is refused first: the replacement in an undefined
REM variable yields the text of the replacement itself, and "\" would be the root of the drive. Each matching file is removed on
REM its own, because del with several patterns removes nothing as soon as one of them matches no file.
set OUTOK=
if defined OUTDIR if not "!OUTDIR:\Output\=!"=="!OUTDIR!" set OUTOK=1
if defined OUTDIR if not "!OUTDIR:\Output_=!"=="!OUTDIR!" set OUTOK=1
if not defined OUTOK (
  call :say "ABORT: the output folder !OUTDIR! is not under a folder Output or Output_O_D of an OD pair"
  set STEP=output_dir
  set RC=1
  exit /b 1
)
if exist "!OUTDIR!\" (
  call :say "emptying the output folder: !OUTDIR!"
  for %%F in ("!OUTDIR!\PerBlock\tt_*.csv" "!OUTDIR!\PerBlock\tt_*.xml" "!OUTDIR!\Mediaan\tt_*.csv" "!OUTDIR!\Mediaan\tt_*.xml" "!OUTDIR!\tt_*.csv" "!OUTDIR!\tt_*.xml" "!OUTDIR!\signature.txt" "!OUTDIR!\signature.xml" "!OUTDIR!\od_tellingen.*" "!OUTDIR!\unieke_od_tellingen.*" "!OUTDIR!\PerBlock\tt_*.parquet" "!OUTDIR!\Mediaan\tt_*.parquet" "!OUTDIR!\Tellingen\tellingen_*.*") do del /q "%%~fF"
  if exist "!OUTDIR!\signature.txt" (
    call :say "ABORT: the output folder !OUTDIR! could not be emptied, a file in it may be open in another program"
    set STEP=output_dir
    set RC=1
    exit /b 1
  )
)
REM The output runs in portions of origin blocks, each in its own GeoDmsRun, followed by the counts of all blocks in one more
REM GeoDmsRun (WriteOutputBlocks.ps1). Blocks per portion: Classifications/Components/BlocksPerPortion of the component,
REM or the environment variable OUTPUT_BATCHSIZE; OUTPUT_MAXBLOCKS calculates at most that many blocks (for testing).
REM The merge (Merged) also runs per block in portions (ComponentMerge/PerBlock).
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
if defined COMP call :say "%WHAT% FAILED at step %STEP% of %COMP% (exit %RC%)"
if not defined COMP call :say "%WHAT% FAILED at step %STEP% (exit %RC%)"
if defined PAUSE_END pause
exit /b 1

:done
call :say "%WHAT% done"
if defined PAUSE_END pause
exit /b 0
