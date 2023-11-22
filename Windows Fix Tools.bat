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
SET menu1Op2=Repair disk
SET menu1Op3=Windows update fix
SET menu1Op4=Advanced options

SET menu2Op1="SFC & DISM" check and automatic correction
SET menu2Op2="SFC & DISM" check and manual correction

SET menuWinUpdOp1=Solution 1
SET menuWinUpdOp2=Solution 2 - repair the disk
SET menuWinUpdOp3=Solution 3 - repair "DISM" and "SFC" system

GOTO start

:Portugues
SET menu1Op1=Correcao automatizada
SET menu1Op2=Reparar disco
SET menu1Op3=Correcao do windows update
SET menu1Op4=Opcoes avancadas

SET menu2Op1=Verificacao "SFC & DISM" e correcao automatica
SET menu2Op2=Verificacao "SFC & DISM" e correcao manual

SET menuWinUpdOp1=Solucao 1
SET menuWinUpdOp2=Solucao 2 - repare o disco
SET menuWinUpdOp3=Solucao 3 - repare o sistema "DISM" e "SFC"

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
ECHO 3 - %menu1Op3%
ECHO 4 - %menu1Op4%
ECHO 5 - EXIT
ECHO.
SET /P M=Type 1, 2, 3, 4 or 5 then press ENTER: 
IF %M%==1 GOTO auto
IF %M%==2 GOTO FixDisk
IF %M%==3 GOTO MENUWinUpdateFix
IF %M%==4 GOTO MENU2
IF %M%==5 GOTO FIM
IF %N%=>6 GOTO EOF



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
IF %M%==3 GOTO start
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


:FixDisk
ECHO.
ECHO =============================
ECHO Fix Disk:
ECHO.
chkdsk/f C:
GOTO FIM

:MENUWinUpdateFix
CLS
ECHO.
ECHO =============================
ECHO Windows Fix Tools
ECHO =============================
ECHO.
ECHO =============================
ECHO Windows Update Fix:
ECHO.
ECHO 1 - %menuWinUpdOp1%
ECHO 2 - %menuWinUpdOp2%
ECHO 3 - %menuWinUpdOp3%
ECHO 4 - EXIT
ECHO.
SET /P M=Type 1, 2, 3 or 4 then press ENTER: 
IF %M%==1 GOTO WinUpdateFixSolution1
IF %M%==2 GOTO FixDisk
IF %M%==3 GOTO AUTOCMD
IF %M%==4 GOTO start
IF %N%==5 GOTO EOF

:WinUpdateFixSolution1
ECHO.
ECHO =============================
ECHO Windows Update Fix:
ECHO.
net stop bits
net stop wuauserv
ren %systemroot%\softwaredistribution softwaredistribution.bak
ren %systemroot%\system32\catroot2 catroot2.bak
net start bits
net start wuauserv 
SET /P M=Reinicar agora? / Restart now? (Y=1/N): 
IF %M%==1 shutdown /r /t 0
GOTO start

:FIM
ECHO.
ECHO.
ECHO.
ECHO =============================
ECHO Finalizado
ECHO =============================
pause