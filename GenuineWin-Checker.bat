@echo off

setlocal EnableDelayedExpansion

for /f "tokens=6 delims=[]. " %%a in ('ver') do set /a winbuild=%%a
set "nul1=>nul"
set "nul2=>nul"
set "ps=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "psc=%ps% -NoLogo -NoProfile -ExecutionPolicy Bypass -Command"

set "_NCS=1"
if %winbuild% LSS 10586 set "_NCS=0"
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 %nul2% | find /i "0x0" %nul1% && (set "_NCS=0")

if %_NCS% EQU 1 (
for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"
set     "Red="41;97m""
set    "Gray="100;97m""
set   "Green="42;97m""
set    "Blue="44;97m""
set   "White="107;91m""
set    "_Red="40;91m""
set  "_White="40;37m""
set  "_Green="40;92m""
set "_Yellow="40;93m""
) else (
set     "Red="Red" "white""
set    "Gray="Darkgray" "white""
set   "Green="DarkGreen" "white""
set    "Blue="Blue" "white""
set   "White="White" "Red""
set    "_Red="Black" "Red""
set  "_White="Black" "Gray""
set  "_Green="Black" "Green""
set "_Yellow="Black" "Yellow""
)

echo Checking Administrator Requirements...

net session >nul 2>&1
if %errorlevel% == 0 (
  goto continue
) else (
  cls
  call :dk_color %Red% "===Error==="
  echo Administrator privileges required.  Please run this script as administrator.
  echo Press Any Key to Exit...
  pause >nul
  exit /b 1
)

:continue

set "%errorlevel%= "
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
    cls
    call :dk_color %Red% "===Error==="
    echo Can't connect to Internet. Please check your connection.
    echo Error Code: 404
    echo:
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:check_product
cls
echo Checking computer information / Kiem tra thong tin may...
timeout /t 2 /nobreak >nul

set "PC_NAME=%COMPUTERNAME%"
set "CURRENT_USER=%USERNAME%"

for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "OS_Name=%%B"
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion 2^>nul') do set "OS_Version=%%B"

set "OS_NAME=%OS_Name%"
set "VERSION=%OS_Version%"

cscript //nologo %systemroot%\system32\slmgr.vbs /xpr | findstr /i "permanently" >nul

if %errorlevel% equ 0 (
    set "WIN_ACT=Activated / Da kich hoat"
) else (
    cscript //nologo %systemroot%\system32\slmgr.vbs /xpr | findstr /i "grace" >nul
    if !errorlevel! equ 0 (
        set "WIN_ACT=[OOB Grace] Trial Time / Dang trong thoi gian dung thu"
    ) else (
        set "WIN_ACT=Unactivated / Chua kich hoat hoac loi"
    )
)
for /f "delims=" %%A in ('powershell -Command "[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds((Get-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion').InstallDate))"') do set "Install_Date=%%A"

set "TIME=%Install_Date%"

cls
mode 150,50
echo ===================-Computer Information / Thong tin may:-===================
echo:
echo Computer name / Ten may: %PC_NAME%
echo:
echo User / Nguoi dung: %CURRENT_USER%
echo:
echo OS / He dieu hanh: %OS_NAME% %VERSION%
echo:
echo Activation Status / Tinh trang kich hoat:
echo:
call :dk_color2 %_White% "Windows: " %_Yellow% "%WIN_ACT%"
echo:
echo Installed On / Thoi gian cai dat: %TIME%
echo:
echo =============================================================================

echo Deep Scanning will start in 5 seconds / Kiem tra sau se bat dau sau 5 giay...
timeout /t 5 /nobreak >nul

cls
echo Scanning / Dang quet...
timeout /t 2 /nobreak >nul
cls
echo Checking the KMS server. / Kiem tra may chu KMS.
set "KMS=false"
set "kms_host=None"
set "kms_verdict=clean"

