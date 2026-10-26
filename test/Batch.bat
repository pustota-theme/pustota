@echo off
rem Batch file example
:: Comment with double colon
setlocal enabledelayedexpansion

rem Variables
set NAME=World
set /a COUNT=1 + 2 * 3
set /p INPUT=Enter value: 
set "QUOTED=value with spaces"
echo Hello, %NAME%!
echo Count is !COUNT!
echo Script dir: %~dp0
echo First arg: %1, all args: %*

rem Conditionals
if "%NAME%"=="World" (
    echo Matched
) else (
    echo Not matched
)

if not exist "output" mkdir output
if defined NAME echo NAME is set
if %COUNT% GEQ 5 echo Big
if /i "%INPUT%" EQU "yes" goto :confirmed
if errorlevel 1 echo Failed

rem Loops
for %%i in (1 2 3) do echo %%i
for /l %%n in (1, 1, 5) do (
    echo Number %%n
)
for /f "tokens=1,2 delims=," %%a in (data.csv) do echo %%a - %%b
for /d %%d in (*) do echo Folder %%d
for /r %%f in (*.txt) do echo File %%f

rem Labels and calls
call :greet "Ann"
goto :eof

:greet
echo Hello, %~1
exit /b 0

:confirmed
echo Confirmed

rem Redirection and pipes
dir /b > files.txt 2>&1
type files.txt | find "txt" >> found.txt
echo ok && echo success || echo failure
copy nul empty.txt >nul

endlocal
exit /b %ERRORLEVEL%
