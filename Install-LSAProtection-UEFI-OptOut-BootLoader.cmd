@echo off
:: Test status of RunAsPpl
SET __RunAsPPL=0

reg query hklm\system\currentcontrolset\control\lsa /v RunAsPpl|find /i "RunAsPpl"|find /i "0x1" > nul
if %errorlevel% == 0 SET __RunAsPPL=1

reg query hklm\system\currentcontrolset\control\lsa /v RunAsPpl|find /i "RunAsPpl"|find /i "0x2" > nul
if %errorlevel% == 0 SET __RunAsPPL=1

:: LSA Protection enabled in registry - must be removed first!
if %__RunAsPPL%==1 goto RunAsPPLEnabled


:: Test if boot entry already added
bcdedit /enum "{0cb3b571-2f2e-4343-a879-d86a476d7215}" | find /i "{0cb3b571-2f2e-4343-a879-d86a476d7215}" > nul
if %errorlevel% == 0 SET __RunAsPPLBootLoader=1
if %errorlevel% == 1 SET __RunAsPPLBootLoader=0

if %__RunAsPPLBootLoader%==0 (if NOT exist %~dp0LSAPPLConfig.efi goto NoBootLoader)
if %__RunAsPPLBootLoader%==0 (if exist x:\ goto XAlreadyMounted)

if %__RunAsPPLBootLoader%==0 echo Boot loader will be installed.
if %__RunAsPPLBootLoader%==1 echo Boot loader already installed - will be re-activated.
echo .

:: Add Opt Out Boot loader to system partition and boot loader table.
if %__RunAsPPLBootLoader%==0 mountvol X: /s
if %__RunAsPPLBootLoader%==0 copy "%~dp0LSAPPLConfig.efi" X:\EFI\Microsoft\Boot\LSAPPLConfig.efi /Y
if %__RunAsPPLBootLoader%==0 bcdedit /create "{0cb3b571-2f2e-4343-a879-d86a476d7215}" /d "DebugTool" /application osloader
if %__RunAsPPLBootLoader%==0 bcdedit /set "{0cb3b571-2f2e-4343-a879-d86a476d7215}" path "\EFI\Microsoft\Boot\LSAPPLConfig.efi"
if %__RunAsPPLBootLoader%==0 bcdedit /set "{0cb3b571-2f2e-4343-a879-d86a476d7215}" loadoptions "%1"
if %__RunAsPPLBootLoader%==0 bcdedit /set "{0cb3b571-2f2e-4343-a879-d86a476d7215}" device partition=X:
if %__RunAsPPLBootLoader%==0 mountvol X: /d

:: Set bootsequence so the Opt Out bootloader will be invoked on next boot
bcdedit /set "{bootmgr}" bootsequence "{0cb3b571-2f2e-4343-a879-d86a476d7215}"

echo .
echo Boot loader for LSA Protection Opt Out Tool (ID = {0cb3b571-2f2e-4343-a879-d86a476d7215} ) has been added/activated!
echo Reboot with console open and press F3 when asked to opt out!
goto:eof

:NoBootLoader
echo %~dp0LSAPPLConfig.efi not found!
goto:eof


:XAlreadyMounted
echo X: already mounted. X: must be available. Unmount it first then re-run.
goto:eof

:RunAsPPLEnabled
echo .
echo Opt Out Tool Boot loader NOT installed!!
echo .
echo HKLM\System\CurrentControlSet\Control\LSA\RunAsPpl is still set to:
echo .
reg query hklm\system\currentcontrolset\control\lsa /v RunAsPpl
echo .
echo UEFI variable would be set again immediately after boot - remove this setting or set it
echo to 0x0 to disable RunAsPpl in registry, then rerun this script to install opt out tool!
echo .
echo IMPORTANT: Setting may come from a Group Policy - ensure you change that as well!
echo .
goto:eof