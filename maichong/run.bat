@echo off
REM 脉冲 (MaiChong) - Design Preview Script
REM Run this to preview the new modern design inspired by Doubao and Qianwen

echo ========================================
echo   MaiChong Design Preview
echo   Modern AI Assistant Style
echo ========================================
echo.

REM Check if Flutter is available
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter not found in PATH
    echo Please install Flutter or add it to your PATH
    echo.
    echo Download from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [1/3] Getting Flutter packages...
call flutter pub get

echo.
echo [2/3] Analyzing code...
call flutter analyze --no-fatal-infos

echo.
echo [3/3] Starting web preview...
echo.
echo App will open at: http://localhost:8082
echo Press Ctrl+C to stop the server
echo.
call flutter run -d chrome --web-port 8082

pause
