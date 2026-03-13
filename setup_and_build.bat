@echo off
chcp 65001 >nul
title BrainPlay - Setup & Build
color 0A

echo ============================================
echo    BrainPlay - Setup and Build Tool
echo ============================================
echo.

:: Check if Flutter is in PATH
where flutter >nul 2>&1
if %errorlevel%==0 (
    set FLUTTER_CMD=flutter
    goto :found
)

:: Check common Flutter locations
if exist "C:\flutter\bin\flutter.bat" (
    set FLUTTER_CMD=C:\flutter\bin\flutter.bat
    goto :found
)
if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set FLUTTER_CMD=%USERPROFILE%\flutter\bin\flutter.bat
    goto :found
)
if exist "C:\src\flutter\bin\flutter.bat" (
    set FLUTTER_CMD=C:\src\flutter\bin\flutter.bat
    goto :found
)
if exist "D:\flutter\bin\flutter.bat" (
    set FLUTTER_CMD=D:\flutter\bin\flutter.bat
    goto :found
)

:: Flutter not found
echo [ERROR] Flutter is not installed or not found!
echo.
echo Please install Flutter first:
echo   1. Go to: https://docs.flutter.dev/get-started/install/windows
echo   2. Download Flutter SDK
echo   3. Extract to C:\flutter
echo   4. Add C:\flutter\bin to your system PATH
echo   5. Run this script again
echo.
pause
exit /b 1

:found
echo [OK] Flutter found: %FLUTTER_CMD%
echo.

:: Show Flutter version
echo Checking Flutter version...
%FLUTTER_CMD% --version
echo.

:: Get dependencies
echo ============================================
echo   Step 1: Getting dependencies...
echo ============================================
%FLUTTER_CMD% pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies!
    pause
    exit /b 1
)
echo [OK] Dependencies ready!
echo.

:: Ask what to do
echo ============================================
echo   What do you want to do?
echo ============================================
echo   1. Build APK (Android)
echo   2. Run on connected device
echo   3. Build APK + Install on device
echo   4. Run on Chrome (Web)
echo   5. Exit
echo ============================================
set /p choice="Enter choice (1-5): "

if "%choice%"=="1" goto :build_apk
if "%choice%"=="2" goto :run_device
if "%choice%"=="3" goto :build_install
if "%choice%"=="4" goto :run_web
if "%choice%"=="5" exit /b 0
goto :found

:build_apk
echo.
echo Building Release APK...
echo This may take a few minutes...
echo.
%FLUTTER_CMD% build apk --release
if %errorlevel%==0 (
    echo.
    echo ============================================
    echo   [SUCCESS] APK Built Successfully!
    echo   Location: build\app\outputs\flutter-apk\app-release.apk
    echo ============================================

    :: Copy APK to Desktop
    copy "build\app\outputs\flutter-apk\app-release.apk" "%USERPROFILE%\Desktop\BrainPlay.apk" >nul 2>&1
    if %errorlevel%==0 (
        echo   Also copied to: Desktop\BrainPlay.apk
    )
) else (
    echo [ERROR] Build failed!
)
echo.
pause
exit /b 0

:run_device
echo.
echo Checking connected devices...
%FLUTTER_CMD% devices
echo.
echo Running on device...
%FLUTTER_CMD% run --release
pause
exit /b 0

:build_install
echo.
echo Building and installing APK...
%FLUTTER_CMD% build apk --release
if %errorlevel%==0 (
    echo.
    echo Installing on device...
    %FLUTTER_CMD% install --release
    echo.
    echo [SUCCESS] App installed on device!
) else (
    echo [ERROR] Build failed!
)
pause
exit /b 0

:run_web
echo.
echo Running on Chrome...
%FLUTTER_CMD% run -d chrome
pause
exit /b 0
