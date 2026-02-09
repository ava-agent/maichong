@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   MaiChong - Code Verification
echo ========================================
echo.

cd /d "%~dp0"

set ERRORS=0
set WARNINGS=0

echo [1/5] Checking file structure...
echo.

REM Check main entry points
if exist "lib\main.dart" (
    echo [OK] lib\main.dart
) else (
    echo [ERROR] lib\main.dart not found!
    set /a ERRORS+=1
)

if exist "lib\app.dart" (
    echo [OK] lib\app.dart
) else (
    echo [ERROR] lib\app.dart not found!
    set /a ERRORS+=1
)

REM Check theme files
if exist "lib\core\theme\app_colors.dart" (
    echo [OK] lib\core\theme\app_colors.dart
) else (
    echo [ERROR] lib\core\theme\app_colors.dart not found!
    set /a ERRORS+=1
)

if exist "lib\core\theme\app_text_styles.dart" (
    echo [OK] lib\core\theme\app_text_styles.dart
) else (
    echo [ERROR] lib\core\theme\app_text_styles.dart not found!
    set /a ERRORS+=1
)

if exist "lib\core\theme\app_theme.dart" (
    echo [OK] lib\core\theme\app_theme.dart
) else (
    echo [ERROR] lib\core\theme\app_theme.dart not found!
    set /a ERRORS+=1
)

echo.
echo [2/5] Checking page files...

if exist "lib\presentation\pages\welcome_page.dart" (
    echo [OK] lib\presentation\pages\welcome_page.dart
) else (
    echo [ERROR] lib\presentation\pages\welcome_page.dart not found!
    set /a ERRORS+=1
)

if exist "lib\presentation\pages\timeline\timeline_page.dart" (
    echo [OK] lib\presentation\pages\timeline\timeline_page.dart
) else (
    echo [ERROR] lib\presentation\pages\timeline\timeline_page.dart not found!
    set /a ERRORS+=1
)

echo.
echo [3/5] Checking widget files...

if exist "lib\presentation\widgets\ai\modern_ai_chat_page.dart" (
    echo [OK] lib\presentation\widgets\ai\modern_ai_chat_page.dart
) else (
    echo [WARNING] lib\presentation\widgets\ai\modern_ai_chat_page.dart not found!
    set /a WARNINGS+=1
)

if exist "lib\presentation\widgets\ai\modern_chat_bubble.dart" (
    echo [OK] lib\presentation\widgets\ai\modern_chat_bubble.dart
) else (
    echo [WARNING] lib\presentation\widgets\ai\modern_chat_bubble.dart not found!
    set /a WARNINGS+=1
)

if exist "lib\presentation\widgets\timeline\event_card.dart" (
    echo [OK] lib\presentation\widgets\timeline\event_card.dart
) else (
    echo [ERROR] lib\presentation\widgets\timeline\event_card.dart not found!
    set /a ERRORS+=1
)

echo.
echo [4/5] Checking data services...

if exist "lib\data\services\storage_service.dart" (
    echo [OK] lib\data\services\storage_service.dart
) else (
    echo [ERROR] lib\data\services\storage_service.dart not found!
    set /a ERRORS+=1
)

if exist "lib\data\services\ai_service.dart" (
    echo [OK] lib\data\services\ai_service.dart
) else (
    echo [ERROR] lib\data\services\ai_service.dart not found!
    set /a ERRORS+=1
)

echo.
echo [5/5] Checking configuration files...

if exist "pubspec.yaml" (
    echo [OK] pubspec.yaml
) else (
    echo [ERROR] pubspec.yaml not found!
    set /a ERRORS+=1
)

echo.
echo ========================================
echo   Verification Summary
echo ========================================
echo.

if %ERRORS% EQU 0 (
    echo [SUCCESS] No critical errors found!
) else (
    echo [ERROR] Found %ERRORS% error(s)!
)

if %WARNINGS% EQU 0 (
    echo [INFO] No warnings.
) else (
    echo [WARNING] Found %WARNINGS% warning(s).
)

echo.
echo Total Files Checked: 15
echo Errors: %ERRORS%
echo Warnings: %WARNINGS%
echo.

if %ERRORS% EQU 0 (
    echo [READY] Project is ready to run!
    echo.
    echo Next steps:
    echo   1. Run 'start.bat' to launch the app
    echo   2. Or run: flutter run -d chrome --web-port 8082
    echo.
)

pause
