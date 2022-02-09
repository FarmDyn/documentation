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

echo Create a PDF file from the documentation

@REM copy all media to media folder in top level dir
@REM mkdir \\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\media
@REM xcopy "\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\docs\media" "\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\media" /s/h/e/k/f/c/I
@REM xcopy "\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\docs\media" "\\agpserv6\em\work1\Pahmeyer\FarmDyn\media" /s/h/e/k/f/c/I


SET SECTIONS_FILEPATH=print/tableOfContents.txt
REM Remove all newlines in SECTIONS
setlocal enabledelayedexpansion
set SECTIONS=
for /f %%i In (%SECTIONS_FILEPATH%) DO set SECTIONS=!SECTIONS! %%i

.\bin\Scripts\pandoc.exe -f markdown-raw_tex --listings --toc %sections% -o print/FarmDyn_Documentation.pdf -H print/gams.tex

@REM media directory
@REM rmdir \\agpserv7\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\media /s /q
@REM rmdir \\agpserv7\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\media /s /q
pause
