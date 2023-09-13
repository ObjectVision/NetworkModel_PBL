set geodmsversion=GeoDms7411
set exe_dir=C:\Program Files\ObjectVision\%geodmsversion%
set ProgramPath=%exe_dir%\GeoDmsRun.exe

cd ..\cfg

CHOICE /M "Wil je eerder gemaakte ontkoppelde OSM data hergebruiken en dus draaien van maak OSM-data overslaan?"
if ErrorLevel 2 goto runPrepareData
CHOICE /M "Wil je eerder gemaakte ontkoppelde congestion data hergebruiken en dus draaien van het congestions speed netwerk overslaan? Dit is de stap die zoveel tijd kost."
if ErrorLevel 2 goto runCongestionData
GOTO runDayGroups

:runPrepareData
"%ProgramPath%" main.dms /MaakOntkoppeldeData/OSM/Step1_Generate_roads_shp2fss REM ruwe OSM naar fss
REM call ..\batch\RunPrepare.cmd MonTue                                            REM maak finale OSM netwerk per dag groep
call ..\batch\RunPrepare.cmd WedThuFri 
REM call ..\batch\RunPrepare.cmd SatSun 

:runCongestionData
REM call ..\batch\RunCongestionSpeeds.cmd MonTue 
call ..\batch\RunCongestionSpeeds.cmd WedThuFri 
call ..\batch\RunCongestionSpeeds.cmd SatSun 

:runDayGroups
REM call ..\batch\RunDayGroups.cmd MonTue 
REM call ..\batch\RunDayGroups.cmd WedThuFri 
REM call ..\batch\RunDayGroups.cmd SatSun 

pause "Klaar ?"