cscript //nologo %systemroot%\system32\slmgr.vbs /dli | findstr /i "VOLUME_KMS VOLUME" >nul
if %errorlevel% equ 0 (
    :: Lấy địa chỉ máy chủ KMS
    for /f "tokens=3" %%K in ('cscript //nologo %systemroot%\system32\slmgr.vbs /dli ^| findstr /i "KMS machine name"') do (
        set "temp_kms=%%K"
        for /f "tokens=1 delims=:" %%L in ("!temp_kms!") do set "kms_host=%%L"
    )
    
    if defined kms_host set "kms_host=!kms_host: =!"
    
    if defined kms_host (
        set "kms_blacklist=127.0.0.1 localhost kms.msganti.com kms.digiboy.ir kms.loli.best mskms.orgzh.org kms.lotro.cc kms.chinancce.com kms.shuax.com"
        
        set "is_black=0"
        for %%B in (!kms_blacklist!) do (
            if /i "!kms_host!"=="%%B" set "is_black=1"
        )
        
        set "is_trusted_domain=0"
        set "is_private_ip=0"
        
        if "!is_black!"=="0" (
            echo !kms_host! | findstr /i "\.edu \.edu\.vn \.gov \.gov\.vn \.org" >nul
            if !errorlevel! equ 0 set "is_trusted_domain=1"
            
            echo !kms_host! | findstr /r "^10\." >nul && set "is_private_ip=1"
            echo !kms_host! | findstr /r "^192\.168\." >nul && set "is_private_ip=1"
            echo !kms_host! | findstr /r "^172\.\(1[6-9]\|2[0-9]\|3[0-1]\)\." >nul && set "is_private_ip=1"
        )
        
        if "!is_black!"=="1" (
            set "KMS=true"
            set "kms_verdict=suspicious"
        ) else if "!is_trusted_domain!"=="1" (
            set "KMS=false"
            set "kms_verdict=trusted_domain"
        ) else if "!is_private_ip!"=="1" (
            set "KMS=false"
            set "kms_verdict=private_network"
        ) else (
            set "KMS=true"
            set "kms_verdict=unknown_server"
        )
    )
)
echo Checking KMS38/HWID. / Kiem tra KMS38/HWID.
set "KMS38=unknown"
for /f "tokens=*" %%T in ('cscript //nologo %systemroot%\system32\slmgr.vbs /xpr 2^>nul') do set "expire_info=%%T"
echo !expire_info! | findstr /i "2038" >nul
if %errorlevel% equ 0 (
    set "KMS38=true"
)

set "hwid=unknown"
set "current_partial_key="
for /f "tokens=2 delims=:" %%A in ('cscript //nologo %systemroot%\system32\slmgr.vbs /dli ^| findstr /i "Partial Product Key"') do (
    set "temp_key=%%A"
    set "current_partial_key=!temp_key: =!"
)

set "generic_keys=T83GX 3V66T 2YT43 8HVX7 H8Q99 4398T YYVX2 6F377 DBX9C M269M MT396 6C8CH 3GH72 R3VYY QFF9Y 27GXM 4CP9G"

set "is_hwid_mas=0"
if defined current_partial_key (
    for %%K in (%generic_keys%) do (
        if /i "%current_partial_key%"=="%%K" (
            set "is_hwid_mas=1"
        )
    )
)

if "%is_hwid_mas%"=="1" (
    set "hwid=true"
) else (
    set "hwid=false"
)

echo Checking the copyright logic and OEM key.  / Kiem tra logic ban quyen va OEM key.
set "bios=unknown"

set "active_partial_key="
for /f "tokens=3 delims=: " %%A in ('cscript //nologo %systemroot%\system32\slmgr.vbs /dli ^| findstr /i "Partial Product Key"') do (
    set "active_partial_key=%%A"
)

set "bios_key="
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\ProductOptions" /v "OriginalProductKey" 2^>nul') do (
    set "bios_key=%%B"
)

if not defined bios_key (
    for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v "BackupProductKeyDefault" 2^>nul') do (
        set "bios_key=%%B"
    )
)

