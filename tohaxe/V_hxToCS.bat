@echo off
cd %~dp0
rd /s /q out\cs 2>nul >nul
echo : 
echo : ��ւ̂��߁Ahx/RegexUtil, hx/SortUtil ���폜
echo :

del /f src\hx\RegexUtil.hx 2>nul
del /f src\hx\SortUtil.hx 2>nul

echo :
echo : compile
echo : 
Haxe -p src\hx_alt  -p src\cs2hx_src -p src\hx -p src\test -m Program  --cs out\cs 
echo : done
echo : 
echo : run
echo :
pause
out\cs\bin\Program.exe
pause