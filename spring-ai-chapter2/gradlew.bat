@echo off
setlocal EnableExtensions

rem Windows bootstrap launcher for this project.
rem Downloads the pinned Gradle distribution once, verifies its SHA-256,
rem then forwards all arguments to Gradle.

set "GRADLE_VERSION=8.14.8"
set "GRADLE_SHA256=94da89692fc3ca6d2d0ce6bb48548762ea0f1897ba444286f5c7f3759c7af651"
set "GRADLE_URL=https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip"

if not defined GRADLE_USER_HOME set "GRADLE_USER_HOME=%USERPROFILE%\.gradle"
set "GRADLE_CACHE_DIR=%GRADLE_USER_HOME%\manual-wrapper\dists\gradle-%GRADLE_VERSION%-bin"
set "GRADLE_HOME=%GRADLE_CACHE_DIR%\gradle-%GRADLE_VERSION%"
set "GRADLE_ZIP=%GRADLE_CACHE_DIR%\gradle-%GRADLE_VERSION%-bin.zip"

if exist "%GRADLE_HOME%\bin\gradle.bat" goto run_gradle

if not exist "%GRADLE_CACHE_DIR%" mkdir "%GRADLE_CACHE_DIR%"
if errorlevel 1 goto setup_failed

echo Gradle %GRADLE_VERSION% belum tersedia. Mengunduh distribusi resmi...
echo Lokasi cache: "%GRADLE_CACHE_DIR%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
  "Invoke-WebRequest -UseBasicParsing -Uri '%GRADLE_URL%' -OutFile '%GRADLE_ZIP%';" ^
  "$actual = (Get-FileHash -LiteralPath '%GRADLE_ZIP%' -Algorithm SHA256).Hash.ToLowerInvariant();" ^
  "if ($actual -ne '%GRADLE_SHA256%') { Remove-Item -LiteralPath '%GRADLE_ZIP%' -Force; throw 'SHA-256 distribusi Gradle tidak cocok.' };" ^
  "Expand-Archive -LiteralPath '%GRADLE_ZIP%' -DestinationPath '%GRADLE_CACHE_DIR%' -Force;"

if errorlevel 1 goto download_failed
if not exist "%GRADLE_HOME%\bin\gradle.bat" goto extract_failed
if exist "%GRADLE_ZIP%" del /q "%GRADLE_ZIP%" >nul 2>&1

echo Gradle %GRADLE_VERSION% siap digunakan.

:run_gradle
call "%GRADLE_HOME%\bin\gradle.bat" %*
set "GRADLE_EXIT_CODE=%ERRORLEVEL%"
exit /b %GRADLE_EXIT_CODE%

:setup_failed
echo Gagal menyiapkan folder Gradle. Periksa hak akses folder user.
exit /b 1

:download_failed
echo Gagal mengunduh atau memverifikasi Gradle. Periksa koneksi internet dan PowerShell.
exit /b 1

:extract_failed
echo Gagal mengekstrak distribusi Gradle. Hapus folder cache Gradle project lalu coba lagi.
exit /b 1
