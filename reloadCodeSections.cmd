@echo off

echo[
echo[
echo   ______                   _____
echo   ^|  ____^|                 ^|  __ \
echo   ^| ^|__ __ _ _ __ _ __ ___ ^| ^|  ^| ^|_   _ _ __
echo   ^|  __/ _` ^| '__^| '_ ` _ \^| ^|  ^| ^| ^| ^| ^| '_ \
echo   ^| ^| ^| (_^| ^| ^|  ^| ^| ^| ^| ^| ^| ^|__^| ^| ^|_^| ^| ^| ^| ^|
echo   ^|_^|  \__,_^|_^|  ^|_^| ^|_^| ^|_^|_____/ \__, ^|_^| ^|_^|
echo                                    __/ ^|
echo                                   ^|___/
echo[
echo[
echo Economic Modeling of Agricultural Systems Group
echo Institute for Food and Resource Economics
echo University of Bonn
echo[
echo[

@REM get all .md files in the docs folder (and subfolders)
@REM and do the code completion on every file in the folder

@REM add n: bin folder to path
set PATH=%PATH%;N:\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\bin;.\bin

cd .\docs
for /R %%f in (*.md) do embedmd -w %%f
cd ..
pause
