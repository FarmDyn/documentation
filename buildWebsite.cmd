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

echo The documentation website is build from the Markdown files 
echo and copied to the agpserv2 server once completed.

\\agpserv7\agpo\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\bin\python.exe -m mkdocs build


@REM go to website directory
pushd \\agpserv2\ilrweb\em\rsrch\farmdyn\FarmDynDoku

echo Cleaning website directory
@REM remove all existing files
del *.*

echo Copying new files to website directory
@REM copy everything from the docs site directory to the website
xcopy "\\agpserv7\agpo\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn\site" "\\agpserv2\ilrweb\em\rsrch\farmdyn\FarmDynDoku" /s/h/e/k/f/c