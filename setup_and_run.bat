@echo off
setlocal
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter tidak ditemukan. Instal Flutter dan tambahkan ke PATH.
  pause
  exit /b 1
)
if not exist android\app\src\main\AndroidManifest.xml (
  echo Membuat folder platform Android dan iOS...
  flutter create --platforms=android,ios .
  if errorlevel 1 goto :error
)
flutter pub get
if errorlevel 1 goto :error
flutter run
exit /b 0
:error
echo Proses gagal. Periksa pesan di atas.
pause
exit /b 1
