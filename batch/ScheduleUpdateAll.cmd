@echo off
REM ---------------------------------------------------------------------------------------------
REM ScheduleUpdateAll.cmd <sectie> [argumenten]: start batch\UpdateAll.cmd met die argumenten als eenmalige
REM geplande taak NM_PBL_UpdateAll, in een zichtbaar consolevenster van de aangemelde gebruiker, en keert meteen
REM terug. Zo overleeft een run van uren het sluiten van het venster of de sessie waaruit hij gestart is.
REM De taak voert batch\UpdateAllTask.cmd uit, dat het verloop in batch\log\UpdateAll_status.txt schrijft en de
REM taak na afloop verwijdert. Er loopt hoogstens een zo'n taak tegelijk.
REM
REM   ScheduleUpdateAll.cmd cars                     de vier autostores
REM   ScheduleUpdateAll.cmd all -nosources           autostores, ketenstore en uitvoer
REM   set GEODMS_EXE=C:\...\GeoDmsRun.exe            vooraf: een andere engine voor deze run
REM ---------------------------------------------------------------------------------------------
setlocal
set TASK=NM_PBL_UpdateAll
if "%~1"=="" (
  echo Gebruik: ScheduleUpdateAll.cmd ^<sectie^> [argumenten], zie UpdateAll.cmd voor de secties.
  exit /b 1
)
schtasks /Query /TN %TASK% >nul 2>&1
if not errorlevel 1 (
  echo De taak %TASK% bestaat al: er loopt nog een UpdateAll-run, of een vorige is afgebroken.
  echo Zie %~dp0log\UpdateAll_status.txt; verwijderen met: schtasks /Delete /TN %TASK% /F
  exit /b 1
)
tasklist /FI "IMAGENAME eq GeoDmsRun.exe" | find /I "GeoDmsRun.exe" >nul
if not errorlevel 1 echo Let op: er draait al een GeoDmsRun; de twee runs delen geheugen en processor.
if not exist "%~dp0log" mkdir "%~dp0log"
set LAUNCH=%~dp0log\UpdateAll_task_launch.cmd
> "%LAUNCH%" echo @echo off
if defined GEODMS_EXE (>> "%LAUNCH%" echo set "GEODMS_EXE=%GEODMS_EXE%")
>> "%LAUNCH%" echo call "%~dp0UpdateAllTask.cmd" %*
REM /SC ONCE zonder /SD op 00:00 ligt in het verleden, dus de trigger vuurt nooit vanzelf; /Run start de taak nu.
schtasks /Create /TN %TASK% /TR "cmd.exe /c \"%LAUNCH%\"" /SC ONCE /ST 00:00 /F >nul 2>&1
if errorlevel 1 (
  echo Aanmaken van de taak %TASK% mislukt.
  exit /b 1
)
schtasks /Run /TN %TASK% >nul
if errorlevel 1 (
  echo Starten van de taak %TASK% mislukt.
  exit /b 1
)
echo Taak %TASK% gestart: UpdateAll %*
echo Verloop in %~dp0log\UpdateAll_status.txt, logs per stap in %~dp0log\UpdateAll_^<stap^>.log en .txt
exit /b 0
