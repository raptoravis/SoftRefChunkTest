@echo off

REM - This batch file will build the editor and game code for your Unreal Engine project.

set CURRENT_DIR=%~dp0

call :read_params %*

set UEENGINE_ROOT=E:\dev\ue4.my.git
set UEENGINE_ROOT=D:\EpicGames\UE_4.27

set UPROJECT_PATH=%CURRENT_DIR%..

set USE_AUTODETECT=1

if %USE_AUTODETECT%==1 (
for /f "delims=" %%a in ('dir %UPROJECT_PATH%\*.uproject /b') do (
 call set PROJECT_NAME=%%~na
 )
) else (
 call set PROJECT_NAME=tps
) 


if exist "%UEENGINE_ROOT%" (
	echo 
) else (
	set UEENGINE_ROOT=%UPROJECT_PATH%\..\engine
	set PROJECT_NAME=tps
)


REM set CONFIGUATION=Development+Shipping+DebugGame
set CONFIGUATION=Development

set UPROJECT_FULLNAME=%UPROJECT_PATH%\%PROJECT_NAME%

echo =======================================================================================================
echo ****** CLEAN:              %CLEAN%
echo ****** UEENGINE_ROOT:      %UEENGINE_ROOT%
echo ****** UPROJECT_PATH:      %UPROJECT_PATH%
echo ****** PROJECT_NAME:       %PROJECT_NAME%
echo ****** UPROJECT_FULLNAME:  %UPROJECT_FULLNAME%
echo ****** CONFIGUATION:       %CONFIGUATION%
echo =======================================================================================================

goto :NextStep

:read_params
if not %1/==/ (
    if not "%__var%"=="" (
        if not "%__var:~0,1%"=="-" (
            endlocal
            goto read_params
        )
        endlocal & set %__var:~1%=%~1
    ) else (
        setlocal & set __var=%~1
    )
    shift
    goto read_params
)
exit /B

:NextStep
