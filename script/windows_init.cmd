@echo off

set ROOT=%~dp0
set STATUS=%ROOT%/status
set REQU=%ROOT%/requirements.txt
set CODE=%ROOT%/../

IF EXIST %STATUS% (
  type %STATUS%
  echo "已初始化完毕！"
  goto last
)

pip install -r %REQU%
if ERRORLEVEL 1 (
   echo "依赖配置失败！请检查pip是否正确安装。"
   goto last
)

set path_=%Path%
setx /M "Path" "%path_%;%CODE%"
if ERRORLEVEL 1 (
   echo "路径配置失败！请手动添加下面的路径到系统环境变量Path中。"
   echo %path_%
   goto last
)

set dt="%date% %time%"
echo %dt% && echo %dt% > %STATUS%
echo "初始化成功！请在新的命令窗口，执行code -h进行确认。"
pause
exit

:last 
echo ""
