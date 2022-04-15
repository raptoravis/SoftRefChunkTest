@echo off

rem https://github.com/botman99/ue4-unreal-automation-tool
rem echo "=========================================================="
rem echo "Usage: Build.bat [-clean=1] [-configuration=Development|Shipping]
rem echo "=========================================================="

call _SetEnv.bat %*

if exist "%UPROJECT_FULLNAME%.uproject" goto Continue

echo.
echo Warning - %UPROJECT_FULLNAME%.uproject does not exist!
echo (edit _SetEnv.bat in a text editor and set UEENGINE_ROOT,UPROJECT_PATH,PROJECT_NAME)
echo.

pause

goto Exit

:Continue

if exist CLEAN_FAILED.txt del CLEAN_FAILED.txt
if exist BUILD_TOOLS_FAILED.txt del BUILD_TOOLS_FAILED.txt
if exist BUILD_EDITOR_FAILED.txt del BUILD_EDITOR_FAILED.txt
if exist BUILD_GAME_FAILED.txt del BUILD_GAME_FAILED.txt

set INSTALLEDBUILD_ON=0

REM - We need to check if this is an "Installed Build" (i.e. installed from the Epic Launcher) or a source code build (from GitHub).
REM - We don't clean tools on an installed build.
if exist "%UEENGINE_ROOT%\Engine\Build\InstalledBuild.txt" (
	set INSTALLEDBUILD_ON=1
    goto InstalledBuild
) else (
    goto SourceCodeBuild
)

:InstalledBuild

