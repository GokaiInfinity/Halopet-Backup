# Halopet Backend - Midtrans Integration

Backend sederhana berbasis Node.js dan Express untuk menangani pembayaran Midtrans untuk aplikasi Halopet.

## Cara Menjalankan

1. Pastikan **Node.js** sudah terinstal di komputer Anda.
2. Buka terminal (atau Command Prompt) di folder `backend` ini.
3. Jalankan perintah instalasi dependensi:
   ```bash
   npm install
   ```
4. Jalankan server:
   ```bash
   npm start
   ```
   Atau jika ingin auto-restart saat ada perubahan kode:
   ```bash
   npm run dev
   ```

5. Server akan berjalan di `http://localhost:3000`.

## API Endpoints

- `GET /` : Health check untuk memastikan server berjalan.
- `POST /api/payment/token` : Dipanggil dari aplikasi Flutter untuk mendapatkan `snap_token`.
- `POST /api/payment/webhook` : Diatur di *Dashboard* Midtrans sebagai **Payment Notification URL** (Namun Anda butuh `ngrok` jika ingin Midtrans bisa memanggil URL lokal komputer Anda).

## Menghubungkan Webhook lokal dengan ngrok
Karena Midtrans berada di internet, mereka tidak bisa mengirim POST ke `localhost:3000`.
Anda bisa menggunakan **ngrok** untuk mendapatkan URL publik sementara:
1. Download dan instal ngrok dari [ngrok.com](https://ngrok.com/)
2. Jalankan perintah: `ngrok http 3000`
3. ngrok akan memberikan URL seperti `https://abcd-123.ngrok.app`
4. Copy URL tersebut dan tambahkan `/api/payment/webhook`. Contoh: `https://abcd-123.ngrok.app/api/payment/webhook`
5. Paste di Midtrans Dashboard -> Settings -> Payment Notification URL.
