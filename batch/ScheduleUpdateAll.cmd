@echo off
REM ---------------------------------------------------------------------------------------------
REM ScheduleUpdateAll.cmd <section> [arguments]: starts batch\UpdateAll.cmd with those arguments as the one-off
REM scheduled task NM_PBL_UpdateAll, in a visible console window of the logged-on user, and returns at once.
REM This way a run of hours survives closing the window or the session it was started from.
REM The task runs batch\UpdateAllTask.cmd, which writes the progress to batch\log\UpdateAll_status.txt and deletes the
REM task afterwards. At most one such task runs at a time.
REM
REM   ScheduleUpdateAll.cmd cars                     the four car stores
REM   ScheduleUpdateAll.cmd all -nosources           the car stores, the chain store, the pre- and post-transport stores and the output
REM   set GEODMS_EXE=C:\...\GeoDmsRun.exe            beforehand: another engine for this run
REM ---------------------------------------------------------------------------------------------
setlocal
set TASK=NM_PBL_UpdateAll
if "%~1"=="" (
  echo Usage: ScheduleUpdateAll.cmd ^<section^> [arguments], see UpdateAll.cmd for the sections.
  exit /b 1
)
schtasks /Query /TN %TASK% >nul 2>&1
if not errorlevel 1 (
  echo The task %TASK% already exists: an UpdateAll run is still going, or an earlier one was aborted.
  echo See %~dp0log\UpdateAll_status.txt; delete it with: schtasks /Delete /TN %TASK% /F
  exit /b 1
)
tasklist /FI "IMAGENAME eq GeoDmsRun.exe" | find /I "GeoDmsRun.exe" >nul
if not errorlevel 1 echo Note: a GeoDmsRun is already running; the two runs share memory and processor.
if not exist "%~dp0log" mkdir "%~dp0log"
set LAUNCH=%~dp0log\UpdateAll_task_launch.cmd
> "%LAUNCH%" echo @echo off
if defined GEODMS_EXE (>> "%LAUNCH%" echo set "GEODMS_EXE=%GEODMS_EXE%")
>> "%LAUNCH%" echo call "%~dp0UpdateAllTask.cmd" %*
REM /SC ONCE without /SD at 00:00 lies in the past, so the trigger never fires by itself; /Run starts the task now.
schtasks /Create /TN %TASK% /TR "cmd.exe /c \"%LAUNCH%\"" /SC ONCE /ST 00:00 /F >nul 2>&1
if errorlevel 1 (
  echo Creating the task %TASK% failed.
  exit /b 1
)
schtasks /Run /TN %TASK% >nul
if errorlevel 1 (
  echo Starting the task %TASK% failed.
  exit /b 1
)
echo Task %TASK% started: UpdateAll %*
echo Progress in %~dp0log\UpdateAll_status.txt, logs per step in %~dp0log\UpdateAll_^<step^>.log and .txt
exit /b 0
