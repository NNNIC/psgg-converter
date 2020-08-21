@echo off
set CS2HX=cs2hx\bin\debug\cs2hx.exe
cd /d %~dp0
echo :
echo : convert
echo :
rd /s /q src\hx 2>nul
"%CS2HX%" /sln:..\psggConverter\psggConverter.sln /projects:psggConverterLib  /out:src\hx /extraTranslation:Translations.xml
::"%CS2HX%" /sln:..\psggConverter\psggConverter.sln /projects:psggConverterLib  /out:src\hx
cmd /k