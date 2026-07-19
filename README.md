# HaloPet Mobile

Project Flutter untuk aplikasi telemedicine hewan berdasarkan desain `HaloPet(1).fig` dan dokumen kebutuhan proyek.

## Fitur yang tersedia

- Login/register dengan tiga role: pemilik hewan, dokter, dan admin.
- Session login lokal menggunakan `shared_preferences`.
- SQLite untuk user, dokter, hewan, jadwal, konsultasi, pesan, rekam medis, dan notifikasi.
- CRUD data hewan.
- Daftar dokter, detail dokter, jadwal, dan booking konsultasi.
- Riwayat konsultasi dan chat lokal.
- Dashboard dokter untuk menerima/menyelesaikan konsultasi serta menambahkan rekam medis.
- Dashboard admin, daftar user/dokter, monitoring konsultasi, dan laporan.
- Empty state, error state, loading state, dan komponen UI reusable.

## Akun demo

| Role | Email | Password |
|---|---|---|
| Pemilik | `owner@halopet.com` | `123456` |
| Dokter | `doctor@halopet.com` | `123456` |
| Admin | `admin@halopet.com` | `123456` |

## Menjalankan di VS Code

1. Instal Flutter SDK dan Android Studio/Android SDK.
2. Ekstrak ZIP lalu buka folder `HaloPet_Flutter_Final` di VS Code.
3. Bila folder platform belum tersedia, jalankan satu kali:

```bash
flutter create --platforms=android,ios .
```

4. Ambil dependency dan jalankan:

```bash
flutter pub get
flutter run
```

Untuk Windows tersedia `setup_and_run.bat`.

## Catatan desain

File `.fig` asli, thumbnail canvas, dan dokumen kebutuhan disimpan pada `docs/figma_reference/`. File Figma yang diterima memakai format binary `fig-kiwi`; implementasi UI mengikuti struktur halaman, modul, warna biru-putih, kartu membulat, dan alur pada canvas/thumbnail. Penyesuaian pixel-perfect per frame dapat dilanjutkan setelah setiap frame diekspor dari Figma dalam resolusi penuh.

## Struktur utama

```text
lib/
├── app/
├── core/
├── database/
├── models/
├── providers/
├── services/
└── features/
    ├── auth/
    ├── owner/
    ├── doctor/
    └── admin/
```

## Reset data demo

Hapus aplikasi dari emulator/perangkat, lalu jalankan kembali. Database SQLite akan dibuat dan diisi ulang otomatis.
