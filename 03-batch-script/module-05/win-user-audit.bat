@echo off
:: ============================================================
:: win-user-audit.bat
:: Simple Windows User & Permission Audit Script
:: Author: sabluchaudhary555
:: ============================================================

set REPORT=audit_report.txt
set DIVIDER=------------------------------------------------------------

echo Starting audit... > %REPORT%
echo Report Generated: %date% %time% >> %REPORT%
echo. >> %REPORT%


:: ---- 1. Current User Info ----
echo %DIVIDER% >> %REPORT%
echo [1] CURRENT USER >> %REPORT%
echo %DIVIDER% >> %REPORT%
whoami >> %REPORT%
echo. >> %REPORT%

whoami /all >> %REPORT%
echo. >> %REPORT%


:: ---- 2. All Local Users ----
echo %DIVIDER% >> %REPORT%
echo [2] ALL LOCAL USERS >> %REPORT%
echo %DIVIDER% >> %REPORT%
net user >> %REPORT%
echo. >> %REPORT%


:: ---- 3. Users in Administrators Group ----
echo %DIVIDER% >> %REPORT%
echo [3] ADMINISTRATORS GROUP MEMBERS >> %REPORT%
echo %DIVIDER% >> %REPORT%
net localgroup Administrators >> %REPORT%
echo. >> %REPORT%


:: ---- 4. All Local Groups ----
echo %DIVIDER% >> %REPORT%
echo [4] ALL LOCAL GROUPS >> %REPORT%
echo %DIVIDER% >> %REPORT%
net localgroup >> %REPORT%
echo. >> %REPORT%


:: ---- 5. Password Policy ----
echo %DIVIDER% >> %REPORT%
echo [5] PASSWORD POLICY >> %REPORT%
echo %DIVIDER% >> %REPORT%
net accounts >> %REPORT%
echo. >> %REPORT%


:: ---- 6. Current User Privileges ----
echo %DIVIDER% >> %REPORT%
echo [6] CURRENT USER PRIVILEGES >> %REPORT%
echo %DIVIDER% >> %REPORT%
whoami /priv >> %REPORT%
echo. >> %REPORT%


:: ---- 7. Check Dangerous Privileges ----
echo %DIVIDER% >> %REPORT%
echo [7] DANGEROUS PRIVILEGE CHECK >> %REPORT%
echo %DIVIDER% >> %REPORT%

whoami /priv | findstr /i "SeDebugPrivilege" > nul
if %errorlevel%==0 (
    echo [WARNING] SeDebugPrivilege is ENABLED >> %REPORT%
) else (
    echo [OK] SeDebugPrivilege not present >> %REPORT%
)

whoami /priv | findstr /i "SeImpersonatePrivilege" > nul
if %errorlevel%==0 (
    echo [WARNING] SeImpersonatePrivilege is ENABLED >> %REPORT%
) else (
    echo [OK] SeImpersonatePrivilege not present >> %REPORT%
)

whoami /priv | findstr /i "SeTakeOwnershipPrivilege" > nul
if %errorlevel%==0 (
    echo [WARNING] SeTakeOwnershipPrivilege is ENABLED >> %REPORT%
) else (
    echo [OK] SeTakeOwnershipPrivilege not present >> %REPORT%
)
echo. >> %REPORT%


:: ---- 8. UAC Status ----
echo %DIVIDER% >> %REPORT%
echo [8] UAC STATUS >> %REPORT%
echo %DIVIDER% >> %REPORT%
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA >> %REPORT% 2>&1
echo. >> %REPORT%


:: ---- 9. Permissions on Common Folders ----
echo %DIVIDER% >> %REPORT%
echo [9] PERMISSIONS ON SENSITIVE FOLDERS >> %REPORT%
echo %DIVIDER% >> %REPORT%

echo -- C:\ProgramData -- >> %REPORT%
icacls C:\ProgramData >> %REPORT%
echo. >> %REPORT%

echo -- C:\Program Files -- >> %REPORT%
icacls "C:\Program Files" >> %REPORT%
echo. >> %REPORT%

echo -- C:\Windows\Temp -- >> %REPORT%
icacls C:\Windows\Temp >> %REPORT%
echo. >> %REPORT%


:: ---- 10. Stored Credentials ----
echo %DIVIDER% >> %REPORT%
echo [10] STORED CREDENTIALS (cmdkey) >> %REPORT%
echo %DIVIDER% >> %REPORT%
cmdkey /list >> %REPORT%
echo. >> %REPORT%


:: ---- 11. Scheduled Tasks Running as SYSTEM ----
echo %DIVIDER% >> %REPORT%
echo [11] SCHEDULED TASKS RUNNING AS SYSTEM >> %REPORT%
echo %DIVIDER% >> %REPORT%
schtasks /query /fo LIST /v | findstr /i "Run As User" >> %REPORT%
echo. >> %REPORT%


:: ---- 12. AlwaysInstallElevated Check ----
echo %DIVIDER% >> %REPORT%
echo [12] ALWAYSINSTALLELEVATED CHECK >> %REPORT%
echo %DIVIDER% >> %REPORT%

reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated >> %REPORT% 2>&1
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated >> %REPORT% 2>&1
echo. >> %REPORT%


:: ---- Done ----
echo %DIVIDER% >> %REPORT%
echo Audit Complete. >> %REPORT%
echo %DIVIDER% >> %REPORT%

echo.
echo Done. Report saved to: %REPORT%
echo Open it with: notepad %REPORT%
pause