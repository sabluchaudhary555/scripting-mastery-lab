@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: syscheck.bat — instant Windows system snapshot
::
:: gives you everything useful about the current machine
:: in one screen. useful when you sit down at an unfamiliar PC,
:: RDP into a server, or just want to know what's going on.
::
:: no admin required for most checks.
:: run as admin to unlock the extra sections.
::
:: usage:
::   syscheck             run all checks
::   syscheck net         network info only
::   syscheck disk        disk usage only
::   syscheck users       logged-in users and accounts
::   syscheck admin       full check (run as admin)
:: ============================================================

title System Check — %COMPUTERNAME%
color 0A

set VERSION=1.0
set SECTION=%~1

:: figure out if we are running as admin
set IS_ADMIN=0
net session >nul 2>&1
if %errorlevel%==0 set IS_ADMIN=1

:: ── dispatch ──────────────────────────────────────────────────────────────────

if "%SECTION%"=="net"   goto :section_network
if "%SECTION%"=="disk"  goto :section_disk
if "%SECTION%"=="users" goto :section_users
if "%SECTION%"=="admin" goto :run_all
if "%SECTION%"==""      goto :run_all

echo Unknown section: %SECTION%
echo Usage: syscheck [net^|disk^|users^|admin]
exit /b 1

:: ── helpers ───────────────────────────────────────────────────────────────────

:header
echo.
echo  ══ %~1 ═══════════════════════════════════════════════
goto :eof

:dim_line
echo  %~1
goto :eof

:warn_line
echo  [!] %~1
goto :eof

:: ── run all sections ──────────────────────────────────────────────────────────

:run_all
cls
echo.
echo  ┌────────────────────────────────────────────────────┐
echo  │            syscheck v%VERSION% — system snapshot          │
echo  └────────────────────────────────────────────────────┘
echo  machine  : %COMPUTERNAME%
echo  user     : %USERNAME%
echo  time     : %DATE%  %TIME:~0,8%
echo  admin    : %IS_ADMIN% (1=yes 0=no)
echo  path     : %CD%

call :section_os
call :section_network
call :section_disk
call :section_processes
call :section_users

if %IS_ADMIN%==1 (
    call :section_admin_only
) else (
    echo.
    echo  [i] run as Administrator to see: startup items, open ports, scheduled tasks
)

echo.
echo  ════════════════════════════════════════════════════════
echo  done. press any key to exit.
pause >nul
exit /b 0

:: ── section: OS & hardware ────────────────────────────────────────────────────

:section_os
call :header "OS   ^&  HARDWARE"

:: windows version
for /f "tokens=* skip=1" %%i in ('wmic os get Caption /format:list 2^>nul') do (
    if not "%%i"=="" echo  OS       : %%i
)

:: architecture
for /f "tokens=* skip=1" %%i in ('wmic os get OSArchitecture /format:list 2^>nul') do (
    if not "%%i"=="" echo  Arch     : %%i
)

:: uptime (last boot time)
for /f "tokens=* skip=1" %%i in ('wmic os get LastBootUpTime /format:list 2^>nul') do (
    if not "%%i"=="" (
        set raw=%%i
        set raw=!raw:LastBootUpTime=!
        set raw=!raw:~0,4!-!raw:~4,2!-!raw:~6,2! !raw:~8,2!:!raw:~10,2!
        echo  Last boot: !raw!
    )
)

:: RAM total
for /f "tokens=* skip=1" %%i in ('wmic ComputerSystem get TotalPhysicalMemory /format:list 2^>nul') do (
    if not "%%i"=="" (
        set raw=%%i
        set raw=!raw:TotalPhysicalMemory=!
        set /a ram_gb=!raw! / 1073741824
        echo  RAM      : !ram_gb! GB
    )
)

:: CPU name
for /f "tokens=* skip=1" %%i in ('wmic cpu get Name /format:list 2^>nul') do (
    if not "%%i"=="" echo  CPU      : %%i
)

goto :eof

:: ── section: network ─────────────────────────────────────────────────────────

:section_network
call :header "NETWORK"

:: IP addresses — ipconfig, grab IPv4 lines
echo  IP addresses:
ipconfig | findstr /i "IPv4" | findstr /v "127.0.0.1" > %TEMP%\ips.tmp
for /f "tokens=* delims=" %%line in (%TEMP%\ips.tmp) do echo    %%line
del %TEMP%\ips.tmp >nul 2>&1

