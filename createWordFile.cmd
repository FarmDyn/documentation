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

SET SECTIONS_FILEPATH=print/tableOfContents.txt
REM Remove all newlines in SECTIONS
setlocal enabledelayedexpansion
set SECTIONS=
for /f %%i In (%SECTIONS_FILEPATH%) DO set SECTIONS=!SECTIONS! %%i


\\agpserv7\agpo\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\bin\Scripts\pandoc.exe --toc %sections% -o print/FarmDyn_Documentation.docx