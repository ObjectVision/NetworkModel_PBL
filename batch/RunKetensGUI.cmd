REM set geodmsversion=GeoDms17.4.6
REM set exe_dir=C:\Program Files\ObjectVision\%geodmsversion%
set exe_dir=C:\Dev\GeoDMS\bin\Release\x64
set ProgramPath=%exe_dir%\GeoDmsGuiQt.exe

cd ..\cfg

"%ProgramPath%" /L../batch/log/log.txt /T../profile/NW_v2025_GUI.dmsscript main.dms /NetworkSetup/ConfigurationPerRegio/all/PublicTransport/Keten_Generatie/roo/Generate

REM pause "Klaar ?"