:: default gateway
echo  Default gateway:
ipconfig | findstr /i "Default Gateway" | findstr /v "0.0.0.0" > %TEMP%\gw.tmp
for /f "tokens=* delims=" %%line in (%TEMP%\gw.tmp) do echo    %%line
del %TEMP%\gw.tmp >nul 2>&1

:: DNS servers
echo  DNS:
ipconfig | findstr /i "DNS Servers" > %TEMP%\dns.tmp
for /f "tokens=* delims=" %%line in (%TEMP%\dns.tmp) do echo    %%line
del %TEMP%\dns.tmp >nul 2>&1

:: quick connectivity check — ping the gateway silently
ping -n 1 8.8.8.8 >nul 2>&1
if %errorlevel%==0 (
    echo  Internet : reachable
) else (
    call :warn_line "Internet : NOT reachable"
)

:: hostname
echo  Hostname : %COMPUTERNAME%

goto :eof

:: ── section: disk usage ───────────────────────────────────────────────────────

:section_disk
call :header "DISK   USAGE"

echo  Drive  Size        Free        Used%%
echo  ─────────────────────────────────────────
for /f "skip=1 tokens=1,2,3" %%a in ('wmic logicaldisk get DeviceID^,Size^,FreeSpace /format:csv 2^>nul') do (
    if not "%%a"=="Node" (
        set drive=%%a
        set free=%%b
        set total=%%c

        if not "!total!"=="" if not "!total!"=="0" (
            set /a free_gb=!free! / 1073741824
            set /a total_gb=!total! / 1073741824
            set /a used_gb=!total_gb! - !free_gb!
            set /a pct=(!used_gb! * 100) / !total_gb!

            :: warn if disk is over 85% full
            if !pct! GTR 85 (
                call :warn_line "!drive!     !total_gb! GB      !free_gb! GB free    !pct!%%  ^<-- low"
            ) else (
                echo   !drive!     !total_gb! GB      !free_gb! GB free    !pct!%%
            )
        )
    )
)

goto :eof

:: ── section: top processes ────────────────────────────────────────────────────

:section_processes
call :header "TOP   PROCESSES  (by memory)"

echo  PID      Mem(KB)    Name
echo  ─────────────────────────────────────────

:: get process list sorted by memory, show top 10
:: tasklist gives us what we need — parse it
set count=0
for /f "skip=3 tokens=1,5" %%a in ('tasklist /fo table /nh 2^>nul ^| sort /r /+65') do (
    if !count! LSS 10 (
        echo   %%a          %%b
        set /a count+=1
    )
)

goto :eof

:: ── section: logged-in users ──────────────────────────────────────────────────

:section_users
call :header "USERS"

echo  Currently logged in:
query user 2>nul | findstr /v "USERNAME" > %TEMP%\users.tmp 2>nul
for /f "tokens=* delims=" %%line in (%TEMP%\users.tmp) do echo    %%line
del %TEMP%\users.tmp >nul 2>&1

:: current user details
echo.
echo  Current user  : %USERNAME%
echo  User profile  : %USERPROFILE%
echo  Computer      : %COMPUTERNAME%

goto :eof

:: ── section: admin-only checks ────────────────────────────────────────────────

:section_admin_only
call :header "ADMIN   CHECKS  (elevated)"

:: open listening ports
echo  Listening ports (local):
netstat -an 2>nul | findstr "LISTENING" | findstr /v "127.0.0.1" > %TEMP%\ports.tmp
set pcount=0
for /f "tokens=* delims=" %%line in (%TEMP%\ports.tmp) do (
    if !pcount! LSS 8 (
        echo    %%line
        set /a pcount+=1
    )
)
if %pcount%==0 echo    none found
del %TEMP%\ports.tmp >nul 2>&1

:: scheduled tasks (active only, top 5)
echo.
echo  Active scheduled tasks (first 5):
set tcount=0
for /f "tokens=1 delims=," %%a in ('schtasks /query /fo csv /nh 2^>nul') do (
    if !tcount! LSS 5 (
        echo    %%a
        set /a tcount+=1
    )
)

:: startup items from registry
echo.
echo  Startup items (HKCU run):
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul | findstr /v "HKEY"

goto :eof