@echo off
@REM Change DEVICE_ID to your connected device id (adb devices -l)
SET DEVICE_ID="0"

@REM Prevents changes to build.bat, "git update-index --no-assume-unchanged build.bat" to undo
git update-index --assume-unchanged build.bat



IF %DEVICE_ID% == "0" goto :fail
SET RELEASE_PATH=%~dp0build\app\outputs\bundle\release
CALL flutter pub get
CALL flutter build appbundle
IF EXIST "%RELEASE_PATH%\app-release.apks" DEL /F "%RELEASE_PATH%\app-release.apks"
java -jar bundletool-all-1.14.1.jar build-apks --connected-device --bundle=%RELEASE_PATH%/app-release.aab --output=%RELEASE_PATH%/app-release.apks --device-id=%DEVICE_ID%
java -jar bundletool-all-1.14.1.jar install-apks --apks=%RELEASE_PATH%/app-release.apks --device-id=%DEVICE_ID%
echo Build installed.
EXIT /B 0

:fail
echo Set DEVICE_ID in %~dp0build.bat
CALL adb devices -l
EXIT /B 1
