# HaloPet / VetCare Flutter SQLite Prototype

Prototype aplikasi Veterinary Telemedicine berbasis mobile menggunakan Flutter dan SQLite. Aplikasi ini dibuat berdasarkan SRS: konsultasi dokter hewan, data hewan peliharaan, rekam medis, produk/obat, transaksi simulasi, dashboard, laporan, dan role pengguna.

## Catatan Penting

Project ini berisi source code Flutter. Folder platform Android/iOS sengaja tidak dibuat di sini agar ukuran ZIP ringan dan kompatibel dengan versi Flutter yang dipakai di laptop kamu. Untuk menjalankan aplikasi, buat/generate platform Flutter terlebih dahulu dengan langkah di bawah.

Fitur yang masih berupa simulasi prototype:
- Chat konsultasi tersimpan lokal di SQLite, bukan real-time antar perangkat.
- Pembayaran menggunakan status simulasi berhasil/gagal.
- Pengiriman pesanan menggunakan status lokal.
- Verifikasi dokter dilakukan oleh admin dalam aplikasi.

## Akun Demo

| Role | Email | Password |
|---|---|---|
| Pemilik Hewan | pemilik@halopet.test | 123456 |
| Dokter Hewan | dokter@halopet.test | 123456 |
| Admin | admin@halopet.test | 123456 |

## Cara Implementasi Paling Mudah

### 1. Install kebutuhan

Pastikan sudah terpasang:
- Flutter SDK
- Android Studio
- Android SDK
- VS Code atau Android Studio
- Emulator Android atau HP Android dengan USB debugging aktif

Cek instalasi:

```bash
flutter doctor
```

Perbaiki bagian yang masih bertanda silang sampai minimal Flutter dan Android toolchain sudah siap.

### 2. Ekstrak ZIP

Ekstrak file ZIP ini, misalnya ke:

```text
D:\TA\halopet_vetcare
```

### 3. Generate folder Android

Masuk ke folder project:

```bash
cd D:\TA\halopet_vetcare
```

Jalankan salah satu cara berikut.

#### Windows

Klik dua kali file:

```text
setup_project_windows.bat
```

Atau jalankan dari terminal:

```bash
setup_project_windows.bat
```

#### Mac/Linux

```bash
chmod +x setup_project_linux_mac.sh
./setup_project_linux_mac.sh
```

Script tersebut akan:
1. Mencadangkan `lib/main.dart` dan `pubspec.yaml`.
2. Menjalankan `flutter create . --platforms=android` untuk membuat folder Android.
3. Mengembalikan source code aplikasi HaloPet.
4. Menjalankan `flutter pub get`.

### 4. Jalankan aplikasi

Hubungkan emulator atau HP Android, lalu jalankan:

```bash
flutter run
```

Untuk membuat APK debug:

```bash
flutter build apk --debug
```

Hasil APK biasanya ada di:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## Cara Manual Jika Script Gagal

1. Buat project Flutter baru:

```bash
flutter create halopet_vetcare_run
```

2. Copy folder `lib` dan file `pubspec.yaml` dari ZIP ini ke folder project baru, lalu replace file bawaan Flutter.

3. Masuk ke folder project baru:

```bash
cd halopet_vetcare_run
```

4. Install dependency:

```bash
flutter pub get
```

5. Jalankan aplikasi:

```bash
flutter run
```

## Struktur Project

```text
halopet_vetcare/
├── lib/
│   └── main.dart
├── docs/
│   └── database_schema.sql
├── pubspec.yaml
├── analysis_options.yaml
├── setup_project_windows.bat
├── setup_project_linux_mac.sh
└── README_IMPLEMENTASI.md
```

## Fitur yang Sudah Ada

### Pemilik Hewan
- Login dan registrasi
- Dashboard pemilik
- CRUD data hewan peliharaan
- Melihat daftar dokter
- Membuat konsultasi simulasi
- Chat konsultasi lokal
- Melihat rekam medis
- Melihat produk
- Keranjang
- Checkout dan pembayaran simulasi
- Riwayat pesanan
- Notifikasi lokal
- Rating dokter setelah konsultasi selesai

### Dokter Hewan
- Dashboard dokter
- Melihat konsultasi masuk
- Membalas chat konsultasi
- Membuat rekam medis
- Mengelola jadwal konsultasi
- Melihat rekam medis yang dibuat

### Admin
- Dashboard admin
- Manajemen pengguna
- Verifikasi dokter
- Manajemen produk
- Manajemen pesanan
- Laporan konsultasi, pesanan, pendapatan, produk terlaris, dan dokter teraktif

## Dependency Flutter

Aplikasi memakai dependency:

```yaml
sqflite: ^2.3.3+1
path: ^1.9.0
```

## Catatan Pengembangan Lanjutan

Agar menjadi aplikasi online penuh, sistem perlu ditambah:
- Backend server, misalnya Laravel, Node.js, Firebase, atau Supabase.
- Database server, misalnya MySQL, PostgreSQL, atau Firestore.
- Realtime chat, misalnya Firebase Realtime Database, Firestore, atau WebSocket.
- Payment gateway.
- Push notification.
- Upload file/gambar ke cloud storage.

