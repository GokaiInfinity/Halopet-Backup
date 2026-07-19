import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../app/routes.dart';

class ConsultationWizardScreen extends StatefulWidget {
  const ConsultationWizardScreen({super.key});

  @override
  State<ConsultationWizardScreen> createState() =>
      _ConsultationWizardScreenState();
}

class _ConsultationWizardScreenState extends State<ConsultationWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State
  Map<String, Object?>? selectedPet;
  String? selectedService;
  List<String> mainComplaints = [];
  String? duration;
  String? appetite;
  String? activity;

  // Additional Complaints Form
  final _additionalFormKey = GlobalKey<FormState>();
  String urine = '';
  String feces = '';
  bool vomit = false;
  String respiratory = '';
  String skinCoat = '';
  String medication = '';

  // Screening Answers
  Map<String, bool> screeningAnswers = {
    'Kesulitan bernapas?': false,
    'Kejang / Kejang-kejang?': false,
    'Tidak sadar / Pingsan?': false,
    'Perdarahan berat?': false,
    'Trauma berat (kecelakaan)?': false,
    'Tidak dapat berdiri?': false,
    'Keracunan?': false,
    'Tidak dapat buang air kecil?': false,
    'Muntah atau diare terus-menerus?': false,
  };

  void _next() {
    if (_currentPage == 0 && selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih hewan terlebih dahulu.')));
      return;
    }
    if (_currentPage == 0 && selectedPet != null) {
      final species = (selectedPet!['species'] as String).toLowerCase();
      if (species != 'anjing' && species != 'kucing') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Layanan saat ini hanya untuk Anjing dan Kucing.')));
        return;
      }
    }
    if (_currentPage == 1 && selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih layanan terlebih dahulu.')));
      return;
    }
    if (_currentPage == 4 && mainComplaints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih minimal 1 keluhan utama.')));
      return;
    }
    if (_currentPage == 5 && duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih waktu munculnya keluhan.')));
      return;
    }
    if (_currentPage == 6 && (appetite == null || activity == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih kondisi nafsu makan dan aktivitas.')));
      return;
    }
    if (_currentPage == 7) {
      if (!_additionalFormKey.currentState!.validate()) return;
      _additionalFormKey.currentState!.save();
    }

    // Evaluate screening if at step 10 (Result is step 11)
    if (_currentPage == 10) {
      bool isDarurat =
          screeningAnswers.values.any((element) => element == true);
      // Let's assume if appetite is "Tidak mau makan" or activity is "Sangat lemah", it's Sedang, else Ringan
      String category = 'Ringan';
      if (isDarurat) {
        category = 'Darurat';
      } else if (appetite == 'Tidak mau makan' ||
          activity == 'Sangat lemah / Tidak aktif') {
        category = 'Sedang';
      }

      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }

    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prev() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentPage == 0) {
                Navigator.pop(context);
              } else {
                _prev();
              }
            }),
        title: Text(_getAppBarTitle()),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        children: [
          _buildPilihHewan(),
          _buildPilihLayanan(),
          _buildDetailLayanan(),
          _buildInfoBatas(),
          _buildKeluhanUtama(),
          _buildWaktuMuncul(),
          _buildNafsuDanAktivitas(),
          _buildGejalaLanjutan(),
          _buildUploadFoto(),
          _buildRingkasan(),
          _buildSkrining(),
          _buildHasilSkrining(),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentPage) {
      case 0:
        return 'Pilih Hewan';
      case 1:
        return 'Pilih Layanan';
      case 2:
        return 'Detail Layanan';
      case 3:
        return 'Info Batas Telemedicine';
      case 4:
        return 'Keluhan Utama';
      case 5:
        return 'Waktu Muncul Keluhan';
      case 6:
        return 'Nafsu Makan & Aktivitas';
      case 7:
        return 'Gejala Lanjutan';
      case 8:
        return 'Upload Foto/Video';
      case 9:
        return 'Ringkasan Keluhan';
      case 10:
        return 'Skrining Darurat';
      case 11:
        return 'Hasil Skrining';
      default:
        return 'Konsultasi';
    }
  }

  Widget _buildStepIndicator(int current, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final active = i <= current;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFF45A5C7) : const Color(0xFFF0F4F8),
            ),
            alignment: Alignment.center,
            child: Text('${i + 1}',
                style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF7A93AA),
                    fontWeight: FontWeight.bold)),
          );
        }),
      ),
    );
  }

  Widget _buildFooter(String btnText, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF45A5C7),
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(btnText,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // ==== STEP 0: PILIH HEWAN ====
  Widget _buildPilihHewan() {
    return Consumer<PetProvider>(builder: (context, provider, child) {
      if (provider.loading)
        return const Center(child: CircularProgressIndicator());
      if (provider.pets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Anda belum memiliki data hewan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.petAdd),
                child: const Text('Tambah Hewan'),
              )
            ],
          ),
        );
      }
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Pilih hewan yang akan dikonsultasikan',
                style: TextStyle(color: Color(0xFF7A93AA))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: provider.pets.length,
              itemBuilder: (context, index) {
                final pet = provider.pets[index];
                final isSelected = selectedPet?['id'] == pet['id'];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF45A5C7)
                            : const Color(0xFFE6F4F8),
                        width: 2),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFF0F4F8),
                      child: Icon(
                          pet['species'] == 'Anjing'
                              ? Icons.pets
                              : Icons.pets_outlined,
                          color: const Color(0xFF45A5C7)),
                    ),
                    title: Text(pet['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(
                        '${pet['species']} - ${pet['age']} Tahun\n${pet['breed']}'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF45A5C7))
                        : const Icon(Icons.circle_outlined,
                            color: Color(0xFFE6F4F8)),
                    onTap: () => setState(() => selectedPet = pet),
                  ),
                );
              },
            ),
          ),
          _buildFooter('Lanjut', _next),
        ],
      );
    });
  }

