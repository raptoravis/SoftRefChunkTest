@echo off

rem https://github.com/botman99/ue4-unreal-automation-tool

setlocal

REM - This batch file will build the editor and game code for your Unreal Engine project.

rem echo "=========================================================="
rem echo "Usage: PackageGame.bat [-clean=<0|1>] [-platform=Win64|Android] [-Server=1]
rem echo "=========================================================="

call _SetEnv.bat %*

if [%CLEAN%]==[1] (set CLEAN=-clean) else (set CLEAN=)

REM - Set MAPS to the list of maps you want to cook, for example "MainMenuMap+FirstLevel+SecondLevel+TestMap" (DO NOT PUT SPACES ANYWHERE HERE!!!)
set MAPS=

if exist "%UPROJECT_FULLNAME%.uproject" goto Continue

echo.
echo Warning - %UPROJECT_FULLNAME%.uproject does not exist!
echo (edit _SetEnv.bat in a text editor and set UEENGINE_ROOT,UPROJECT_PATH,PROJECT_NAME)
echo.

pause

goto Exit

:Continue

if exist BUILD_EDITOR_FAILED.txt del BUILD_EDITOR_FAILED.txt
if exist BUILD_GAME_FAILED.txt del BUILD_GAME_FAILED.txt
if exist PACKAGING_FAILED.txt del PACKAGING_FAILED.txt

if NOT "%MAPS%"=="" (goto CheckInstalledBuild)

echo.
echo Warning - You don't have MAPS set, this will cause ALL content to be cooked!
echo (potentially making your packaged build larger than it needs to be)
echo.

:CheckInstalledBuild

REM - We need to check if this is an "Installed Build" (i.e. installed from the Epic Launcher) or a source code build (from GitHub).
if exist "%UEENGINE_ROOT%\Engine\Build\InstalledBuild.txt" (
    set INSTALLED=-installed
) else (
    set INSTALLED=
)

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

echo %date% %time% Packaging the game...

REM - Note: "-clean" will clean and rebuild your game code (for C++ projects) and will clean the project's Saved\Cooked and Saved\StagedBuilds for every time this runs
REM - Note: If you don't wish to fully rebuild your game code each time you package, you can add "-nocompile" to skip compiling game code.
REM - Note: "-pak" will store all cooked content into a .pak file (using the UnrealPak tool).  Packaged games can (optionally) use encrypted .pak file for better security.
REM - Note: When you are ready to ship your game, change -configuration to just "-configuration=Shipping" (to prevent including Development and DebugGame executables in your shipped build).
REM - Note: When you are ready to ship your game, add "-nodebuginfo" to prevent the .pdb file from being added to the game's Binaries/Win64 folder.
REM - Note: Using "-createreleaseversion" allows you to create Patches and DLC later for your game if you wish.
REM - Note: You can use "-compressed" if you want to compress packages (this will make files smaller, but may take longer to load in game).

set COOKFLAVOR=ASTC

rem by default Win64
if /i [%PLATFORM%]==[] ( 
	set PLATFORM=Win64
)

if /i [%SERVER%]==[1] (
	echo "               Package Server"

	if /i [%PLATFORM%]==[Win64] goto PackageServer
	if /i [%PLATFORM%]==[Linux] goto PackageServer
	
	echo "               Only Win64 and Linux supported for Server"
	goto Error_PackagingFailed
) else (
	echo "               Package Game"
	
	goto PackageGame
)	

:PackageServer	
set BASICCONFIG=-server -noclient -serverconfig=%CONFIGUATION% -serverplatform=%PLATFORM%
goto PackageCommand

:PackageGame
set BASICCONFIG=-platform=%PLATFORM% -clientconfig=%CONFIGUATION%
goto PackageCommand

:PackageCommand

set COMMANDLINE_OPT=-TargetPlatform=%PLATFORM% -configuration=%CONFIGUATION% %CLEAN% -nocompileeditor -unattended -utf8output -build -cook -stage -pak -prereqs -package -utf8output -archive

set COMMANDLINE_OPTS_ALL=%INSTALLED% %BASICCONFIG% -cookflavor=%COOKFLAVOR% -map=%MAPS% %COMMANDLINE_OPT% -archivedirectory="%UPROJECT_PATH%\Saved\packagesOut" -createreleaseversion=1.0

echo COMMANDLINE_OPTS_ALL: %COMMANDLINE_OPTS_ALL%

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat BuildCookRun -project="%UPROJECT_FULLNAME%.uproject" %COMMANDLINE_OPTS_ALL%
if errorlevel 1 goto Error_PackagingFailed

echo.
echo %date% %time% Done!

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

:Error_PackagingFailed
echo.
echo %date% %time% Error - Packaging failed!
type NUL > PACKAGING_FAILED.txt
goto Exit


:Exit
