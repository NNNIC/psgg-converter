@echo off
cd %~dp0

echo :
echo : Remove Work Foloder
set /p a="Y or [enter] ? "

if "%a%"=="Y" (
    echo :rd /s /q out\c 
    rd /s /q out\c 2>nul 
)

:_skiprd
echo : 
echo : ��ւ̂��߁Ahx/RegexUtil, hx/SortUtil ���폜
echo :

del /f src\hx\RegexUtil.hx 2>nul
del /f src\hx\SortUtil.hx 2>nul

echo :
echo : compile
echo : 
Haxe -p src\hx_alt  -p src\cs2hx_src -p src\hx -p src\test -m Program  --cpp out\c 
echo : done
echo : 
echo : run
echo :
pause
out\c\Program.exe
pause