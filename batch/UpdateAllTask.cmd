@echo off
REM ---------------------------------------------------------------------------------------------
REM UpdateAllTask.cmd <section> [arguments]: runs UpdateAll.cmd in this window, writes the progress to
REM batch\log\UpdateAll_status.txt ("start ...", "engine ...", "updateall exit=<code> ...") and afterwards deletes
REM the scheduled task NM_PBL_UpdateAll if it exists. This is the command of the task that ScheduleUpdateAll.cmd
REM creates; it can also be started by hand. The window stays open for 60 s, so that the last lines can be read.
REM ---------------------------------------------------------------------------------------------
setlocal
set LOGDIR=%~dp0log
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set STATUS=%LOGDIR%\UpdateAll_status.txt
title UpdateAll %* - NetworkModel_PBL
echo start %* %DATE% %TIME% > "%STATUS%"
if defined GEODMS_EXE echo engine %GEODMS_EXE% >> "%STATUS%"
call "%~dp0UpdateAll.cmd" %*
set RC=%ERRORLEVEL%
echo updateall exit=%RC% %DATE% %TIME% >> "%STATUS%"
schtasks /Query /TN NM_PBL_UpdateAll >nul 2>&1
if not errorlevel 1 schtasks /Delete /TN NM_PBL_UpdateAll /F >nul 2>&1
echo === UpdateAll %* finished with exit %RC%; the window closes in 60 s ===
timeout /T 60
exit /b %RC%
