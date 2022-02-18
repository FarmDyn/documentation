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
set PATH=%PATH%;N:\em\work1\FarmDyn\documentation\binaries;.\bin

@REM Open the browser pointing at localhost where site will be served
start firefox http://127.0.0.1:8000/

@REM Run the MkDocs server locally
echo The documentation server will now build the documentation,
echo please wait until you read 'Serving on http:...' below and then reload the page.

python -m mkdocs serve
pause
