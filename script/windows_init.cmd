@echo off

set ROOT=%~dp0
set STATUS=%ROOT%/status
set REQU=%ROOT%/requirements.txt
set CODE=%ROOT%/../

IF EXIST %STATUS% (
  type %STATUS%
  echo "�ѳ�ʼ����ϣ�"
  goto last
)

pip install -r %REQU%
if ERRORLEVEL 1 (
   echo "��������ʧ�ܣ�����pip�Ƿ���ȷ��װ��"
   goto last
)

set path_=%Path%
setx /M "Path" "%path_%;%CODE%"
if ERRORLEVEL 1 (
   echo "·������ʧ�ܣ����ֶ���������·����ϵͳ��������Path�С�"
   echo %path_%
   goto last
)

set dt="%date% %time%"
echo %dt% && echo %dt% > %STATUS%
echo "��ʼ���ɹ��������µ�����ڣ�ִ��code -h����ȷ�ϡ�"
pause
exit

:last 
echo ""
