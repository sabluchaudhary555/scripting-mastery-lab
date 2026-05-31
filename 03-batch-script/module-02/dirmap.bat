@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: dirmap.bat — interactive directory explorer and file finder
::
:: the thing I actually wanted when learning CMD navigation.
:: browse folders, find files by name or extension, see sizes,
:: jump to common Windows locations, and keep a "visited" history
:: so you can hop back to anywhere you've been this session.
::
:: usage:
::   dirmap                    launch interactive explorer
::   dirmap find *.log         find files by pattern
::   dirmap find report 30     find files modified in last 30 days
::   dirmap size C:\Users      show folder sizes
::   dirmap go desktop         jump to a named location
::   dirmap tree C:\Projects   show visual folder tree
:: ============================================================

title dirmap — Directory Explorer
color 0B

set VERSION=1.0
set HISTORY_FILE=%TEMP%\dirmap_history.txt
set MAX_HISTORY=20

:: make sure history file exists
if not exist "%HISTORY_FILE%" type nul > "%HISTORY_FILE%"

:: ── dispatch ──────────────────────────────────────────────────────────────────

set CMD=%~1

if "%CMD%"==""      goto :interactive
if "%CMD%"=="find"  goto :cmd_find
if "%CMD%"=="size"  goto :cmd_size
if "%CMD%"=="go"    goto :cmd_go
if "%CMD%"=="tree"  goto :cmd_tree
if "%CMD%"=="hist"  goto :cmd_history
if "%CMD%"=="help"  goto :show_help
if "%CMD%"=="-h"    goto :show_help

echo Unknown command: %CMD%
echo Run: dirmap help
exit /b 1

:: ── help ──────────────────────────────────────────────────────────────────────

:show_help
echo.
echo  dirmap v%VERSION% -- directory explorer and file finder
echo  ────────────────────────────────────────────────────────
echo.
echo  dirmap                        launch interactive explorer
echo  dirmap find ^<pattern^>          find files matching name/extension
echo  dirmap find ^<pattern^> ^<days^>   find files modified in last N days
echo  dirmap size ^<path^>             show size of each subfolder
echo  dirmap go ^<name^>               jump to a shortcut location
echo  dirmap tree ^<path^>             visual folder tree with file count
echo  dirmap hist                   show navigation history this session
echo.
echo  shortcut names for "go":
echo    desktop  documents  downloads  appdata  temp
echo    windows  system32   programs   root     home
echo.
exit /b 0

:: ── interactive mode ──────────────────────────────────────────────────────────

:interactive
cls
echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║           dirmap v%VERSION% — directory explorer          ║
echo  ╚══════════════════════════════════════════════════════╝
echo.

:interactive_loop
:: show current location and a clean listing
echo  Location: %CD%
echo  ──────────────────────────────────────────────────────
echo.

:: show folders first
set dir_count=0
for /d %%d in (*) do (
    echo    [DIR]  %%d
    set /a dir_count+=1
)

:: then files
set file_count=0
for %%f in (*) do (
    :: skip if it's showing a folder name somehow
    if not exist "%%f\" (
        :: get size nicely
        set sz=%%~zf
        if !sz! gtr 1048576 (
            set /a sz_mb=!sz! / 1048576
            echo    !sz_mb! MB   %%f
        ) else if !sz! gtr 1024 (
            set /a sz_kb=!sz! / 1024
            echo    !sz_kb! KB   %%f
        ) else (
            echo    !sz! B    %%f
        )
        set /a file_count+=1
    )
)

echo.
echo  %dir_count% folder(s)   %file_count% file(s)
echo.
echo  Commands: cd ^<folder^>  ^|  cd ..  ^|  d: (drive)  ^|  q (quit)
echo            find ^<*.ext^>  ^|  size  ^|  tree  ^|  hist  ^|  go ^<name^>
echo.

set /p nav= Navigate: 

:: handle quit
if /i "%nav%"=="q"    goto :interactive_quit
if /i "%nav%"=="quit" goto :interactive_quit
if /i "%nav%"=="exit" goto :interactive_quit

