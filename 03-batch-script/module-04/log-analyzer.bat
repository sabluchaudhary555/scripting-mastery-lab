@echo off
:: ============================================
:: project  : log-analyzer.bat
:: purpose  : scan any log file and generate
::            a clean summary report
:: usage    : log-analyzer.bat C:\path\to\app.log
::            OR double-click and paste log path
:: ============================================

set LOGFILE=%1

:: if no file passed, ask for it
if "%LOGFILE%"=="" (
    set /p LOGFILE=Enter path to log file: 
)

:: strip quotes if user pasted with them
set LOGFILE=%LOGFILE:"=%

:: check the log file exists
if not exist "%LOGFILE%" (
    echo [ERROR] Log file not found: %LOGFILE%
    echo Make sure the path is correct.
    pause
    exit /b
)

:: setup report file next to the log
for %%I in ("%LOGFILE%") do set LOGDIR=%%~dpI
for %%I in ("%LOGFILE%") do set LOGNAME=%%~nI
set REPORT=%LOGDIR%%LOGNAME%_report.txt

:: get current timestamp
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set dt=%%I
set TIMESTAMP=%dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%

echo.
echo Analyzing: %LOGFILE%
echo Report  : %REPORT%
echo.

:: ---- start writing the report ----
echo ============================================ > "%REPORT%"
echo  LOG ANALYSIS REPORT >> "%REPORT%"
echo  File    : %LOGFILE% >> "%REPORT%"
echo  Date    : %TIMESTAMP% >> "%REPORT%"
echo ============================================ >> "%REPORT%"
echo. >> "%REPORT%"

:: ---- section 1: file stats ----
echo [1/5] Counting lines...
echo --- FILE STATS ---------------------------------------- >> "%REPORT%"

for /f %%A in ('find /c "" "%LOGFILE%"') do set TOTAL=%%A
echo Total lines : %TOTAL% >> "%REPORT%"
echo Total lines : %TOTAL%

echo. >> "%REPORT%"

:: ---- section 2: error count ----
echo [2/5] Counting errors...
echo --- SEVERITY COUNTS ----------------------------------- >> "%REPORT%"

for /f "tokens=3" %%A in ('find /c /i "error" "%LOGFILE%"') do set ERRORS=%%A
for /f "tokens=3" %%A in ('find /c /i "warning" "%LOGFILE%"') do set WARNS=%%A
for /f "tokens=3" %%A in ('find /c /i "critical" "%LOGFILE%"') do set CRITS=%%A
for /f "tokens=3" %%A in ('find /c /i "info" "%LOGFILE%"') do set INFOS=%%A

echo CRITICAL : %CRITS% >> "%REPORT%"
echo ERROR    : %ERRORS% >> "%REPORT%"
echo WARNING  : %WARNS% >> "%REPORT%"
echo INFO     : %INFOS% >> "%REPORT%"
echo.
echo CRITICAL : %CRITS%
echo ERROR    : %ERRORS%
echo WARNING  : %WARNS%
echo INFO     : %INFOS%

echo. >> "%REPORT%"

:: ---- section 3: all error lines ----
echo [3/5] Extracting error lines...
echo --- ERROR LINES --------------------------------------- >> "%REPORT%"
find /n /i "error" "%LOGFILE%" >> "%REPORT%"
echo. >> "%REPORT%"

:: ---- section 4: all warning lines ----
echo [4/5] Extracting warning lines...
echo --- WARNING LINES ------------------------------------- >> "%REPORT%"
find /n /i "warning" "%LOGFILE%" >> "%REPORT%"
echo. >> "%REPORT%"

:: ---- section 5: critical lines ----
echo [5/5] Extracting critical lines...
echo --- CRITICAL LINES ------------------------------------ >> "%REPORT%"
find /n /i "critical" "%LOGFILE%" >> "%REPORT%"
echo. >> "%REPORT%"

:: ---- footer ----
echo ============================================ >> "%REPORT%"
echo  Analysis complete: %TIMESTAMP% >> "%REPORT%"
echo ============================================ >> "%REPORT%"

echo.
echo ============================================
echo  Done! Report saved to:
echo  %REPORT%
echo ============================================
echo.
pause