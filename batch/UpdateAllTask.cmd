@echo off
REM ---------------------------------------------------------------------------------------------
REM UpdateAllTask.cmd <sectie> [argumenten]: draait UpdateAll.cmd in dit venster, schrijft het verloop naar
REM batch\log\UpdateAll_status.txt ("start ...", "engine ...", "updateall exit=<code> ...") en verwijdert na afloop
REM de geplande taak NM_PBL_UpdateAll als die bestaat. De opdracht van de taak die ScheduleUpdateAll.cmd aanmaakt;
REM ook met de hand te starten. Het venster blijft 60 s open, zodat de laatste regels te lezen zijn.
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
echo === UpdateAll %* klaar met exit %RC%; venster sluit over 60 s ===
timeout /T 60
exit /b %RC%
