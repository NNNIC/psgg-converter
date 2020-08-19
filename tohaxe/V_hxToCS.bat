@echo off
cd %~dp0
del out\cs 2>nul
echo :
echo : compile
echo : 
Haxe -p src\cs2hx_src -p src\hx -p src\test -p src\sys_cs -m Program  --js out\js\Test.js 
echo : done
echo : 
echo : run
echo :
pause
start out\js\index.html
pause