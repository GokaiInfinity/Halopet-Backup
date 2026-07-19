@echo off
setlocal
cd /d "%~dp0"
echo Menyiapkan project HaloPet Flutter...

if not exist lib\main.dart (
  echo File lib\main.dart tidak ditemukan.
  pause
  exit /b 1
)

copy /Y lib\main.dart lib\main.halopet.backup.dart >nul
copy /Y pubspec.yaml pubspec.halopet.backup.yaml >nul

flutter create . --platforms=android
if errorlevel 1 (
  echo Gagal menjalankan flutter create. Pastikan Flutter sudah terinstall dan PATH benar.
  pause
  exit /b 1
)

copy /Y lib\main.halopet.backup.dart lib\main.dart >nul
copy /Y pubspec.halopet.backup.yaml pubspec.yaml >nul
del lib\main.halopet.backup.dart >nul 2>nul
del pubspec.halopet.backup.yaml >nul 2>nul

flutter pub get
if errorlevel 1 (
  echo Gagal menjalankan flutter pub get.
  pause
  exit /b 1
)

echo.
echo Selesai. Jalankan aplikasi dengan perintah: flutter run
pause