// ==== STEP 1: PILIH LAYANAN ====
  Widget _buildPilihLayanan() {
    final layanans = [
      {
        'title': 'Keluhan Kesehatan Umum',
        'subtitle': 'Demam, batuk, diare, dll',
        'icon': Icons.medical_services
      },
      {
        'title': 'Kulit dan Bulu',
        'subtitle': 'Gatal, rontok, jamur, alergi kulit',
        'icon': Icons.pets
      },
      {
        'title': 'Pencernaan',
        'subtitle': 'Muntah, diare, sembelit, dll',
        'icon': Icons.set_meal
      },
      {
        'title': 'Nutrisi',
        'subtitle': 'Pola makan, alergi makanan',
        'icon': Icons.restaurant
      },
      {
        'title': 'Perilaku',
        'subtitle': 'Agresif, cemas, takut, dll',
        'icon': Icons.psychology
      },
      {
        'title': 'Vaksinasi',
        'subtitle': 'Konsultasi jadwal vaksinasi',
        'icon': Icons.vaccines
      },
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Pilih jenis layanan klinis',
              style: TextStyle(color: Color(0xFF7A93AA))),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: layanans.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Color(0xFFF0F4F8), height: 1),
            itemBuilder: (context, index) {
              final lay = layanans[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE6F4F8),
                  child: Icon(lay['icon'] as IconData,
                      color: const Color(0xFF45A5C7), size: 20),
                ),
                title: Text(lay['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(lay['subtitle'] as String,
                    style: const TextStyle(fontSize: 12)),
                trailing:
                    const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
                onTap: () {
                  setState(() => selectedService = lay['title'] as String);
                  _next();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==== STEP 2: DETAIL LAYANAN ====
  Widget _buildDetailLayanan() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF0F4F8)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.medical_services,
                      size: 64, color: Color(0xFF45A5C7)),
                  const SizedBox(height: 16),
                  Text(selectedService ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text(
                      'Layanan konsultasi untuk keluhan umum seperti demam, batuk, pilek, lesu, tidak nafsu makan, dll.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF7A93AA))),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Termasuk:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem('Konsultasi dengan dokter hewan'),
                  _buildCheckItem('Skrining kondisi kesehatan'),
                  _buildCheckItem('Saran penanganan awal'),
                  _buildCheckItem('Resep (jika diperlukan)'),
                  _buildCheckItem('Kontrol dan monitoring'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildFooter('Pilih Layanan Ini', _next),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF45A5C7), size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Color(0xFF0F2646))),
        ],
      ),
    );
  }

  // ==== STEP 3: INFO BATAS ====
  Widget _buildInfoBatas() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.desktop_windows,
                    size: 100, color: Color(0xFF45A5C7)),
                const SizedBox(height: 24),
                const Text('Telemedicine memiliki batasan layanan.',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _buildDotItem('Tidak untuk kondisi gawat darurat berat'),
                _buildDotItem('Tidak dapat menggantikan pemeriksaan fisik'),
                _buildDotItem('Tidak untuk tindakan medis invasif'),
                _buildDotItem('Resep sesuai kebijakan dokter hewan'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F8),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFF45A5C7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                            'Jika kondisi hewan memburuk, dokter akan menyarankan untuk pemeriksaan langsung ke klinik.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF0F2646))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFooter('Saya Mengerti, Lanjutkan', _next),
        ],
      ),
    );
  }

  Widget _buildDotItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF7A93AA)),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(text, style: const TextStyle(color: Color(0xFF0F2646)))),
        ],
      ),
    );
  }

  // ==== STEP 4: KELUHAN UTAMA ====
  Widget _buildKeluhanUtama() {
    final options = [
      'Batuk / Bersin',
      'Muntah',
      'Diare',
      'Tidak Nafsu Makan',
      'Lesu / Lemah',
      'Gatal / Garuk-garuk',
      'Lainnya'
    ];
    return Column(
      children: [
        _buildStepIndicator(0, 5),
        const Text('Apa keluhan utama hewanmu?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const Text('Pilih satu atau lebih keluhan yang dialami.',
            style: TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              final isChecked = mainComplaints.contains(opt);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isChecked
                          ? const Color(0xFF45A5C7)
                          : const Color(0xFFE6F4F8)),
                  borderRadius: BorderRadius.circular(12),
                  color: isChecked ? const Color(0xFFE6F4F8) : Colors.white,
                ),
                child: CheckboxListTile(
                  title: Text(opt,
                      style: TextStyle(
                          fontWeight:
                              isChecked ? FontWeight.bold : FontWeight.normal)),
                  value: isChecked,
                  activeColor: const Color(0xFF45A5C7),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        mainComplaints.add(opt);
                      } else {
                        mainComplaints.remove(opt);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
        _buildFooter('Lanjut', _next),
      ],
    );
  }

  // ==== STEP 5: WAKTU MUNCUL ====
  Widget _buildWaktuMuncul() {
    final options = [
      '< 12 Jam',
      '12 - 24 Jam',
      '1 - 3 hari',
      '3 - 7 hari',
      '> 7 hari'
    ];
    return Column(
      children: [
        _buildStepIndicator(1, 5),
        const Text('Kapan keluhan mulai muncul?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = duration == opt;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFF45A5C7)
                          : const Color(0xFFE6F4F8)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: duration,
                  activeColor: const Color(0xFF45A5C7),
                  onChanged: (val) => setState(() => duration = val),
                ),
              );
            },
          ),
        ),
        _buildFooter('Lanjut', _next),
      ],
    );
  }

  // ==== STEP 6: NAFSU MAKAN & AKTIVITAS ====
  Widget _buildNafsuDanAktivitas() {
    final makanOpts = [
      'Baik seperti biasa',
      'Sedikit berkurang',
      'Sangat berkurang',
      'Tidak mau makan'
    ];
    final aktifOpts = [
      'Aktif seperti biasa',
      'Sedikit menurun',
      'Malas / Lesu',
      'Sangat lemah / Tidak aktif'
    ];

    return Column(
      children: [
        _buildStepIndicator(2, 5), // Treat as step 3
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bagaimana nafsu makan hewanmu?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...makanOpts.map((opt) => RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: appetite,
                      activeColor: const Color(0xFF45A5C7),
                      onChanged: (val) => setState(() => appetite = val),
                    )),
                const SizedBox(height: 24),
                const Text('Bagaimana tingkat aktivitasnya?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...aktifOpts.map((opt) => RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: activity,
                      activeColor: const Color(0xFF45A5C7),
                      onChanged: (val) => setState(() => activity = val),
                    )),
              ],
            ),
          ),
        ),
        _buildFooter('Lanjut', _next),
      ],
    );
  }

  // ==== STEP 7: GEJALA LANJUTAN ====
  Widget _buildGejalaLanjutan() {
    return Column(
      children: [
        _buildStepIndicator(3, 5),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _additionalFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lengkapi form gejala lanjutan (Opsional)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Kondisi buang air kecil',
                        border: OutlineInputBorder()),
                    onSaved: (val) => urine = val ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Kondisi buang air besar',
                        border: OutlineInputBorder()),
                    onSaved: (val) => feces = val ?? '',
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Muntah atau tidak?'),
                    value: vomit,
                    onChanged: (val) => setState(() => vomit = val),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Batuk, bersin, atau sesak napas',
                        border: OutlineInputBorder()),
                    onSaved: (val) => respiratory = val ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Kondisi kulit dan bulu',
                        border: OutlineInputBorder()),
                    onSaved: (val) => skinCoat = val ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Obat yang sedang dikonsumsi',
                        border: OutlineInputBorder()),
                    onSaved: (val) => medication = val ?? '',
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildFooter('Lanjut', _next),
      ],
    );
  }

  // ==== STEP 8: UPLOAD FOTO ====
  Widget _buildUploadFoto() {
    return Column(
      children: [
        _buildStepIndicator(4, 5),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unggah Foto / Video (Opsional)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                const Text(
                    'Foto atau video membantu dokter\nmemahami kondisi hewan lebih baik.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7A93AA))),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUploadBox(
                        Icons.camera_alt, 'Tambah Foto', 'Maks. 5 MB', () => _showUploadMenu(context)),
                    const SizedBox(width: 16),
                    _buildUploadBox(
                        Icons.videocam, 'Tambah Video', 'Maks. 20 MB', () => _showUploadMenu(context)),
                  ],
                ),
                // (Mocking the list of uploaded files, we can just skip for now)
              ],
            ),
          ),
        ),
        _buildFooter('Lanjut', _next),
      ],
    );
  }

  void _showUploadMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Pilih Sumber',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto berhasil diunggah!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto berhasil diunggah!')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE6F4F8), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF45A5C7), size: 32),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ==== STEP 9: RINGKASAN ====
  Widget _buildRingkasan() {
    return Column(
      children: [
        _buildStepIndicator(4, 5), // Or we hide step indicator here
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedPet != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFF0F4F8),
                        child: Icon(
                            selectedPet!['species'] == 'Anjing'
                                ? Icons.pets
                                : Icons.pets_outlined,
                            color: const Color(0xFF45A5C7)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedPet!['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(
                              '${selectedPet!['breed']} - ${selectedPet!['age']} Tahun',
                              style: const TextStyle(color: Color(0xFF7A93AA))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                _buildRingkasanRow('Layanan', selectedService ?? '-'),
                _buildRingkasanRow('Keluhan Utama', mainComplaints.join(', ')),
                _buildRingkasanRow('Waktu Muncul', duration ?? '-'),
                _buildRingkasanRow('Nafsu Makan', appetite ?? '-'),
                _buildRingkasanRow('Aktivitas', activity ?? '-'),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F8),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFF45A5C7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                            'Pastikan semua informasi sudah benar sebelum melanjutkan.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF0F2646))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter('Lanjut ke Skrining', _next),
      ],
    );
  }

  Widget _buildRingkasanRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(color: Color(0xFF7A93AA)))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ==== STEP 10: SKRINING DARURAT ====
  Widget _buildSkrining() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
              'Jawab pertanyaan berikut untuk memastikan kondisi hewan aman untuk konsultasi online.',
              style: TextStyle(color: Color(0xFF7A93AA))),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: screeningAnswers.keys.map((q) {
              final isYes = screeningAnswers[q]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(q,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    Row(
                      children: [
                        _buildChoiceBtn('Ya', isYes,
                            () => setState(() => screeningAnswers[q] = true)),
                        const SizedBox(width: 8),
                        _buildChoiceBtn('Tidak', !isYes,
                            () => setState(() => screeningAnswers[q] = false)),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        _buildFooter('Selanjutnya', _next),
      ],
    );
  }

  Widget _buildChoiceBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF45A5C7) : Colors.white,
          border: Border.all(
              color:
                  active ? const Color(0xFF45A5C7) : const Color(0xFFE6F4F8)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: active ? Colors.white : const Color(0xFF7A93AA),
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ==== STEP 11: HASIL SKRINING ====
  Widget _buildHasilSkrining() {
    bool isDarurat = screeningAnswers.values.any((element) => element == true);
    String category = 'Ringan';
    Color iconColor = Colors.green;
    IconData icon = Icons.check_circle;
    String desc =
        'Hewanmu dalam kondisi yang aman untuk konsultasi online.\n\nSilakan lanjut memilih dokter untuk mendapatkan konsultasi.';

    if (isDarurat) {
      category = 'Darurat';
      iconColor = Colors.red;
      icon = Icons.warning;
      desc =
          'Hewanmu terindikasi dalam kondisi darurat!\nSegera lakukan tindakan dan cari pertolongan medis terdekat.';
    } else if (appetite == 'Tidak mau makan' ||
        activity == 'Sangat lemah / Tidak aktif') {
      category = 'Sedang';
      iconColor = Colors.orange;
      icon = Icons.error;
      desc =
          'Hewanmu perlu diperhatikan dan dipantau.\n\nSegera konsultasi dengan dokter hewan dan pantau kondisinya secara berkala.';
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 100, color: iconColor),
                  const SizedBox(height: 24),
                  Text('Kondisi $category',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: iconColor)),
                  const SizedBox(height: 16),
                  Text(desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 16)),
                  if (category == 'Darurat') ...[
                    const SizedBox(height: 32),
                    const Text('Apa yang bisa dilakukan sekarang?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 12),
                    _buildEmergencyAction('Tetap tenang dan amankan hewan'),
                    _buildEmergencyAction(
                        'Lakukan pertolongan awal sesuai arahan'),
                    _buildEmergencyAction(
                        'Segera bawa ke klinik / rumah sakit hewan'),
                  ],
                ],
              ),
            ),
          ),
          if (category == 'Darurat') ...[
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cari Klinik Terdekat',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _goToDoctorList,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0F2646)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Hubungi Dokter',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
            ),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Beranda')),
          ] else ...[
            _buildFooter('Pilih Dokter', _goToDoctorList),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Beranda')),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyAction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _goToDoctorList() {
    // Determine category
    bool isDarurat = screeningAnswers.values.any((element) => element == true);
    String category = 'Ringan';
    if (isDarurat)
      category = 'Darurat';
    else if (appetite == 'Tidak mau makan' ||
        activity == 'Sangat lemah / Tidak aktif') category = 'Sedang';

    // Prepare data to pass to DoctorListScreen
    final complaintData = {
      'service_type': selectedService,
      'main_complaints': mainComplaints.join(', '),
      'duration': duration,
      'appetite': appetite,
      'activity': activity,
      'urine': urine,
      'feces': feces,
      'vomit': vomit ? 1 : 0,
      'respiratory': respiratory,
      'skin_coat': skinCoat,
      'medication': medication,
    };

    // Map human readable questions to db columns
    final screeningData = {
      'difficulty_breathing': screeningAnswers['Kesulitan bernapas?']! ? 1 : 0,
      'seizures': screeningAnswers['Kejang / Kejang-kejang?']! ? 1 : 0,
      'unconscious': screeningAnswers['Tidak sadar / Pingsan?']! ? 1 : 0,
      'heavy_bleeding': screeningAnswers['Perdarahan berat?']! ? 1 : 0,
      'severe_trauma': screeningAnswers['Trauma berat (kecelakaan)?']! ? 1 : 0,
      'cannot_stand': screeningAnswers['Tidak dapat berdiri?']! ? 1 : 0,
      'poisoning': screeningAnswers['Keracunan?']! ? 1 : 0,
      'cannot_urinate':
          screeningAnswers['Tidak dapat buang air kecil?']! ? 1 : 0,
      'continuous_vomiting':
          screeningAnswers['Muntah atau diare terus-menerus?']! ? 1 : 0,
      'result_category': category,
    };

    Navigator.pushNamed(context, AppRoutes.doctorList, arguments: {
      'pet_id': selectedPet!['id'],
      'complaint': mainComplaints.join(', '), // legacy map
      'complaint_data': complaintData,
      'screening_data': screeningData,
    });
  }
}
