@echo off
@REM requires 7-zip

SET RELEASE_PATH=%~dp0build\app\outputs\bundle\release
CALL flutter pub get
CALL flutter build appbundle
IF EXIST "%RELEASE_PATH%\app-release.apks" DEL /F "%RELEASE_PATH%\app-release.apks"
java -jar bundletool-all-1.14.1.jar build-apks --bundle=%RELEASE_PATH%/app-release.aab --output=%RELEASE_PATH%/app-release.apks --mode=universal
echo Extracting.
IF EXIST "%RELEASE_PATH%\universal.apks" DEL /F "%RELEASE_PATH%\universal.apks"
IF EXIST "%RELEASE_PATH%\universal.apk" DEL /F "%RELEASE_PATH%\universal.apk"
IF EXIST "%RELEASE_PATH%\playlist_editor.apk" DEL /F "%RELEASE_PATH%\playlist_editor.apk"
7z e "%RELEASE_PATH%\app-release.apks" -o"%RELEASE_PATH%" universal.apk
REN "%RELEASE_PATH%\universal.apk" playlist_editor.apk 
echo Build completed.
EXIT /B 0
