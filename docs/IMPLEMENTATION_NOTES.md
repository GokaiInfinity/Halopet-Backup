# Catatan Implementasi

## Cakupan versi ini

Versi ini merupakan implementasi Flutter MVP yang fungsional dan menyimpan seluruh data secara lokal. Modul pembayaran, push notification, panggilan video, dan backend online belum diaktifkan karena membutuhkan layanan eksternal dan kredensial proyek.

## Database

Database `halopet.db` dibuat otomatis dengan versi awal `1`. Password disimpan sebagai SHA-256 untuk demonstrasi lokal. Untuk produksi, gunakan backend aman, TLS, salted adaptive password hashing, validasi server, dan kontrol akses berbasis token.

## Desain Figma

`canvas.fig` dalam file Figma merupakan format binary. Thumbnail menunjukkan kumpulan screen mobile dengan gaya utama biru-putih dan beberapa dashboard. Karena aset gambar terpisah tidak terdapat di folder `images/` pada export, aplikasi memakai ikon Material dan avatar inisial agar tetap dapat berjalan tanpa aset yang hilang.

## Pengembangan berikutnya

- Hubungkan REST API/Firebase/Supabase.
- Tambahkan payment gateway.
- Integrasikan video call.
- Tambahkan upload foto ke object storage.
- Tambahkan unit/widget/integration test.
- Ekspor setiap frame Figma 1x/2x untuk penyelarasan pixel-perfect.
