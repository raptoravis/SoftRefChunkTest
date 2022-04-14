@echo off

rem echo "=========================================================="
rem echo "Usage: Launch.bat [-NetMode=<G|S|C> G: StandaloneGame S: Server C: Client] [-Map=Map] [-ExecCmds=Cmds]
rem echo "=========================================================="

call _SetEnv.bat %*

if [%NETMODE%]==[] (
	set NETMODE=G
)

if [%MAP%]==[] (
	set MAP=/Game/Maps/TestMap/TestMap.umap
)

if [%RESX%]==[] (
	set RESX=1280
)

if [%RESY%]==[] (
	set RESY=720
)


if [%WINDOWED%]==[] (
	set WINDOWED=-windowed
) else if [%WINDOWED%]==[1] (
	set WINDOWED=-windowed
) else (
	set WINDOWED=
)


if [%LLMCSV%]==[0] (
	set LLMCSV=
) else if [%LLMCSV%]==[1] (
	set LLMCSV=-LLMCSV
) 


if [%LLMTARGETS%]==[] (
	set LLMTARGETS=-LLMTAGSETS=Assets
) else (
	set LLMTARGETS=-LLMTAGSETS=%LLMTARGETS%
)


if [%EXECCMDS%]==[] (
	rem set EXECCMDS="-r.Shaders.Optimize=0;r.Shaders.KeepDebugInfo=1;r.Shaders.SkipCompression=1"
	set EXECCMDS=
)

rem set OTHER_OPT=-nosound -noailogging -noverifygc -novsync -benchmark -deterministic
set OTHER_OPT=-noailogging -noverifygc -novsync
set TRACE_OPT=-trace=log,counters,cpu,frame,bookmark,file,loadtime,gpu,rhicommands,rendercommands,object -statnamedevents

if exist "%UPROJECT_FULLNAME%.uproject" goto Continue

echo.
echo Warning - %UPROJECT_FULLNAME%.uproject does not exist!
echo (edit _SetEnv.bat in a text editor and set UEENGINE_ROOT,UPROJECT_PATH,PROJECT_NAME)
echo.

pause

goto Exit

:Continue

echo =======================================================================================================
echo ****** NETMODE:    %NETMODE%
echo ****** WINDOWED:   %WINDOWED%
echo ****** RESX,Y:     %RESX%, %RESY%
echo ****** MAP:        %MAP%
echo ****** EXECCMDS:   %EXECCMDS%

echo ****** OTHER_OPT:  %OTHER_OPT%
echo ****** TRACE_OPT:  %TRACE_OPT%

echo ****** LLMCSV:     %LLMCSV%
echo ****** LLMTARGETS: %LLMTARGETS%



echo =======================================================================================================

if [%NETMODE%]==[S] (
	start "Launch Dedicated Server" "%UEENGINE_ROOT%\Engine\Binaries\Win64\UE4Editor.exe" "%UPROJECT_FULLNAME%.uproject" %MAP% -ExecCmds=%EXECCMDS% -server -log -nosteam
) else (

	set COMMANDLINE_OPT=-game %WINDOWED% -ResX=%RESX% -ResY=%RESY% -ExecCmds=%EXECCMDS% %OTHER_OPT% %TRACE_OPT% %LLMCSV% %LLMTARGETS%
	echo ****** COMMANDLINE_OPT: !COMMANDLINE_OPT!
	
	if /i [%NETMODE%]==[C] ( 
		set MAP=127.0.0.1
		
		echo ****** Start Client: !MAP!
	) else (
		echo ****** Start Standalone Game: !MAP!
	)
	
	start "Launch Game" "%UEENGINE_ROOT%\Engine\Binaries\Win64\UE4Editor.exe" "%UPROJECT_FULLNAME%.uproject" !MAP! !COMMANDLINE_OPT!
)


:Exit


