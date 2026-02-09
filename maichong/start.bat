@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   MaiChong - Pulse Assistant
echo   Starting Flutter Web App
echo ========================================
echo.

REM Change to project directory
cd /d "%~dp0"

REM Check if Flutter is in PATH
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Flutter not found in PATH
    echo.
    echo Trying common Flutter locations...

    REM Try common Flutter installation paths
    set FLUTTER_FOUND=0

    if exist "C:\src\flutter\bin\flutter.bat" (
        set "FLUTTER=C:\src\flutter\bin\flutter.bat"
        set FLUTTER_FOUND=1
    )

    if exist "C:\flutter\bin\flutter.bat" (
        set "FLUTTER=C:\flutter\bin\flutter.bat"
        set FLUTTER_FOUND=1
    )

    if exist "%LOCALAPPDATA%\flutter\bin\flutter.bat" (
        set "FLUTTER=%LOCALAPPDATA%\flutter\bin\flutter.bat"
        set FLUTTER_FOUND=1
    )

    if !FLUTTER_FOUND! EQU 0 (
        echo [ERROR] Flutter not found!
        echo.
        echo Please install Flutter or add it to your PATH
        echo Download: https://flutter.dev/docs/get-started/install
        echo.
        pause
        exit /b 1
    )

    echo [INFO] Found Flutter at: !FLUTTER!
    echo.
)

echo [1/4] Cleaning previous build...
if exist "build" (
    rmdir /s /q build 2>nul
)

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo [3/4] Analyzing code...
call flutter analyze --no-fatal-infos
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Some issues found, but continuing...
)

echo.
echo [4/4] Starting web server...
echo.
echo ========================================
echo   App will open at:
echo   http://localhost:8082
echo ========================================
echo.
echo Press Ctrl+C to stop the server
echo.

call flutter run -d chrome --web-port 8082

echo.
echo Application finished.
pause
