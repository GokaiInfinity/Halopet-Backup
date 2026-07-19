import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';

// ==== MOCKUP 09: MANAJEMEN PASIEN ====
class AdminPatientManagementScreen extends StatelessWidget {
  const AdminPatientManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Manajemen Pasien',
      index: 1, // Bottom Nav Index 1
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH & FILTER
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari nama hewan atau pemilik...',
                        hintStyle: const TextStyle(color: Color(0xFF7A93AA)),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF7A93AA)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.blue)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFF0F2646)),
                  ),
                ],
              ),
            ),

            // TABS
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FA),
                          borderRadius: BorderRadius.circular(24)),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(24)),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF7A93AA),
                        dividerColor: Colors.transparent,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Semua'),
                          Tab(text: 'Aktif'),
                          Tab(text: 'Nonaktif'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildPatientItem(context, 'Milo', 'Golden Retriever',
                              'Adel Pratama', true),
                          _buildPatientItem(context, 'Luna', 'Kucing Anggora',
                              'Siti Aisyah', true),
                          _buildPatientItem(context, 'Max', 'Kucing Persia',
                              'Budi Santoso', true),
                          _buildPatientItem(context, 'Bella', 'Anjing Poodle',
                              'Rina Marlina', true),
                          _buildPatientItem(context, 'Coco',
                              'Kucing Maine Coon', 'Dwi Lestari', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TAMBAH PASIEN (if needed, though mockup has a + floating action or button at bottom)
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Tambah Pasien',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientItem(BuildContext context, String name, String breed,
      String owner, bool isActive) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.adminPatientDetail),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE6F0F9),
              child: Icon(
                  name == 'Milo' || name == 'Bella'
                      ? Icons.pets
                      : Icons.catching_pokemon,
                  color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 4),
                  Text(breed,
                      style: const TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('Pemilik: $owner',
                      style: const TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 12)),
                ],
              ),
            ),
            Text(
              isActive ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==== MOCKUP 10: DETAIL PASIEN ====
class AdminPatientDetailScreen extends StatelessWidget {
  const AdminPatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Pasien',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.more_horiz, color: Color(0xFF0F2646)),
              onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER INFO
              Row(
                children: [
                  const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE6F0F9),
                      child: Icon(Icons.pets, color: Colors.blue, size: 40)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Milo',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F2646))),
                      const SizedBox(height: 4),
                      const Text('Golden Retriever • Jantan',
                          style: TextStyle(
                              color: Color(0xFF7A93AA), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text('Aktif',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // INFORMASI PEMILIK
              const Text('Informasi Pemilik',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              _buildDetailRow('Nama', 'Adel Pratama'),
              _buildDetailRow('Email', 'adel.pratama@email.com'),
              _buildDetailRow('No. Telepon', '0812xxxxxxxxx'),
              _buildDetailRow('Alamat', 'Jakarta, Indonesia'),
              const SizedBox(height: 32),

              // INFORMASI HEWAN
              const Text('Informasi Hewan',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              _buildDetailRow('Tanggal Lahir', '12 Jan 2021'),
              _buildDetailRow('Berat', '25 kg'),
              _buildDetailRow('Riwayat Alergi', 'Tidak ada'),
              _buildDetailRow('Golongan Darah', 'DEA 1.1+'),
              const SizedBox(height: 40),

              // AKSI
              const Text('Aksi',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Edit Data',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Nonaktifkan',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF7A93AA))),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF0F2646), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==== MOCKUP 11: MANAJEMEN DOKTER ====
class AdminDoctorManagementScreen extends StatelessWidget {
  const AdminDoctorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manajemen Dokter',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH & FILTER
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari dokter atau spesialis...',
                        hintStyle: const TextStyle(color: Color(0xFF7A93AA)),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF7A93AA)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.blue)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFF0F2646)),
                  ),
                ],
              ),
            ),

            // TABS
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FA),
                          borderRadius: BorderRadius.circular(24)),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(24)),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF7A93AA),
                        dividerColor: Colors.transparent,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Semua'),
                          Tab(text: 'Aktif'),
                          Tab(text: 'Nonaktif'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildDoctorItem('Drh. Anisa Putri',
                              'Spesialis Hewan Kecil', true),
                          _buildDoctorItem('Drh. Bimo Ardi',
                              'Spesialis Hewan Eksotik', true),
                          _buildDoctorItem('Drh. Citra Angel',
                              'Spesialis Hewan Besar', false),
                          _buildDoctorItem(
                              'Drh. Eko Wibowo', 'Spesialis Kulit', true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TAMBAH DOKTER
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.adminAddDoctor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Tambah Dokter',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorItem(String name, String spec, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFE6F0F9),
            child: Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F2646))),
                const SizedBox(height: 4),
                Text(spec,
                    style: const TextStyle(
                        color: Color(0xFF7A93AA), fontSize: 12)),
              ],
            ),
          ),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              color: isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ==== MOCKUP 12: TAMBAH DOKTER ====
class AdminAddDoctorScreen extends StatelessWidget {
  const AdminAddDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Dokter',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PHOTO UPLOAD
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.blue.withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(Icons.person_outline,
                              size: 50, color: Colors.blue),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Foto Profil',
                        style: TextStyle(
                            color: Color(0xFF7A93AA),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // FORM
              _buildTextField('Nama Lengkap', 'Masukkan nama lengkap'),
              const SizedBox(height: 16),
              _buildTextField('Email', 'Masukkan email'),
              const SizedBox(height: 16),
              _buildTextField('No. Telepon', 'Masukkan nomor telepon'),
              const SizedBox(height: 16),

              const Text('Spesialisasi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Pilih spesialisasi',
                        style: TextStyle(color: Color(0xFF7A93AA))),
                    items: const [],
                    onChanged: (value) {},
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    children: [
                      Radio(
                          value: true,
                          groupValue: true,
                          onChanged: (v) {},
                          activeColor: Colors.blue),
                      const Text('Aktif'),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Radio(value: false, groupValue: true, onChanged: (v) {}),
                      const Text('Nonaktif'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Simpan Dokter',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF7A93AA), fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
