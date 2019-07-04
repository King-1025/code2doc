@echo off

set ROOT=%~dp0
set STATUS=%ROOT%/status
set REQU=%ROOT%/requirements.txt
set CODE=%ROOT%/../

IF EXIST %STATUS% (
  type %STATUS%
  goto last
)

pip install -r %REQU%

set path_=%Path%
setx /M "Path" "%path_%;%CODE%"

set dt="%date% %time%"
echo %dt% && echo %dt% > %STATUS%
echo "init ok!"
pause
exit

:last 
echo ""
