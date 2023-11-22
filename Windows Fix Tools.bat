@echo off
CLS
TITLE "SFC & DISM Tool"
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
::START
::::::::::::::::::::::::::::
ECHO.
ECHO =============================
ECHO " SFC & DISM Tool "
ECHO =============================

:MENU
ECHO.
ECHO "1 - Verificacao SFC & DISM e correcao automatica"
ECHO "2 - Verificacao SFC & DISM e correcao manual"
ECHO "3 - EXIT"
ECHO.
SET /P M=Type 1, 2 or 3 then press ENTER: 
ECHO.
ECHO 1 - CMD
ECHO 2 - PowerShell
ECHO 3 - EXIT
ECHO.
SET /P N=Type 1, 2 or 3 then press ENTER: 

cls
ECHO.
ECHO =============================
ECHO " SFC & DISM Tool "
ECHO =============================
ECHO.

IF %M%==1 IF %N%==1 GOTO ALTOCMD
IF %M%==1 IF %N%==2 GOTO ALTOPWS
IF %M%==2 IF %N%==1 GOTO MANUALCMD
IF %M%==2 IF %N%==2 GOTO MANUALPWS
IF %M%==4 GOTO EOF
IF %N%==4 GOTO EOF

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