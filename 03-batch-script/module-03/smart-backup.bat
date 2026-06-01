@echo off
:: ============================================
:: project  : smart-backup.bat
:: purpose  : organize and backup your files
::            by type into dated folders
:: usage    : drag a folder onto this .bat file
::            OR run: smart-backup.bat C:\MyFiles
:: ============================================

set SOURCE=%1

:: if no folder was passed, ask for it
if "%SOURCE%"=="" (
    set /p SOURCE=Enter folder path to backup: 
)

:: check if folder actually exists
if not exist "%SOURCE%" (
    echo [ERROR] Folder not found: %SOURCE%
    pause
    exit /b
)

:: get today's date for backup folder name (YYYY-MM-DD format)
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set dt=%%I
set TODAY=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%

:: backup destination — creates next to source folder
set DEST=%~dp1Backup_%TODAY%

echo.
echo Source  : %SOURCE%
echo Dest    : %DEST%
echo Date    : %TODAY%
echo.

:: create category folders
mkdir "%DEST%\Documents" 2>nul
mkdir "%DEST%\Images" 2>nul
mkdir "%DEST%\Videos" 2>nul
mkdir "%DEST%\Code" 2>nul
mkdir "%DEST%\Others" 2>nul

echo Sorting files...
echo.

:: copy documents
for %%f in ("%SOURCE%\*.pdf" "%SOURCE%\*.docx" "%SOURCE%\*.txt" "%SOURCE%\*.xlsx" "%SOURCE%\*.pptx") do (
    if exist "%%f" (
        copy "%%f" "%DEST%\Documents\" >nul
        echo [DOC]    %%~nxf
    )
)

:: copy images
for %%f in ("%SOURCE%\*.jpg" "%SOURCE%\*.jpeg" "%SOURCE%\*.png" "%SOURCE%\*.gif" "%SOURCE%\*.bmp") do (
    if exist "%%f" (
        copy "%%f" "%DEST%\Images\" >nul
        echo [IMG]    %%~nxf
    )
)

:: copy videos
for %%f in ("%SOURCE%\*.mp4" "%SOURCE%\*.avi" "%SOURCE%\*.mkv" "%SOURCE%\*.mov") do (
    if exist "%%f" (
        copy "%%f" "%DEST%\Videos\" >nul
        echo [VID]    %%~nxf
    )
)

:: copy code files
for %%f in ("%SOURCE%\*.py" "%SOURCE%\*.js" "%SOURCE%\*.html" "%SOURCE%\*.css" "%SOURCE%\*.java" "%SOURCE%\*.cpp" "%SOURCE%\*.bat") do (
    if exist "%%f" (
        copy "%%f" "%DEST%\Code\" >nul
        echo [CODE]   %%~nxf
    )
)

:: everything else goes to Others
for %%f in ("%SOURCE%\*.*") do (
    if exist "%%f" (
        :: only copy if it wasn't already sorted
        if not exist "%DEST%\Documents\%%~nxf" (
        if not exist "%DEST%\Images\%%~nxf" (
        if not exist "%DEST%\Videos\%%~nxf" (
        if not exist "%DEST%\Code\%%~nxf" (
            copy "%%f" "%DEST%\Others\" >nul
            echo [OTHER]  %%~nxf
        ))))
    )
)

:: write a log file inside the backup
echo Backup created on %TODAY% > "%DEST%\backup_log.txt"
echo Source: %SOURCE% >> "%DEST%\backup_log.txt"
echo. >> "%DEST%\backup_log.txt"
dir "%DEST%" /s /b >> "%DEST%\backup_log.txt"

echo.
echo ============================================
echo  Backup done! Saved to:
echo  %DEST%
echo ============================================
echo.
pause