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

@REM add n: bin folder to path
set PATH=%PATH%;N:\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\bin;.\bin

echo Create a PDF file from the documentation

@REM copy all media to media folder in top level dir
@REM mkdir .\media
@REM xcopy ".\docs\media" ".\media" /s/h/e/k/f/c/I

SET SECTIONS_FILEPATH=print/tableOfContents.txt
REM Remove all newlines in SECTIONS
setlocal enabledelayedexpansion
set SECTIONS=
for /f %%i In (%SECTIONS_FILEPATH%) DO set SECTIONS=!SECTIONS! %%i

pandoc -f markdown-raw_tex --listings --toc %sections% -o print/FarmDyn_Documentation.pdf -H print/gams.tex

@REM remove toplevel media directory
@REM rmdir .\media /s /q
pause