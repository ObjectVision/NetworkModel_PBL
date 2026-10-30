@echo off
REM ---------------------------------------------------------------------------------------------
REM ScheduleUpdateAll.cmd <section> [arguments]: starts batch\UpdateAll.cmd with those arguments as the one-off
REM scheduled task NM_PBL_UpdateAll, in a visible console window of the logged-on user, and returns at once.
REM This way a run of hours or days survives closing the window or the session it was started from; the task has no
REM time limit (Windows stops a task after 72 hours by default, and a variant with cycling components can take longer).
REM The task runs batch\UpdateAllTask.cmd; it and UpdateAll.cmd write the progress per step to
REM batch\log\UpdateAll_status.txt, and the task is deleted afterwards. At most one such task runs at a time.
REM
REM   ScheduleUpdateAll.cmd all                      the whole variant: sources, checks, per component the caches and the output, the merge
REM   ScheduleUpdateAll.cmd all -nosources           the same without the OSM and GTFS caches
REM   ScheduleUpdateAll.cmd output -component Car    only the output of one component of the variant
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
REM schtasks gives the task the default limit of 72 hours (ExecutionTimeLimit PT72H); PT0S means no limit.
powershell -NoProfile -Command "$t = Get-ScheduledTask -TaskName '%TASK%'; $t.Settings.ExecutionTimeLimit = 'PT0S'; Set-ScheduledTask -InputObject $t | Out-Null"
if errorlevel 1 (
  echo Removing the time limit of the task %TASK% failed; it stops after 72 hours.
)
schtasks /Run /TN %TASK% >nul
if errorlevel 1 (
  echo Starting the task %TASK% failed.
  exit /b 1
)
echo Task %TASK% started: UpdateAll %*
echo Progress in %~dp0log\UpdateAll_status.txt, logs per step in %~dp0log\UpdateAll_^<step^>.log and .txt
exit /b 0
