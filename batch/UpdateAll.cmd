@echo off
setlocal EnableDelayedExpansion
REM ---------------------------------------------------------------------------------------------
REM UpdateAll.cmd: werkt de stores van NetworkModel_PBL bij met GeoDmsRun, in de volgorde waarin
REM ze elkaar nodig hebben. Elke stap is een eigen GeoDmsRun-aanroep, zodat het geheugen tussen
REM de stappen vrijkomt, en stopt bij een fout. Logs in batch\log\UpdateAll_<stap>.log.
REM
REM   UpdateAll.cmd                 alle secties (bronnen, autoritten, ketens); reken op een nacht
REM   UpdateAll.cmd all -nosources  alles behalve de genoemde secties: -nosources, -nocars, -nochains
REM   UpdateAll.cmd sources         OSM-netwerk, TomTom-stores, GTFS-store, LISA (alleen bij een
REM                                 nieuwe editie nodig; ca. 15 min)
REM   UpdateAll.cmd cars [moment..] de stores van de directe autorit per congestiemoment
REM                                 (PublicTransport_Prep/Direct/CarPerMoment/<moment>/Write_Car);
REM                                 zonder momenten alle vier: MorningRush NoonRush LateEveningRush
REM                                 en Freeflow (TomTom) of MaxSpeed (OSM); 40 min scalair per
REM                                 moment, langer met ParetoLegs_Car
REM   UpdateAll.cmd chains          de OV-ketenstore (PublicTransport_Prep/x/Write_Result), na de
REM                                 voorcheck op haltenblokken en prijsdekking; uren, veel geheugen
REM
REM De oude RunAll.cmd, RunKetens*.cmd, RunPrepare.cmd, RunDayGroups.cmd en RunCongestionSpeeds.cmd
REM wezen naar itempaden van voor 2025 en zijn op 2026-09-23 verwijderd.
REM ---------------------------------------------------------------------------------------------
REM Engine: sinds 2026-09-23 de lokale msbuild-build 20.21.x in C:\dev\GeoDMS_2026\bin\Release\x64, want het model
REM gebruikt de pareto-epsilon van GeoDMS #1282 (impedance_matrix_od64 met pareto(imp2_epsilon), pareto_optimal_eps);
REM de geinstalleerde 20.20.0.m kent die niet en rekent dan met kwantisatie per link.
set EXE=C:\dev\GeoDMS_2026\bin\Release\x64\GeoDmsRun.exe
REM Met de omgevingsvariabele GEODMS_EXE draait een andere GeoDmsRun.exe, bijvoorbeeld een proefbuild.
if defined GEODMS_EXE set "EXE=%GEODMS_EXE%"
REM De volledige padnaam zonder "..": GeoDMS leidt %LocalDataProjDir% af uit de naam van de map boven cfg, en
REM met batch\..\cfg\main.dms werd dat "..", zodat de stores in c:\LocalData\..\IntermediateResults (= C:\) kwamen.
for %%I in ("%~dp0..\cfg\main.dms") do set CFG=%%~fI
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
:args
shift
if "%~1"=="" goto argsdone
if /I "%~1"=="-nosources" (set SKIP_SOURCES=1) else if /I "%~1"=="-nocars" (set SKIP_CARS=1) else if /I "%~1"=="-nochains" (set SKIP_CHAINS=1) else set MOMENTS=!MOMENTS! %~1
goto args
:argsdone

echo UpdateAll %SECTION%%MOMENTS% gestart %DATE% %TIME%

if /I "%SECTION%"=="all"     goto sources
if /I "%SECTION%"=="sources" goto sources
if /I "%SECTION%"=="cars"    goto cars
if /I "%SECTION%"=="chains"  goto chains
echo Onbekende sectie "%SECTION%": kies all, sources, cars of chains.
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
if "%SKIP_CHAINS%"=="1" goto done
echo === ketens: voorcheck haltenblokken en prijsdekking ===
call :run chains_precheck /ChecksBeforeRunning/PT_CheckBlocks /SourceData/Infrastructure/OVprijzen/PrijsDekking/Tabel_OK_DOVA
if not "!RC!"=="0" goto failed
findstr /R "^Minimum.1" "%LOGDIR%\UpdateAll_chains_precheck.txt" >nul
if errorlevel 1 (
  echo ABORT: de prijsdekking is niet OK, zie %LOGDIR%\UpdateAll_chains_precheck.txt
  goto failed
)
echo === ketens: Write_Result (uren) ===
call :run chains %PREP%/x/Write_Result
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