REM - Check if a .sln file exists for the project, if so, then it is a C++ project and you can clean and build the game editor and game.
REM - (otherwise it's a Blueprint project).
if exist "%UPROJECT_FULLNAME%.sln" (
	if [%CLEAN%]==[0] goto Build

    echo.
    echo %date% %time% Cleaning Game Editor...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME%Editor Win64 Development" -Project="%UPROJECT_FULLNAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed

    echo.
    echo %date% %time% Building Game Editor...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat BuildEditor -Project="%UPROJECT_FULLNAME%.uproject" -notools
    if errorlevel 1 goto Error_BuildEditorFailed

    echo.
    echo %date% %time% Cleaning Game...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME% Win64 Development" -Target="%PROJECT_NAME% Win64 Shipping" -Target="%PROJECT_NAME% Win64 DebugGame" -Project="%UPROJECT_FULLNAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed

    echo.
    echo %date% %time% Building Game...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat BuildGame -project="%UPROJECT_FULLNAME%.uproject" -platform=Win64 -notools -configuration=%CONFIGUATION%
    if errorlevel 1 goto Error_BuildGameFailed
) else (
    echo.
    echo You don't need to run this batch file.  There's nothing to build for Blueprint projects.

    goto Exit
)

echo.
echo %date% %time% Done!

goto Exit


:SourceCodeBuild

if [%CLEAN%]==[0] goto Build

echo.
echo %date% %time% Cleaning Tools...
echo.

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UnrealHeaderTool Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UnrealPak Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat ShaderCompileWorker Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UnrealLightmass Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UnrealFrontend Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UnrealInsights Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UnrealMultiUserServer Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat CrashReportClient Win64 Shipping -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat CrashReportClientEditor Win64 Shipping -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
rem call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UnrealGameSync Win64 Shipping -WaitMutex -FromMSBuild
rem if errorlevel 1 goto Error_CleanFailed

echo.
echo %date% %time% Cleaning Editor...
echo.

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat -Target="UE4Editor Win64 Development" -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed

echo.
echo %date% %time% Cleaning Editor Game (UE4Game)...
echo.

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UE4Game Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UE4Game Win64 Shipping -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat UE4Game Win64 DebugGame -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed

REM - Check if a .sln file exists for the project, if so, then it is a C++ project and you can clean the game editor and game.
REM - (otherwise it's a Blueprint project).
if exist "%UPROJECT_FULLNAME%.sln" (
    echo.
    echo %date% %time% Cleaning Game Editor...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME%Editor Win64 Development" -Project="%UPROJECT_FULLNAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed

    echo.
    echo %date% %time% Cleaning Game...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME% Win64 Development" -Target="%PROJECT_NAME% Win64 Shipping" -Target="%PROJECT_NAME% Win64 DebugGame" -Project="%UPROJECT_FULLNAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed
)


:Build

if [%INSTALLEDBUILD_ON%]==[1] goto BuildProject

echo.
echo %date% %time% Building Tools...
echo.

%UEENGINE_ROOT%\Engine\Binaries\DotNET\UnrealBuildTool.exe UnrealFrontend Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_BuildToolsFailed
%UEENGINE_ROOT%\Engine\Binaries\DotNET\UnrealBuildTool.exe UnrealInsights Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_BuildToolsFailed
%UEENGINE_ROOT%\Engine\Binaries\DotNET\UnrealBuildTool.exe UnrealMultiUserServer Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_BuildToolsFailed

if exist "%UEENGINE_ROOT%\Engine\Source\Programs\UnrealGameSync\UnrealGameSync.sln" (
	rem devenv "%UEENGINE_ROOT%\Engine\Source\Programs\UnrealGameSync\UnrealGameSync.sln" /build Development /projectconfig Development
	rem set MSBUILD=%WINDIR%\Microsoft.NET\Framework\v2.0.50727\MsBuild.exe
	set MSBUILD2017="C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe"
	set MSBUILD2019="C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
	
	IF EXIST !MSBUILD2019! (
		set MSBUILD=!MSBUILD2019!
	) ELSE (
		IF EXIST !MSBUILD2017! (
			set MSBUILD=!MSBUILD2017!
		) ELSE (
			echo visual studio 2019/2017 needed
		)
	) 
	
	echo MSBUILD: !MSBUILD!
	
	IF EXIST "!MSBUILD!" (
		rem !MSBUILD! "%UEENGINE_ROOT%\Engine\Source\Programs\UnrealGameSync\UnrealGameSync.sln" /t:UnrealGameSync\UnrealGameSync:Build /p:Configuration=Development
		rem if errorlevel 1 goto Error_BuildToolsFailed
	) else (
		echo !MSBUILD! not exist
	)
) else (
	echo UnrealGameSync not exist
)

if exist "%UEENGINE_ROOT%\Engine\Source\Programs\UnrealPakViewer\UnrealPakViewer.Target.cs" (
	%UEENGINE_ROOT%\Engine\Binaries\DotNET\UnrealBuildTool.exe UnrealPakViewer Win64 Development -WaitMutex -FromMSBuild
	rem if errorlevel 1 goto Error_BuildToolsFailed
) else (
	echo UnrealPakViewer not exist
)

REM - Other tools will get built by UBT when building editor (when -notools is NOT specified)

echo.
echo %date% %time% Building Editor...
echo.

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat BuildEditor
if errorlevel 1 goto Error_BuildEditorFailed

echo.
echo %date% %time% Building Editor Game (UE4Game)...
echo.

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat BuildGame -platform=Win64 -configuration=%CONFIGUATION%
if errorlevel 1 goto Error_BuildGameFailed

:BuildProject

REM - Check if a .sln file exists for the project, if so, then it is a C++ project and you can build the game editor (otherwise it's a Blueprint project).
if exist "%UPROJECT_FULLNAME%.sln" (
    echo.
    echo %date% %time% Building Game Editor...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat BuildEditor -Project="%UPROJECT_FULLNAME%.uproject" -notools
    if errorlevel 1 goto Error_BuildEditorFailed

    echo.
    echo %date% %time% Building Game...
    echo.

    call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat BuildGame -project="%UPROJECT_FULLNAME%.uproject" -platform=Win64 -notools -configuration=%CONFIGUATION%
    if errorlevel 1 goto Error_BuildGameFailed
)

echo.
echo %date% %time% Done!

goto Exit

:Error_CleanFailed
echo.
echo %date% %time% Error - Clean failed!
type NUL > CLEAN_FAILED.txt
goto Exit

:Error_BuildToolsFailed
echo.
echo %date% %time% Error - Build Tools failed!
type NUL > BUILD_TOOLS_FAILED.txt
goto Exit

:Error_BuildEditorFailed
echo.
echo %date% %time% Error - Build Editor failed!
type NUL > BUILD_EDITOR_FAILED.txt
goto Exit

:Error_BuildGameFailed
echo.
echo %date% %time% Error - Build Game failed!
type NUL > BUILD_GAME_FAILED.txt
goto Exit


:Exit