:: handle hist
if /i "%nav%"=="hist" (
    call :cmd_history
    goto :interactive_loop
)

:: handle size
if /i "%nav%"=="size" (
    call :cmd_size "%CD%"
    echo.
    pause
    goto :interactive_loop
)

:: handle tree
if /i "%nav%"=="tree" (
    tree /f /a 2>nul | more
    echo.
    pause
    goto :interactive_loop
)

:: handle cls
if /i "%nav%"=="cls" (
    cls
    goto :interactive_loop
)

:: handle find *.ext
set first_word=%nav:~0,4%
if /i "!first_word!"=="find" (
    set find_arg=%nav:~5%
    call :cmd_find !find_arg!
    echo.
    pause
    goto :interactive_loop
)

:: handle go <name>
set first_word=%nav:~0,2%
if /i "!first_word!"=="go" (
    set go_arg=%nav:~3%
    call :cmd_go !go_arg!
    goto :interactive_loop
)

:: handle drive switch (D: or D)
echo %nav% | findstr /r "^[A-Za-z]:*$" >nul 2>&1
if %errorlevel%==0 (
    :: add colon if missing
    set drive_input=%nav%
    if "!drive_input:~1!"=="" set drive_input=!drive_input!:
    call :save_history "%CD%"
    !drive_input! 2>nul
    if %errorlevel% NEQ 0 echo  Drive not found: !drive_input!
    goto :interactive_loop
)

:: everything else — treat as a cd command
if not "%nav%"=="" (
    call :save_history "%CD%"
    cd %nav% 2>nul
    if %errorlevel% NEQ 0 (
        echo  Cannot navigate to: %nav%
        :: restore last location from history
    )
)

goto :interactive_loop

:interactive_quit
echo.
echo  Goodbye. Final location: %CD%
echo.
exit /b 0

:: ── find files ────────────────────────────────────────────────────────────────

:cmd_find
set PATTERN=%~2
set DAYS=%~3
set SEARCH_ROOT=%CD%

if "%PATTERN%"=="" (
    set /p PATTERN= Search pattern (e.g. *.log or report): 
)

echo.
echo  Searching for "%PATTERN%" in %SEARCH_ROOT%
if not "%DAYS%"=="" echo  Modified in last %DAYS% days
echo  ──────────────────────────────────────────────────────
echo.

set found=0

if not "%DAYS%"=="" (
    :: find files by name AND modified within N days
    for /f "tokens=* delims=" %%f in ('dir /s /b "%SEARCH_ROOT%\%PATTERN%" 2^>nul') do (
        :: check modification date — use forfiles which supports /d
        forfiles /p "%%~dpf" /m "%%~nxf" /d -%DAYS% /c "cmd /c echo   %%p" 2>nul
        set /a found+=1
    )
) else (
    :: find by name only — recursive
    set found=0
    for /f "tokens=* delims=" %%f in ('dir /s /b "%SEARCH_ROOT%\%PATTERN%" 2^>nul') do (
        set filepath=%%f
        :: get file size
        set sz=%%~zf
        set /a sz_kb=!sz! / 1024
        echo   !sz_kb! KB   %%f
        set /a found+=1
    )
)

echo.
if %found%==0 (
    echo  No files found matching "%PATTERN%"
) else (
    echo  Found: %found% file(s)
)

goto :eof

:: ── folder sizes ──────────────────────────────────────────────────────────────

:cmd_size
set SIZE_PATH=%~2
if "%SIZE_PATH%"=="" set SIZE_PATH=%CD%

echo.
echo  Folder sizes in: %SIZE_PATH%
echo  ──────────────────────────────────────────────────────

:: use pushd so we come back to original dir after
pushd "%SIZE_PATH%" 2>nul
if %errorlevel% NEQ 0 (
    echo  Cannot access: %SIZE_PATH%
    goto :eof
)

