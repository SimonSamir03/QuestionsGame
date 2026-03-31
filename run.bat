@echo off
chcp 65001 >nul
title BrainPlay
color 0A
set PATH=C:\flutter\bin;%PATH%

echo ============================================
echo    BrainPlay
echo ============================================
echo   1. Build APK
echo   2. Run on device
echo   3. Build + Install on device
echo   4. Run on Chrome
echo   5. Flutter Doctor
echo ============================================
set /p c="Choose (1-5): "

if "%c%"=="1" flutter build apk --release && copy "build\app\outputs\flutter-apk\app-release.apk" "%USERPROFILE%\Desktop\BrainPlay.apk" && echo Done! APK on Desktop
if "%c%"=="2" flutter run --release
if "%c%"=="3" flutter build apk --release && flutter install --release
if "%c%"=="4" flutter run -d chrome
if "%c%"=="5" flutter doctor -v

pause
