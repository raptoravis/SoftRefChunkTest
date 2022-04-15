@echo off

rem https://github.com/botman99/ue4-unreal-automation-tool

rem setlocal
setlocal EnableDelayedExpansion

rem Get start time:
set "STARTTIME=%time: =0%"

echo ==========================STARTTIME: %date% %time%

echo =======================================================================================================
echo "Usage: UAT.bat [-List] [BuildGame -Help] 
echo "               [-Action=OpenEditor|OE"
echo "               [-Action=Launch|LH [-NetMode=<G|S|C> G: StandaloneGame, S: Server, C: Client] 
echo "                   				[-Map=/Game/Maps/TestMap/TestMap]"
echo "                   				[-ResX=1280] [-ResY=720] [-Windowed=1] [-ExecCmds=Cmds]"
echo "                   				[-LLMCSV=<0|1>] [-LLMTARGETS=<Assets|AssetClasses>]"
echo "               [-Action=Build|BD [-clean=<0|1>] [-configuration=Development|Shipping]"
echo "               [-Action=OpenSln|OS"
echo "               [-Action=GenerateSln|GS"
echo "               [-Action=CompileAllBlueprints|CBP"
echo "               [-Action=|PakViewer|PV"
echo "               [-Action=|Insights|IS]"
echo "               [-Action=|FrontEnd|FE]"
echo "               [-Action=Package|PK [-clean=<0|1>] [-platform=Win64|Android|Linux]] [-Server=<0|1>] [-configuration=Development|Shipping]
echo "               [-Action=ExtactPak|EP -PakFile=PakFile [-PakOut=OutDir]]"
echo =======================================================================================================

REM CLEAR it as read_params might set it
set CLEAN=0

call _SetEnv.bat %*

if exist "%UPROJECT_FULLNAME%.uproject" goto Continue

echo.
echo Warning - %UPROJECT_FULLNAME%.uproject does not exist!
echo (edit _SetEnv.bat in a text editor and set UEENGINE_ROOT,UPROJECT_PATH,PROJECT_NAME)
echo.

pause

goto Exit

:Continue

IF [%ACTION%] == [] (
	echo ****** No Action specified, Use the default RunUAT
	
	rem not specify any action, use RunUAT
	goto UAT
)

echo ****** ACTION:              %ACTION%

if /i [%ACTION%]==[OpenEditor] goto OpenEditor
if /i [%ACTION%]==[OE] goto OpenEditor

if /i [%ACTION%]==[Launch] goto Launch
if /i [%ACTION%]==[LH] goto Launch

if /i [%ACTION%]==[Build] goto Build
if /i [%ACTION%]==[BD] goto Build

if /i [%ACTION%]==[Package] goto PackageGame
if /i [%ACTION%]==[PK] goto PackageGame

if /i [%ACTION%]==[OpenSln] goto OpenSln
if /i [%ACTION%]==[OS] goto OpenSln

if /i [%ACTION%]==[GenerateSln] goto GenerateSln
if /i [%ACTION%]==[GS] goto GenerateSln


if /i [%ACTION%]==[CompileAllBlueprints] goto CompileAllBlueprints
if /i [%ACTION%]==[CBP] goto CompileAllBlueprints

if /i [%ACTION%]==[PakViewer] goto PakViewer
if /i [%ACTION%]==[PV] goto PakViewer

if /i [%ACTION%]==[Insights] goto Insights
if /i [%ACTION%]==[IS] goto Insights

if /i [%ACTION%]==[FrontEnd] goto FrontEnd
if /i [%ACTION%]==[FE] goto FrontEnd

if /i [%ACTION%]==[ExtactPak] goto ExtactPak
if /i [%ACTION%]==[EP] goto ExtactPak

echo ****** Unhandled Action: %ACTION%, Do nothing
goto Exit

:OpenEditor

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat OpenEditor -project=%UPROJECT_FULLNAME%.uproject

goto Exit

:Launch

call _Launch.bat

goto Exit

:Build

call _Build.bat

goto Exit

:PackageGame

call _Package.bat

goto Exit

:OpenSln

start  %UPROJECT_FULLNAME%.sln

goto Exit

:GenerateSln

call %UEENGINE_ROOT%\GenerateProjectFiles.bat %UPROJECT_FULLNAME%.uproject -Game -Engine

goto Exit


:CompileAllBlueprints

rem if [%BPCOMPILERESULT%]==[] (
rem 	set BPCOMPILERESULT=%UPROJECT_PATH%\Saved\BPCompileResult.txt
rem )

rem echo ****** BPCOMPILERESULT:     %BPCOMPILERESULT%

echo ****** Result:              %UPROJECT_PATH%\Saved\Logs

start %UEENGINE_ROOT%\Engine\Binaries\Win64\UE4Editor-Cmd.exe %UPROJECT_FULLNAME%.uproject -run=CompileAllBlueprints

goto Exit

:PakViewer

start  %UEENGINE_ROOT%\Engine\Binaries\Win64\UnrealPakViewer.exe

goto Exit

:Insights

start  %UEENGINE_ROOT%\Engine\Binaries\Win64\UnrealInsights.exe

goto Exit


:FrontEnd

start  %UEENGINE_ROOT%\Engine\Binaries\Win64\UnrealFrontEnd.exe

goto Exit


:ExtactPak

if [%PAKOUT%]==[] (
	set PAKOUT=%UPROJECT_PATH%\Saved\ExtactPak
)

echo ****** PakFile:             %PakFile%
echo ****** PakOut:              %PakOut%

start  %UEENGINE_ROOT%\Engine\Binaries\Win64\UnrealPak.exe -extract %PakFile% %PakOut%

goto Exit

:UAT

call %UEENGINE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat %*

goto Exit

:Exit

rem Get end time:
set "ENDTIME=%time: =0%"

echo ==========================EndTime: %date% %time%


rem Get elapsed time:
set "end=!ENDTIME:%time:~8,1%=%%100)*100+1!"  &  set "start=!STARTTIME:%time:~8,1%=%%100)*100+1!"
set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100), elap-=(elap>>31)*24*60*60*100"

rem Convert elapsed time to HH:MM:SS:CC format:
set /A "cc=elap%%100+100,elap/=100,ss=elap%%60+100,elap/=60,mm=elap%%60+100,hh=elap/60+100"

echo Start:    %STARTTIME%
echo End:      %ENDTIME%
echo Elapsed:  %hh:~1%%time:~2,1%%mm:~1%%time:~2,1%%ss:~1%%time:~8,1%%cc:~1%