if "%bios_key%"=="" (
    set "bios=unknown"
) else (
    set "bios_partial_key=!bios_key:~-5!"
    
    if defined active_partial_key (
        if /i "!active_partial_key!"=="!bios_partial_key!" (
            set "bios=false"
        ) else (
            set "is_mas=0"
            for %%K in (%generic_keys%) do (
                if /i "%active_partial_key%"=="%%K" set "is_mas=1"
            )
            
            if "!is_mas!"=="1" (
                set "bios=true"
            ) else (
                set "bios=upgrade"
            )
        )
    )
)

echo Check the suspicious folder or file. / Kiem tra thu muc hay file nghi van.

set "kmsfile=unknown"
set "kms_tool_detected=0"
set "detected_paths="

set "target_paths="C:\Program Files\KMSpico" "C:\Program Files (x86)\KMSpico" "C:\ProgramData\KMSAuto" "C:\ProgramData\KMSAutoS" "C:\Windows\KMSAuto" "C:\Program Files\KMSAuto Net""

for %%P in (%target_paths%) do (
    if exist %%P (
        set "kms_tool_detected=1"
        set "detected_paths=!detected_paths! %%P,"
    )
)

set "target_files="C:\Windows\SECOH-QAD.exe" "C:\Windows\SECOH-QAD.dll" "C:\Windows\KMSConnection.xml""
for %%F in (%target_files%) do (
    if exist %%F (
        set "kms_tool_detected=1"
        set "detected_paths=!detected_paths! %%F,"
    )
)

sc query "KMSpico_service" >nul 2>&1
if %errorlevel% equ 0 (
    set "kms_tool_detected=1"
    set "detected_paths=!detected_paths! [Service: KMSpico_service],"
)
sc query "Service_KMS" >nul 2>&1
if %errorlevel% equ 0 (
    set "kms_tool_detected=1"
    set "detected_paths=!detected_paths! [Service: Service_KMS],"
)

if "%kms_tool_detected%"=="1" (
    set "kmsfile=true"
) else (
    set "kmsfile=false"
)

echo Check the KMS Tasks. / Kiem tra cac task KMS.

set "kmstask=unknown"
set "task_detected=0"
set "detected_tasks="

set "target_tasks="KMSConnection" "KMSpico" "KMSAuto" "KMSAutoS" "KMS38" "Wub" "KMS-Activation" "HEU_KMS" "AIO_KMS""

for %%T in (%target_tasks%) do (
    schtasks /query /fo LIST 2>nul | findstr /i /c:"TaskName: \%%T" /c:"TaskName: \Microsoft\Windows\%%T" >nul
    if !errorlevel! equ 0 (
        set "task_detected=1"
        set "detected_tasks=!detected_tasks! [Task: %%T],"
    )
)

set "temp_tasks=%temp%\tasks_list.txt"
schtasks /query /v /fo CSV > "%temp_tasks%" 2>nul

findstr /i "secoh-qad" "%temp_tasks%" >nul && (
    set "task_detected=1"
    set "detected_tasks=!detected_tasks! [Task: Chay SECOH-QAD],"
)
findstr /i "Appdata\Local\Temp" "%temp_tasks%" | findstr /i ".vbs .bat .ps1" >nul && (
    set "task_detected=1"
    set "detected_tasks=!detected_tasks! [Task: Chay Script tu Temp],"
)

if exist "%temp_tasks%" del /f /q "%temp_tasks%"

if "%task_detected%"=="1" (
    set "kmstask=true"
) else (
    set "kmstask=false"
)

echo Checking for registry interference. / Dang kiem tra can thiep registry.