for /d %%d in (*) do (
    :: get total size of each subfolder using dir /s
    set total=0
    for /f "tokens=3 delims= " %%s in ('dir /s "%%d" 2^>nul ^| findstr /c:"File(s)"') do (
        set raw=%%s
        set raw=!raw:,=!
        set total=!raw!
    )
    set /a total_mb=!total! / 1048576
    echo   !total_mb! MB   %%d
)

popd
echo.
goto :eof

:: ── quick jump to common locations ───────────────────────────────────────────

:cmd_go
set DEST=%~2
if "%DEST%"=="" set DEST=%~1

:: save current location before jumping
call :save_history "%CD%"

if /i "%DEST%"=="desktop"   ( cd /d "%USERPROFILE%\Desktop"                    & goto :go_done )
if /i "%DEST%"=="documents" ( cd /d "%USERPROFILE%\Documents"                  & goto :go_done )
if /i "%DEST%"=="downloads" ( cd /d "%USERPROFILE%\Downloads"                  & goto :go_done )
if /i "%DEST%"=="appdata"   ( cd /d "%APPDATA%"                                & goto :go_done )
if /i "%DEST%"=="temp"      ( cd /d "%TEMP%"                                   & goto :go_done )
if /i "%DEST%"=="windows"   ( cd /d "%WINDIR%"                                 & goto :go_done )
if /i "%DEST%"=="system32"  ( cd /d "%WINDIR%\System32"                        & goto :go_done )
if /i "%DEST%"=="programs"  ( cd /d "%ProgramFiles%"                           & goto :go_done )
if /i "%DEST%"=="root"      ( cd /d C:\                                        & goto :go_done )
if /i "%DEST%"=="home"      ( cd /d "%USERPROFILE%"                            & goto :go_done )

echo  Unknown shortcut: %DEST%
echo  Available: desktop documents downloads appdata temp windows system32 programs root home
goto :eof

:go_done
echo  Jumped to: %CD%
goto :eof

:: ── tree with file count ──────────────────────────────────────────────────────

:cmd_tree
set TREE_PATH=%~2
if "%TREE_PATH%"=="" set TREE_PATH=%CD%

echo.
echo  Folder tree: %TREE_PATH%
echo  ──────────────────────────────────────────────────────
tree "%TREE_PATH%" /f /a 2>nul

:: count files and folders as a summary
set fc=0
set dc=0
for /f %%i in ('dir /s /b /a-d "%TREE_PATH%" 2^>nul ^| find /c /v ""') do set fc=%%i
for /f %%i in ('dir /s /b /ad  "%TREE_PATH%" 2^>nul ^| find /c /v ""') do set dc=%%i

echo.
echo  Total: %fc% file(s) in %dc% folder(s)
goto :eof

:: ── navigation history ────────────────────────────────────────────────────────

:save_history
:: append to history file, keep last MAX_HISTORY entries
echo %~1 >> "%HISTORY_FILE%"

:: trim to last MAX_HISTORY lines
set tmp=%TEMP%\dirmap_hist_tmp.txt
if exist "%tmp%" del "%tmp%"
set lcount=0
for /f "tokens=* delims=" %%line in (%HISTORY_FILE%) do set /a lcount+=1

if %lcount% gtr %MAX_HISTORY% (
    set /a skip=%lcount% - %MAX_HISTORY%
    set i=0
    for /f "tokens=* delims=" %%line in (%HISTORY_FILE%) do (
        set /a i+=1
        if !i! gtr !skip! echo %%line >> "%tmp%"
    )
    move /y "%tmp%" "%HISTORY_FILE%" >nul
)
goto :eof

:cmd_history
echo.
echo  Navigation history this session:
echo  ──────────────────────────────────────────────────────
if not exist "%HISTORY_FILE%" (
    echo  No history yet.
    goto :eof
)

set idx=0
for /f "tokens=* delims=" %%line in (%HISTORY_FILE%) do (
    set /a idx+=1
    echo   !idx!.  %%line
)
if %idx%==0 echo  No history yet.
echo.
goto :eof