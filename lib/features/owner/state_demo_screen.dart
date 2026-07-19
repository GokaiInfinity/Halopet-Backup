import 'package:flutter/material.dart';
import '../../core/widgets/halopet_state_screen.dart';

class StateDemoScreen extends StatelessWidget {
  const StateDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Demo Error & Empty States',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItem(
              context,
              '01 Koneksi Internet Bermasalah',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State01()))),
          _buildItem(
              context,
              '02 Server Tidak Tersedia',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State02()))),
          _buildItem(
              context,
              '03 Halaman Tidak Ditemukan',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State03()))),
          _buildItem(
              context,
              '04 Data Tidak Ditemukan',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State04()))),
          _buildItem(
              context,
              '05 Pencarian Kosong',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State05()))),
          _buildItem(
              context,
              '06 Gagal Memuat Data',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State06()))),
          _buildItem(
              context,
              '07 Gagal Mengunggah File',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State07()))),
          _buildItem(
              context,
              '08 Gagal Membayar',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State08()))),
          _buildItem(
              context,
              '09 Form Belum Lengkap',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State09()))),
          _buildItem(
              context,
              '10 Akses Ditolak',
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const State10()))),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFFF0F4F8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
        onTap: onTap,
      ),
    );
  }
}

// Widget Bantuan untuk merender Mock Ilustrasi
Widget _buildMockIllustration(
    IconData mainIcon, IconData? badgeIcon, Color badgeColor) {
  return SizedBox(
    width: 200,
    height: 200,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Background Circle (Light Blue)
        Container(
          width: 160,
          height: 160,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F4F8),
            shape: BoxShape.circle,
          ),
        ),
        // Main Icon
        Icon(mainIcon, size: 100, color: const Color(0xFF45A5C7)),
        // Badge
        if (badgeIcon != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(badgeIcon, color: Colors.white, size: 24),
              ),
            ),
          )
      ],
    ),
  );
}

// 01 Koneksi Internet Bermasalah
class State01 extends StatelessWidget {
  const State01({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Koneksi internet bermasalah',
      message: 'Periksa koneksi internet Anda\ndan coba lagi.',
      illustration: _buildMockIllustration(Icons.wifi, Icons.close, Colors.red),
      primaryButtonText: 'Coba Lagi',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Periksa Koneksi',
      onSecondaryPressed: () {},
    );
  }
}

// 02 Server Sedang Tidak Tersedia
class State02 extends StatelessWidget {
  const State02({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Server sedang tidak tersedia',
      message:
          'Kami sedang melakukan perbaikan.\nSilakan coba beberapa saat lagi.',
      illustration:
          _buildMockIllustration(Icons.dns, Icons.warning, Colors.red),
      primaryButtonText: 'Coba Lagi',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Kembali ke Beranda',
      onSecondaryPressed: () {},
    );
  }
}

// 03 Halaman Tidak Ditemukan
class State03 extends StatelessWidget {
  const State03({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Halaman tidak ditemukan',
      message:
          'Halaman yang Anda cari\nmungkin sudah dihapus atau\nalamatnya salah.',
      illustration: _buildMockIllustration(
          Icons.pets, Icons.question_mark, Colors.orange), // 404 dog
      primaryButtonText: 'Kembali ke Beranda',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}

// 04 Data Tidak Ditemukan
class State04 extends StatelessWidget {
  const State04({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Data tidak ditemukan',
      message: 'Belum ada data yang tersedia\nuntuk ditampilkan.',
      illustration: _buildMockIllustration(
          Icons.folder_open, Icons.search, const Color(0xFF45A5C7)),
      primaryButtonText: 'Refresh',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}

// 05 Pencarian Kosong
class State05 extends StatelessWidget {
  const State05({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Hasil tidak ditemukan',
      message: 'Tidak ada hasil untuk kata kunci\n"vaksin rabies".',
      illustration: _buildMockIllustration(
          Icons.pets, Icons.search, const Color(0xFF45A5C7)),
      primaryButtonText: 'Coba Kata Kunci Lain',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Lihat Semua',
      onSecondaryPressed: () {},
      topWidget: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E5EC)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFF7A93AA)),
            SizedBox(width: 12),
            Expanded(
                child: Text('Cari: vaksin rabies',
                    style: TextStyle(color: Color(0xFF0F2646)))),
            Icon(Icons.close, color: Color(0xFF7A93AA), size: 20),
          ],
        ),
      ),
    );
  }
}

// 06 Gagal Memuat Data
class State06 extends StatelessWidget {
  const State06({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Gagal memuat data',
      message: 'Terjadi kesalahan saat memuat data.\nSilakan coba lagi.',
      illustration:
          _buildMockIllustration(Icons.pets, Icons.priority_high, Colors.blue),
      primaryButtonText: 'Muat Ulang',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}

// 07 Gagal Mengunggah File
class State07 extends StatelessWidget {
  const State07({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Gagal mengunggah file',
      message:
          'Terjadi kesalahan saat mengunggah file.\nPeriksa ukuran dan format file,\nlalu coba lagi.',
      illustration:
          _buildMockIllustration(Icons.upload_file, Icons.close, Colors.red),
      primaryButtonText: 'Coba Lagi',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Pilih File Lain',
      onSecondaryPressed: () {},
    );
  }
}

// 08 Gagal Membayar
class State08 extends StatelessWidget {
  const State08({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Pembayaran gagal',
      message:
          'Transaksi tidak dapat diproses.\nSilakan periksa metode pembayaran\natau saldo Anda.',
      illustration: _buildMockIllustration(
          Icons.credit_card, Icons.priority_high, Colors.red),
      primaryButtonText: 'Coba Lagi',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Pilih Metode Lain',
      onSecondaryPressed: () {},
    );
  }
}

// 09 Form Belum Lengkap
class State09 extends StatelessWidget {
  const State09({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Form belum lengkap',
      message:
          'Mohon lengkapi semua field yang\nwajib diisi sebelum melanjutkan.',
      illustration: _buildMockIllustration(
          Icons.assignment, Icons.priority_high, Colors.red),
      primaryButtonText: 'Lengkapi Form',
      onPrimaryPressed: () => Navigator.pop(context),
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}

// 10 Akses Ditolak
class State10 extends StatelessWidget {
  const State10({super.key});
  @override
  Widget build(BuildContext context) {
    return HalopetStateScreen(
      title: 'Akses ditolak',
      message: 'Anda tidak memiliki izin untuk\nmengakses halaman ini.',
      illustration:
          _buildMockIllustration(Icons.shield, Icons.close, Colors.red),
      primaryButtonText: 'Kembali ke Beranda',
      onPrimaryPressed: () {},
      secondaryButtonText: 'Hubungi Admin',
      onSecondaryPressed: () {},
    );
  }
}
