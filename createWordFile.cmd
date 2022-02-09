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

echo Create a Word file from the documentation

@REM copy all media to media folder in top level dir
xcopy "\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\docs\media" "\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\media" /s/h/e/k/f/c/I
xcopy "\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\docs\media" "\\agpserv6\em\work1\Pahmeyer\FarmDyn\media" /s/h/e/k/f/c/I

SET SECTIONS_FILEPATH=\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\print\tableOfContents.txt
REM Remove all newlines in SECTIONS
setlocal enabledelayedexpansion
set SECTIONS=
for /f %%i In (%SECTIONS_FILEPATH%) DO set SECTIONS=!SECTIONS! %%i


\\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\bin\Scripts\pandoc.exe --toc %sections% -o \\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\print\FarmDyn_Documentation2.docx

@REM media directory
@REM rmdir \\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\media /s /q
@REM rmdir \\agpserv6\em\work1\Pahmeyer\FarmDyn\FarmDynDoku\media /s /q
pause