set "registry=unknown"
set "reg_bypass_detected=0"
set "detected_regs="

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v NoGenTicket >nul 2>&1
if %errorlevel% equ 0 (
    set "reg_bypass_detected=1"
    set "detected_regs=!detected_regs! [Registry: NoGenTicket Bypass],"
)

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServiceName >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%R in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServiceName 2^>nul') do set "kms_reg_ip=%%R"
    set "reg_bypass_detected=1"
    set "detected_regs=!detected_regs! [KMS Server Registry: !kms_reg_ip!],"
)

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServicePort >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%P in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServicePort 2^>nul') do set "kms_reg_port=%%P"
    set "reg_bypass_detected=1"
    set "detected_regs=!detected_regs! [KMS Port Registry: !kms_reg_port!],"
)

if "%reg_bypass_detected%"=="1" (
    set "registry=true"
) else (
    set "registry=false"
)

echo Scanning successful. / Quet thanh cong.
timeout /t 2 /nobreak >nul
cls
echo Outputting results. / Dang xuat ket qua.
timeout /t 2 /nobreak >nul
cls
echo ===================-Computer Information / Thong tin may:-===================
echo:
echo Computer name / Ten may: %PC_NAME%
echo:
echo User / Nguoi dung: %CURRENT_USER%
echo:
echo OS / He dieu hanh: %OS_NAME% %VERSION%
echo:
echo Activation Status / Tinh trang kich hoat:
echo:
call :dk_color2 %_White% "Windows: " %_Yellow% "%WIN_ACT%"
echo:
echo Installed On / Thoi gian cai dat: %TIME%
echo:
echo =============================================================================
echo:
echo =============================-Results / Ket qua-=============================
echo:
if /i "%KMS%"=="true" (
    if /i "%kms_verdict%"=="suspicious" (
	call :dk_color %_Red% "[-] Traces of activation of a pirated KMS server have been detected."
    	call :dk_color %_Red% "[-] Phat hien dau vet kich hoat may chu KMS lau."
    ) else if /i "%kms_verdict%"=="trusted_domain" (
    	call :dk_color %_Green% "[+] No traces of pirated KMS were detected."
    	call :dk_color %_Green% "[+] Ko phat hien dau vet KMS lau."
    ) else if /i "%kms_verdict%"=="private_network" (
    	call :dk_color %_Green% "[+] No traces of pirated KMS were detected."
    	call :dk_color %_Green% "[+] Ko phat hien dau vet KMS lau."
    ) else if /i "%kms_verdict%"=="unknown_server" (
	call :dk_color %_Red% "[-] Traces of activation of a pirated KMS server have been detected."
    	call :dk_color %_Red% "[-] Phat hien dau vet kich hoat may chu KMS lau."
    )
) else (
    call :dk_color %_Green% "[+] No traces of pirated KMS were detected."
    call :dk_color %_Green% "[+] Ko phat hien dau vet KMS lau."
)

echo:

if /i "%KMS38%"=="true" (
    call :dk_color %_Red% [-] "Traces of activation of a pirated KMS38 server have been detected."
    call :dk_color %_Red% [-] "Phat hien dau vet kich hoat may chu KMS38 lau."
) else (
    call :dk_color %_Green% "[+] No traces of pirated KMS38 were detected."
    call :dk_color %_Green% "[+] Ko phat hien dau vet KMS38 lau."
)

echo:

if /i "%hwid%"=="true" (
    call :dk_color %_Red% "[-] Detecting activation traces using HWID."
    call :dk_color %_Red% "[-] Phat hien dau vet kich hoat bang HWID."
) else (
    call :dk_color %_Green% "[+] No evidence of using pirated HWID was detected."
    call :dk_color %_Green% "[+] Ko phat hien dau vet dung hwid lau."
)

echo:

if /i "%bios%"=="true" (
    call :dk_color %_Red% "[-] Key not matching detected."
    call :dk_color %_Red% "[-] Phat hien key khong trung khop."
) else if /i "%bios%"=="unknown" (
    call :dk_color %_Yellow% "[ ] BIOS key not found."
    call :dk_color %_Yellow% "[ ] Khong tim thay key BIOS."
) else if /i "%bios%"=="upgrade" (
    call :dk_color %Blue% "[i] Upgrade key detected but lacks a valid digital entitlement."
    call :dk_color %Blue% "[i] Key nang cap duoc phat hien nhung thieu giay phep so hop le."
) else (
    call :dk_color %_Green% "[+] BIOS Key matches."
    call :dk_color %_Green% "[+] BIOS Key trung khop."
)

