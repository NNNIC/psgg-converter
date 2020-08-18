@echo off
set CS2HX=cs2hx\bin\debug\cs2hx.exe
cd /d %~dp0
echo :
echo : convert
echo :
rd /s /q hx 2>nul 
"%CS2HX%" /sln:..\psggConverter\psggConverter.sln /projects:psggConverterLib  /out:hx
cmd /k