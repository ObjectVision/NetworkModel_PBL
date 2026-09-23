@echo off
setlocal EnableDelayedExpansion
REM ---------------------------------------------------------------------------------------------
REM UpdateAll.cmd: werkt de stores van NetworkModel_PBL bij met GeoDmsRun, in de volgorde waarin
REM ze elkaar nodig hebben. Elke stap is een eigen GeoDmsRun-aanroep, zodat het geheugen tussen
REM de stappen vrijkomt, en stopt bij een fout. Logs in batch\log\UpdateAll_<stap>.log.
REM
REM   UpdateAll.cmd                 alle secties (bronnen, autoritten, ketens); reken op een nacht
REM   UpdateAll.cmd sources         OSM-netwerk, TomTom-stores, GTFS-store, LISA (alleen bij een
REM                                 nieuwe editie nodig; ca. 15 min)
REM   UpdateAll.cmd cars [moment..] de stores van de directe autorit per congestiemoment
REM                                 (PublicTransport_Prep/Direct/CarPerMoment/<moment>/Write_Car);
REM                                 zonder momenten alle vier: MorningRush NoonRush LateEveningRush
REM                                 en Freeflow (TomTom) of MaxSpeed (OSM); 40 min scalair per
REM                                 moment, langer met ParetoLegs_Car
REM   UpdateAll.cmd chains          de OV-ketenstore (PublicTransport_Prep/Write_Result), na de
REM                                 voorcheck op haltenblokken en prijsdekking; uren, veel geheugen
REM
REM De oude RunAll.cmd en RunKetens*.cmd wijzen naar itempaden van voor 2025 en werken niet meer.
REM ---------------------------------------------------------------------------------------------
set geodmsversion=GeoDms20.20.0.m
set EXE=C:\Program Files\ObjectVision\%geodmsversion%\GeoDmsRun.exe
set CFG=%~dp0..\cfg\main.dms
set LOGDIR=%~dp0log
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set PREP=/NetworkSetup/PublicTransport_Prep

set SECTION=%~1
if "%SECTION%"=="" set SECTION=all
REM De momenten na de sectie (shift laat %* ongemoeid, dus zelf verzamelen).
set MOMENTS=
:momargs
shift
if "%~1"=="" goto momdone
set MOMENTS=%MOMENTS% %~1
goto momargs
:momdone

echo UpdateAll %SECTION% gestart %DATE% %TIME%

if /I "%SECTION%"=="all"     goto sources
if /I "%SECTION%"=="sources" goto sources
if /I "%SECTION%"=="cars"    goto cars
if /I "%SECTION%"=="chains"  goto chains
echo Onbekende sectie "%SECTION%": kies all, sources, cars of chains.
exit /b 1

:sources
echo === bronnen: OSM-netwerkstore ===
call :run osm_network /SourceData/Infrastructure/OSM/Make_Final_Network
if errorlevel 1 goto failed
echo === bronnen: TomTom-stores (wegen, knopen, speedprofile-net, speedprofiles) ===
call :run tomtom_roads         /SourceData/Infrastructure/TomTom/Impl/Merge_Roads
if errorlevel 1 goto failed
call :run tomtom_junctions     /SourceData/Infrastructure/TomTom/Impl/Merge_Junctions
if errorlevel 1 goto failed
call :run tomtom_speednetworks /SourceData/Infrastructure/TomTom/Impl/Merge_Speednetworks
if errorlevel 1 goto failed
call :run tomtom_speedprofiles /SourceData/Infrastructure/TomTom/Impl/Merge_Speedprofiles
if errorlevel 1 goto failed
echo === bronnen: GTFS-store van de feed GTFS_file_date ===
call :run gtfs /SourceData/Infrastructure/GTFS/LoadFeeds/Write
if errorlevel 1 goto failed
echo === bronnen: LISA-mmd naast de fss (jaar LISA_year, hier y2018) ===
call :run lisa /SourceData/Locaties/LISA/ReadFSS/y2018/Make_PerYear_mmd
if errorlevel 1 goto failed
if /I not "%SECTION%"=="all" goto done

:cars
if "%MOMENTS%"=="" set MOMENTS=MorningRush NoonRush LateEveningRush Freeflow
if /I "%SECTION%"=="all" set MOMENTS=MorningRush NoonRush LateEveningRush Freeflow
for %%M in (%MOMENTS%) do (
  echo === directe autorit: store voor %%M ===
  call :run car_%%M %PREP%/Direct/CarPerMoment/%%M/Write_Car
  if errorlevel 1 goto failed
)
if /I not "%SECTION%"=="all" goto done

:chains
echo === ketens: voorcheck haltenblokken en prijsdekking ===
call :run chains_precheck /ChecksBeforeRunning/PT_CheckBlocks /SourceData/Infrastructure/OVprijzen/PrijsDekking/Tabel_OK_DOVA
if errorlevel 1 goto failed
findstr /R "^Minimum.1" "%LOGDIR%\UpdateAll_chains_precheck.txt" >nul
if errorlevel 1 (
  echo ABORT: de prijsdekking is niet OK, zie %LOGDIR%\UpdateAll_chains_precheck.txt
  goto failed
)
echo === ketens: Write_Result (uren) ===
call :run chains %PREP%/Write_Result
if errorlevel 1 goto failed
goto done

:run
REM %1 = stapnaam, %2.. = items; elke GeoDmsRun-aanroep vraagt de items op via @statistics, wat
REM voor een store-holder de hele store schrijft.
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
echo UpdateAll %SECTION% MISLUKT bij stap %STEP% %DATE% %TIME%
exit /b 1

:done
echo UpdateAll %SECTION% klaar %DATE% %TIME%
exit /b 0