echo:

if /i "%kmsfile%"=="true" (
    call :dk_color %_Red% "[-] Suspicious folders and files detected."
    call :dk_color %_Red% "[-] Phat hien thu muc va file dang ngo."
) else (
    call :dk_color %_Green% "[+] No suspicious folders or files were detected."
    call :dk_color %_Green% "[+] Khong phat hien thu muc va file dang ngo."
)

echo:

if /i "%kmstask%"=="true" (
    call :dk_color %_Red% "[-] The suspicious task has been detected."
    call :dk_color %_Red% "[-] Phat hien task dang ngo."
) else (
    call :dk_color %_Green% "[+] No suspicious tasks detected."
    call :dk_color %_Green% "[+] Khong phat hien task dang ngo."
)

echo:

if /i "%registry%"=="true" (
    call :dk_color %_Red% "[-] Registry tampering has been detected."
    call :dk_color %_Red% "[-] Phat hien registry bi can thiep."
) else (
    call :dk_color %_Green% "[+] No registry interference detected."
    call :dk_color %_Green% "[+] Khong phat hien su can thiep registry."
)

set "system_compromised=0"

if /i "%KMS%"=="true" set "system_compromised=1"
if /i "%KMS38%"=="true" set "system_compromised=1"
if /i "%hwid%"=="true" set "system_compromised=1"
if /i "%kmsfile%"=="true" set "system_compromised=1"
if /i "%kmstask%"=="true" set "system_compromised=1"
if /i "%registry%"=="true" set "system_compromised=1"

echo:

echo Final Verdict/ Ket luan chung:
echo:
if "%system_compromised%"=="1" (
    call :dk_color %_Red% "[-] Non-genuine OS activation detected / Phat hien phuong thuc kich hoat Windows khong chinh hang:"
    echo:
    call :dk_color %_Yellow% "The computer is being used with cracks and various other methods to bypass the license and illegally use the operating system."
    call :dk_color %_Yellow% "May tinh dang dung crack va cac cach khac nhau [KMS, HWID, KMS38] de be khoa ban quyen va su dung trai phep he dieu hanh."
) else (
    call :dk_color %_Green% "[+] Genuine OS activation verified / Xac nhan he dieu hanh kich hoat chinh hang hop phap:"
    echo:
    call :dk_color %_Yellow% "The system license is fully compliant. No bypass methods, unauthorized KMS servers, or licensing exploits were detected."
    call :dk_color %_Yellow% "Ban quyen he thong hoan toan hop le. Khong phat hien phuong thuc bypass, may chu KMS trai phep hoac can thiep giay phep."
    echo:
    call :dk_color %Blue% "[i] This system complies with Microsoft Licensing Terms / Thiet bi nay tuan thu dung Dieu khoan ban quyen cua Microsoft."
)
echo:
call :dk_color %Blue% "[i] The results are from an automated check and are not guaranteed to be accurate; please check manually for more details."
echo:
echo Press any key to exit...
pause >nul
exit


:dk_color
if %_NCS% EQU 1 (
  echo %esc%[%~1%~2%esc%[0m
) else (
  if exist "%ps%" (
    %psc% write-host -back '%1' -fore '%2' '%3'
  ) else (
    echo %~3
  )
)
exit /b

:dk_color2
if %_NCS% EQU 1 (
  echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
) else (
  if exist "%ps%" (
    %psc% write-host -back '%1' -fore '%2' '%3' -NoNewline; write-host -back '%4' -fore '%5' '%6'
  ) else (
    echo %~3 %~6
  )
)
exit /b

:: LEAVE EMPTY BLANK HERE