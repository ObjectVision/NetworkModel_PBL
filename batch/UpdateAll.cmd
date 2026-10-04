@echo off
setlocal EnableDelayedExpansion
REM ---------------------------------------------------------------------------------------------
REM UpdateAll.cmd: werkt de stores van NetworkModel_PBL bij met GeoDmsRun, in de volgorde waarin
REM ze elkaar nodig hebben. Elke stap is een eigen GeoDmsRun-aanroep, zodat het geheugen tussen
REM de stappen vrijkomt, en stopt bij een fout. Logs in batch\log\UpdateAll_<stap>.log.
REM
REM   UpdateAll.cmd                 alle secties (bronnen, autoritten, ketens, uitvoer); reken op meer dan een nacht
REM   UpdateAll.cmd all -nosources  alles behalve de genoemde secties: -nosources, -nocars, -nochains, -nooutput
REM   UpdateAll.cmd sources         OSM-netwerk, TomTom-stores, GTFS-store, LISA (alleen bij een
REM                                 nieuwe editie nodig; ca. 15 min)
REM   UpdateAll.cmd cars [moment..] de stores van de directe autorit per congestiemoment
REM                                 (PublicTransport_Prep/Direct/CarPerMoment/<moment>/Write_Car);
REM                                 zonder momenten alle vier: MorningRush NoonRush LateEveningRush
REM                                 en Freeflow (TomTom) of MaxSpeed (OSM); 40 min scalair per
REM                                 moment, langer met ParetoLegs_Car
REM   UpdateAll.cmd chains          de OV-ketenstore per haltenblok (WriteChainBlocks.ps1; met de omgevingsvariabele
REM                                 CHAINSTORE_SINGLE de ene store van PublicTransport_Prep/x/Write_Result), na de
REM                                 voorcheck op haltenblokken en prijsdekking; uren, veel geheugen
REM   UpdateAll.cmd output          de OV-uitvoer: een csv per herkomstblok en vertrekmoment in
REM                                 %LocalDataProjDir%\Output\<Analysis_date>_<OutputLabel>\PerBlock
REM                                 (ConfigurationPerBlock/Generate_Output), met de ketenstore van de vertrekmomenten in
REM                                 PT_DepartureHours/Minutes. Maakt die map eerst leeg (sinds 2026-10-03, #118): alleen de
REM                                 bestanden van het model (tt_*.csv, tt_*.xml, signature.txt/.xml), ook de samengevoegde,
REM                                 en sinds 2026-10-04 de tellingen od_tellingen.csv en unieke_od_tellingen.csv (met .xml),
REM                                 die de uitvoerstap in dezelfde opvraging maakt.
REM
REM De oude RunAll.cmd, RunKetens*.cmd, RunPrepare.cmd, RunDayGroups.cmd en RunCongestionSpeeds.cmd
REM wezen naar itempaden van voor 2025 en zijn op 2026-09-23 verwijderd.
REM ---------------------------------------------------------------------------------------------
REM Engine: sinds 2026-09-23 de lokale msbuild-build 20.21.x in C:\dev\GeoDMS_2026\bin\Release\x64, want het model
REM gebruikt de pareto-epsilon van GeoDMS #1282 (impedance_matrix_od64 met pareto(imp2_epsilon), pareto_optimal_eps);
REM de geinstalleerde 20.20.0.m kent die niet en rekent dan met kwantisatie per link.
REM Sinds 2026-10-01 vraagt de eindafweging met MinimiseCriteria 'Car' en 'Bike' (#117) bool-criteria in pareto_optimal_eps
REM (GeoDMS #1287, vanaf commit e04ad20f0; een eerdere 20.22.1 geeft 'Cannot find operator'). Lange runs gebruiken een kopie
REM van de build in C:\LocalData\GeoDMS_engine via GEODMS_EXE, nu 20.22.1_e04ad20f0.
set EXE=C:\dev\GeoDMS_2026\bin\Release\x64\GeoDmsRun.exe
REM Met de omgevingsvariabele GEODMS_EXE draait een andere GeoDmsRun.exe, bijvoorbeeld een proefbuild.
if defined GEODMS_EXE set "EXE=%GEODMS_EXE%"
REM De volledige padnaam zonder "..": GeoDMS leidt %LocalDataProjDir% af uit de naam van de map boven cfg, en
REM met batch\..\cfg\main.dms werd dat "..", zodat de stores in c:\LocalData\..\IntermediateResults (= C:\) kwamen.
for %%I in ("%~dp0..\cfg\main.dms") do set CFG=%%~fI
REM De batchmap vastleggen voor het argumentenlusje: na shift wijst %~dp0 niet meer naar deze map.
set "BATCHDIR=%~dp0"
set LOGDIR=%~dp0log
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set PREP=/NetworkSetup/PublicTransport_Prep

set SECTION=%~1
if "%SECTION%"=="" set SECTION=all
REM De argumenten na de sectie: -no<sectie> slaat een sectie over, de rest zijn momenten voor cars.
REM (shift laat %* ongemoeid, dus zelf verzamelen.)
set MOMENTS=
set SKIP_SOURCES=0
set SKIP_CARS=0
set SKIP_CHAINS=0
set SKIP_OUTPUT=0
:args
shift
if "%~1"=="" goto argsdone
if /I "%~1"=="-nosources" (set SKIP_SOURCES=1) else if /I "%~1"=="-nocars" (set SKIP_CARS=1) else if /I "%~1"=="-nochains" (set SKIP_CHAINS=1) else if /I "%~1"=="-nooutput" (set SKIP_OUTPUT=1) else set MOMENTS=!MOMENTS! %~1
goto args
:argsdone

echo UpdateAll %SECTION%%MOMENTS% gestart %DATE% %TIME%

if /I "%SECTION%"=="all"     goto sources
if /I "%SECTION%"=="sources" goto sources
if /I "%SECTION%"=="cars"    goto cars
if /I "%SECTION%"=="chains"  goto chains
if /I "%SECTION%"=="output"  goto output
echo Onbekende sectie "%SECTION%": kies all, sources, cars, chains of output.
exit /b 1

:sources
if "%SKIP_SOURCES%"=="1" goto sources_done
echo === bronnen: OSM-netwerkstore ===
call :run osm_network /SourceData/Infrastructure/OSM/Make_Final_Network
if not "!RC!"=="0" goto failed
echo === bronnen: TomTom-stores (wegen, knopen, speedprofile-net, speedprofiles) ===
call :run tomtom_roads         /SourceData/Infrastructure/TomTom/Impl/Merge_Roads
if not "!RC!"=="0" goto failed
call :run tomtom_junctions     /SourceData/Infrastructure/TomTom/Impl/Merge_Junctions
if not "!RC!"=="0" goto failed
call :run tomtom_speednetworks /SourceData/Infrastructure/TomTom/Impl/Merge_Speednetworks
if not "!RC!"=="0" goto failed
call :run tomtom_speedprofiles /SourceData/Infrastructure/TomTom/Impl/Merge_Speedprofiles
if not "!RC!"=="0" goto failed
echo === bronnen: GTFS-store van de feed GTFS_file_date ===
call :run gtfs /SourceData/Infrastructure/GTFS/LoadFeeds/Write
if not "!RC!"=="0" goto failed
echo === bronnen: LISA-mmd naast de fss (jaar LISA_year, hier y2018) ===
call :run lisa /SourceData/Locaties/LISA/ReadFSS/y2018/Make_PerYear_mmd
if not "!RC!"=="0" goto failed
:sources_done
if /I not "%SECTION%"=="all" goto done

:cars
if "%SKIP_CARS%"=="1" goto cars_done
if "%MOMENTS%"=="" set MOMENTS=MorningRush NoonRush LateEveningRush Freeflow
for %%M in (%MOMENTS%) do (
  echo === directe autorit: store voor %%M ===
  call :run car_%%M %PREP%/Direct/CarPerMoment/%%M/Write_Car
  if not "!RC!"=="0" goto failed
)
:cars_done
if /I not "%SECTION%"=="all" goto done

:chains
if "%SKIP_CHAINS%"=="1" goto chains_done
echo === ketens: voorcheck haltenblokken en prijsdekking ===
call :run chains_precheck /ChecksBeforeRunning/PT_CheckBlocks /SourceData/Infrastructure/OVprijzen/PrijsDekking/Tabel_OK_DOVA
if not "!RC!"=="0" goto failed
findstr /R "^Minimum.1" "%LOGDIR%\UpdateAll_chains_precheck.txt" >nul
if errorlevel 1 (
  echo ABORT: de prijsdekking is niet OK, zie %LOGDIR%\UpdateAll_chains_precheck.txt
  goto failed
)
if defined CHAINSTORE_SINGLE goto chains_single
echo === ketens: de haltenblokken zonder store, in porties (WriteChainBlocks.ps1) ===
set STEP=chains
powershell -NoProfile -ExecutionPolicy Bypass -File "%BATCHDIR%WriteChainBlocks.ps1" -Exe "%EXE%" -Cfg "%CFG%" -LogDir "%LOGDIR%"
set RC=!ERRORLEVEL!
if not "!RC!"=="0" goto failed
goto chains_done
:chains_single
echo === ketens: Write_Result, de ene store van voor 2026-09-29 (CHAINSTORE_SINGLE; zet ook ChainStore_PerBlock op FALSE) ===
call :run chains %PREP%/x/Write_Result
if not "!RC!"=="0" goto failed
:chains_done
if /I not "%SECTION%"=="all" goto done

:output
if "%SKIP_OUTPUT%"=="1" goto done
REM Pauze voor de uitvoerstap (sinds 2026-09-29): zolang batch\pause_before_output.flag bestaat, wacht de uitvoerstap
REM zonder rekenproces, bijvoorbeeld om de machine vrij te geven voor prestatietests; weghalen van de vlag laat hem starten.
set "PAUSEFLAG=%BATCHDIR%pause_before_output.flag"
if not exist "%PAUSEFLAG%" goto output_go
echo %DATE% %TIME% pauze voor de uitvoerstap: wacht tot %PAUSEFLAG% weg is
:output_wait
ping -n 61 127.0.0.1 >nul
if exist "%PAUSEFLAG%" goto output_wait
echo %DATE% %TIME% pauze voorbij, de uitvoerstap start
:output_go
REM De uitvoermap leegmaken (sinds 2026-10-03, NetworkModel_PBL#118): de bestandsnamen dragen alleen datum, moment en blok, de
REM parameters staan in signature.txt in de map. Zonder leegmaken zou een run na een codewijziging zijn blokken naast die van de
REM vorige run zetten. Het model geeft de map (NetworkSetup/OutputDir_ForBatch, naar batch\log\output_dir.txt); alleen de
REM bestanden die het model daar schrijft gaan weg, en alleen als de map onder een map Output ligt. Output_Sig/PathGate faalt
REM vooraf als het langste uitvoerpad te lang is.
call :run output_dir /NetworkSetup/OutputDir_ForBatch /NetworkSetup/Output_Sig/PathGate
if not "!RC!"=="0" goto failed
set OUTDIR=
set /p OUTDIR=<"%LOGDIR%\output_dir.txt"
if not defined OUTDIR (
  echo ABORT: geen uitvoermap in %LOGDIR%\output_dir.txt
  set STEP=output_dir
  goto failed
)
REM Bevat het pad \Output\? (vervangen door niets laat het dan korter; cmd vervangt hoofdletterongevoelig)
if "!OUTDIR:\Output\=!"=="!OUTDIR!" (
  echo ABORT: de uitvoermap !OUTDIR! ligt niet onder een map Output
  set STEP=output_dir
  goto failed
)
if exist "!OUTDIR!\" (
  echo %DATE% %TIME% uitvoermap leegmaken: !OUTDIR!
  del /q "!OUTDIR!\PerBlock\tt_*.csv" "!OUTDIR!\PerBlock\tt_*.xml" "!OUTDIR!\tt_*.csv" "!OUTDIR!\tt_*.xml" "!OUTDIR!\signature.txt" "!OUTDIR!\signature.xml" "!OUTDIR!\od_tellingen.*" "!OUTDIR!\unieke_od_tellingen.*" 2>nul
)
echo === uitvoer: csv per herkomstblok en vertrekmoment (uren) ===
call :run output /NetworkSetup/ConfigurationPerBlock/Generate_Output/OUTPUT_Generate_PublicTransport_fullOD_long_CSVFiles
if not "!RC!"=="0" goto failed
goto done

:run
REM %1 = stapnaam, %2.. = items; elke GeoDmsRun-aanroep vraagt de items op via @statistics, wat
REM voor een store-holder de hele store schrijft. RC houdt de exitcode (ook negatief, bij een
REM afgebroken proces; "if errorlevel 1" ziet die niet).
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
echo UpdateAll %SECTION% MISLUKT bij stap %STEP% (exit %RC%) %DATE% %TIME%
exit /b 1

:done
echo UpdateAll %SECTION% klaar %DATE% %TIME%
exit /b 0
