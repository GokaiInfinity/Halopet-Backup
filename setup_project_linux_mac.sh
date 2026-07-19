#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
echo "Menyiapkan project HaloPet Flutter..."

if [ ! -f lib/main.dart ]; then
  echo "File lib/main.dart tidak ditemukan."
  exit 1
fi

cp lib/main.dart lib/main.halopet.backup.dart
cp pubspec.yaml pubspec.halopet.backup.yaml

flutter create . --platforms=android

cp lib/main.halopet.backup.dart lib/main.dart
cp pubspec.halopet.backup.yaml pubspec.yaml
rm -f lib/main.halopet.backup.dart pubspec.halopet.backup.yaml

flutter pub get

echo "Selesai. Jalankan aplikasi dengan: flutter run"
