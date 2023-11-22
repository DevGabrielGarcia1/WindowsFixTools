@echo off
CLS
TITLE Windows Fix Tools

::::::::::::::::::::::::::::
::Language variables
::::::::::::::::::::::::::::





::::::::::::::::::::::::::::
::Request admin
::::::::::::::::::::::::::::
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================


:init
setlocal DisableDelayedExpansion
set cmdInvoke=1
set winSysFolder=System32
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"

if '%cmdInvoke%'=='1' goto InvokeCmd 

ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
goto ExecElevation

:InvokeCmd
ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
"%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)


::::::::::::::::::::::::::::
::Set Language
::::::::::::::::::::::::::::
CLS
ECHO.
ECHO =============================
ECHO Language
ECHO =============================
ECHO.
ECHO 1 - English
ECHO 2 - Portugues
ECHO 3 - EXIT
ECHO.
SET /P M=Type 1, 2 or 3 then press ENTER: 
IF %M%==4 GOTO EOF
IF %M%==3 GOTO FIM
IF %M%==1 GOTO English
IF %M%==2 GOTO Portugues

:English
SET menu1Op1=Automated correction
SET menu1Op2=Advanced options

SET menuOp1="SFC & DISM" check and automatic correction
SET menuOp2="SFC & DISM" check and manual correction

GOTO start

:Portugues
SET menu1Op1=Correcao automatizada
SET menu1Op2=Opcoes avancadas

SET menu2Op1=Verificacao "SFC & DISM" e correcao automatica
SET menu2Op2=Verificacao "SFC & DISM" e correcao manual

GOTO start



::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
:start
CLS
ECHO.
ECHO =============================
ECHO Windows Fix Tools
ECHO =============================


:MENU1
ECHO.
ECHO 1 - %menu1Op1%
ECHO 2 - %menu1Op2%
ECHO 3 - EXIT
ECHO.
SET /P M=Type 1, 2 or 3 then press ENTER: 
IF %M%==1 GOTO auto
IF %M%==2 GOTO MENU2
IF %M%==3 GOTO FIM
IF %N%==4 GOTO EOF



:MENU2
CLS
ECHO.
ECHO =============================
ECHO Windows Fix Tools
ECHO =============================
ECHO.
ECHO 1 - %menu2Op1%
ECHO 2 - %menu2Op2%
ECHO 3 - EXIT
ECHO.
SET /P M=Type 1, 2 or 3 then press ENTER: 
IF %M%==1 GOTO AUTOCMD
IF %M%==2 GOTO MANUALCMD
IF %M%==3 GOTO FIM
IF %N%==4 GOTO EOF



:auto
:ALTOCMD
ECHO.
ECHO =============================
ECHO SFC Scannow:
sfc /scannow && ECHO. && ECHO ============================= && ECHO DISM ScanHealth: && Dism /Online /Cleanup-Image /ScanHealth && ECHO. && ECHO ============================= && ECHO DISM CheckHealth: && dism /online /cleanup-image /CheckHealth && ECHO. && ECHO ============================= && ECHO DISM RestoreHealth: && dism /online /cleanup-image /restorehealth
echo off
GOTO FIM

:ALTOPWS
ECHO.
ECHO =============================
ECHO Powershell:
echo on
powershell -command "sfc /scannow; Dism /Online /Cleanup-Image /ScanHealth; dism /online /cleanup-image /CheckHealth; dism /online /cleanup-image /restorehealth"
echo off
GOTO FIM

:MANUALCMD
echo on
sfc /scannow && Dism /Online /Cleanup-Image /ScanHealth && dism /online /cleanup-image /CheckHealth
echo off
SET /P M=Type 1 - Yes, 2 - No then press ENTER: 
IF %M%==2 GOTO FIM
dism /online /cleanup-image /restorehealth
GOTO FIM

:MANUALPWS
echo on
powershell -command "sfc /scannow; Dism /Online /Cleanup-Image /ScanHealth; dism /online /cleanup-image /CheckHealth"
echo off
GOTO FIM

:FIM
ECHO.
ECHO.
ECHO.
ECHO =============================
ECHO Finalizado
ECHO =============================
pause