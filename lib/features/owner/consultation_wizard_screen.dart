import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../app/routes.dart';

enum QuestionType { text, radio, checkbox, yesNo }

class ConsultationQuestion {
  final String key;
  final String question;
  final QuestionType type;
  final List<String> options;

  ConsultationQuestion({
    required this.key,
    required this.question,
    required this.type,
    this.options = const [],
  });
}

final Map<String, Map<String, List<ConsultationQuestion>>> serviceConfig = {
  'Keluhan Kesehatan Umum': {
    'Wajib': [
      ConsultationQuestion(key: 'keluhan_utama', question: 'Keluhan utama apa yang sedang dialami?', type: QuestionType.text),
      ConsultationQuestion(key: 'sejak_kapan', question: 'Sejak kapan keluhan muncul?', type: QuestionType.radio, options: ['Kurang dari 24 jam', '1 - 3 hari', 'Lebih dari 3 hari']),
      ConsultationQuestion(key: 'muncul_tiba_tiba', question: 'Apakah keluhan muncul tiba-tiba atau bertahap?', type: QuestionType.radio, options: ['Tiba-tiba', 'Bertahap']),
      ConsultationQuestion(key: 'masih_makan', question: 'Apakah hewan masih mau makan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'masih_minum', question: 'Apakah hewan masih mau minum?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'terlihat_lemas', question: 'Apakah hewan terlihat lemas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'mengalami_muntah', question: 'Apakah hewan mengalami muntah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'mengalami_diare', question: 'Apakah hewan mengalami diare?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'batuk_bersin_sesak', question: 'Apakah ada batuk, bersin, atau sesak napas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'suhu_panas', question: 'Apakah suhu tubuh hewan terasa panas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'masih_aktif', question: 'Apakah hewan masih aktif seperti biasa?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'perubahan_perilaku', question: 'Apakah ada perubahan perilaku?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_keluhan_sama', question: 'Apakah sebelumnya pernah mengalami keluhan yang sama?', type: QuestionType.yesNo),
    ],
    'Tambahan': [
      ConsultationQuestion(key: 'pernah_diberi_obat', question: 'Apakah hewan pernah diberi obat sebelumnya?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'obat_apa', question: 'Obat apa yang sudah diberikan?', type: QuestionType.text),
      ConsultationQuestion(key: 'hewan_lain_sakit', question: 'Apakah ada hewan lain di rumah yang sakit?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'baru_bepergian', question: 'Apakah hewan baru saja bepergian atau keluar rumah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'perubahan_makanan', question: 'Apakah ada perubahan makanan dalam beberapa hari terakhir?', type: QuestionType.yesNo),
    ],
    'Darurat': [
      ConsultationQuestion(key: 'sulit_bernapas', question: 'Apakah hewan sulit bernapas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kejang', question: 'Apakah hewan kejang?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tidak_sadar', question: 'Apakah hewan tidak sadar atau sangat lemas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'muntah_diare_berdarah', question: 'Apakah ada muntah/diare berdarah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tidak_bisa_berdiri', question: 'Apakah hewan tidak bisa berdiri?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tidak_buang_air_kecil', question: 'Apakah hewan tidak buang air kecil lebih dari 24 jam?', type: QuestionType.yesNo),
    ]
  },
};

class ConsultationWizardScreen extends StatefulWidget {
  const ConsultationWizardScreen({super.key});

  @override
  State<ConsultationWizardScreen> createState() =>
      _ConsultationWizardScreenState();
}

class _ConsultationWizardScreenState extends State<ConsultationWizardScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late TabController _tabController;
  int _currentPage = 0;

  // State
  Map<String, Object?>? selectedPet;
  String? selectedService;
  
  // Dynamic form answers
  Map<String, dynamic> formAnswers = {};
  
  // Form keys
  final _formKey = GlobalKey<FormState>();

  // Uploaded media
  List<String> consultationPhotos = [];
  List<String> consultationVideos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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

    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prev() {
    if (_currentPage == 4 && _tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
      return;
    }
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  int get _currentStep {
    if (_currentPage == 0) return 0; // Hewan
    if (_currentPage >= 1 && _currentPage <= 3) return 1; // Layanan
    if (_currentPage == 4) return 2; // Kuesioner
    return 3; // Selesai
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
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              children: [
                _buildPilihHewan(), // 0
                _buildPilihLayanan(), // 1
                _buildDetailLayanan(), // 2
                _buildInfoBatas(), // 3
                _buildKuesionerMedis(), // 4
                _buildRingkasan(), // 5
                _buildHasilSkrining(), // 6
              ],
            ),
          ),
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
        return 'Kuesioner Medis';
      case 5:
        return 'Ringkasan Keluhan';
      case 6:
        return 'Hasil Skrining';
      default:
        return 'Konsultasi';
    }
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(0, 'Hewan'),
          _buildLine(0),
          _buildStepItem(1, 'Layanan'),
          _buildLine(1),
          _buildStepItem(2, 'Kuesioner'),
          _buildLine(2),
          _buildStepItem(3, 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildLine(int stepIndex) {
    return Expanded(
      child: Container(
        height: 2,
        color: _currentStep > stepIndex
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE0E5EC),
      ),
    );
  }

  Widget _buildStepItem(int stepIndex, String label) {
    final isCompleted = _currentStep > stepIndex;
    final isActive = _currentStep == stepIndex;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : isActive
                    ? const Color(0xFF45A5C7)
                    : const Color(0xFFE0E5EC),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Center(
                  child: Text('${stepIndex + 1}',
                      style: TextStyle(
                          color:
                              isActive ? Colors.white : const Color(0xFF7A93AA),
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: isActive
                    ? const Color(0xFF45A5C7)
                    : const Color(0xFF7A93AA),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
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

  // ==== STEP 4: KUESIONER MEDIS (Wajib, Tambahan, Darurat) ====
  Widget _buildKuesionerMedis() {
    final serviceData = serviceConfig[selectedService] ?? {};
    final tabs = ['Wajib', 'Tambahan', 'Darurat'];

    return Column(
      children: [
        const SizedBox(height: 16),
        IgnorePointer(
          ignoring: true,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF45A5C7),
            unselectedLabelColor: const Color(0xFF7A93AA),
            indicatorColor: const Color(0xFF45A5C7),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: tabs.map((tab) {
              final questions = serviceData[tab] ?? [];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: tab == 'Wajib' ? _formKey : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (questions.isEmpty)
                        const Text('Belum ada daftar pertanyaan untuk bagian ini.', style: TextStyle(color: Colors.grey)),
                      ...questions.map((q) => _buildDynamicQuestion(q, isWajib: tab == 'Wajib', isDarurat: tab == 'Darurat')),
                      if (tab == 'Tambahan') ...[
                        const SizedBox(height: 32),
                        _buildUploadFotoSection(),
                      ]
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            String btnText = 'Lanjut ke Tambahan';
            if (_tabController.index == 1) btnText = 'Lanjut ke Darurat';
            if (_tabController.index == 2) btnText = 'Lanjut ke Ringkasan';

            return _buildFooter(btnText, () {
              if (_tabController.index == 0) {
                if (_formKey.currentState != null && !_formKey.currentState!.validate()) return;
                
                // Manual validation for all required fields (radio, yes/no)
                final wajibQuestions = serviceConfig[selectedService]?['Wajib'] ?? [];
                for (var q in wajibQuestions) {
                  if (formAnswers[q.key] == null || formAnswers[q.key].toString().trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harap jawab pertanyaan: ${q.question}')));
                    return;
                  }
                }
                
                if (_formKey.currentState != null) _formKey.currentState!.save();
                _tabController.animateTo(1);
              } else if (_tabController.index == 1) {
                _tabController.animateTo(2);
              } else {
                if (_isEmergency()) {
                  _showEmergencyDialog();
                } else {
                  _next();
                }
              }
            });
          },
        ),
      ],
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Kondisi Darurat', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
            'Hewan terindikasi dalam kondisi darurat yang membutuhkan penanganan segera!\n\nSistem akan mengarahkan Anda ke daftar dokter untuk ditangani secara langsung.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _goToDoctorList(); // Go to doctor list immediately
            },
            child: const Text('Cari Dokter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicQuestion(ConsultationQuestion q, {bool isWajib = false, bool isDarurat = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (q.type == QuestionType.text)
            TextFormField(
              initialValue: formAnswers[q.key] as String?,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ketik jawaban di sini...'),
              onChanged: (val) => formAnswers[q.key] = val,
              validator: (val) {
                if (isWajib && (val == null || val.isEmpty)) return 'Wajib diisi';
                return null;
              },
            )
          else if (q.type == QuestionType.radio)
            ...q.options.map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  toggleable: true,
                  groupValue: formAnswers[q.key] as String?,
                  activeColor: const Color(0xFF45A5C7),
                  onChanged: (val) => setState(() => formAnswers[q.key] = val),
                ))
          else if (q.type == QuestionType.yesNo)
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Ya'),
                    value: true,
                    toggleable: true,
                    groupValue: formAnswers[q.key] as bool?,
                    activeColor: const Color(0xFF45A5C7),
                    onChanged: (val) {
                      setState(() => formAnswers[q.key] = val);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Tidak'),
                    value: false,
                    toggleable: true,
                    groupValue: formAnswers[q.key] as bool?,
                    activeColor: const Color(0xFF45A5C7),
                    onChanged: (val) => setState(() => formAnswers[q.key] = val),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUploadFotoSection() {
    return Column(
      children: [
        const Text('Unggah Foto / Video (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                Icons.camera_alt, 'Tambah Foto', 'Maks. 5 MB', () => _showUploadMenu(context, isVideo: false)),
            const SizedBox(width: 16),
            _buildUploadBox(
                Icons.videocam, 'Tambah Video', 'Maks. 20 MB', () => _showUploadMenu(context, isVideo: true)),
          ],
        ),
        if (consultationPhotos.isNotEmpty || consultationVideos.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...consultationPhotos.map((path) => _buildMediaThumbnail(path, false)),
              ...consultationVideos.map((path) => _buildMediaThumbnail(path, true)),
            ],
          ),
        ]
      ],
    );
  }

  Future<void> _pickMedia(bool isVideo, ImageSource source) async {
    final picker = ImagePicker();
    try {
      if (isVideo) {
        final pickedFile = await picker.pickVideo(source: source);
        if (pickedFile != null) {
          setState(() {
            consultationVideos.add(pickedFile.path);
          });
        }
      } else {
        if (source == ImageSource.gallery) {
          final pickedFiles = await picker.pickMultiImage();
          if (pickedFiles.isNotEmpty) {
            setState(() {
              consultationPhotos.addAll(pickedFiles.map((e) => e.path));
            });
          }
        } else {
          final pickedFile = await picker.pickImage(source: source);
          if (pickedFile != null) {
            setState(() {
              consultationPhotos.add(pickedFile.path);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur kamera tidak didukung di perangkat ini (Windows/Desktop). Silakan pilih dari Galeri.')),
        );
      }
    }
  }

  void _showUploadMenu(BuildContext context, {required bool isVideo}) {
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
                _pickMedia(isVideo, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(isVideo, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(String path, bool isVideo) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: isVideo 
            ? const Icon(Icons.videocam, color: Colors.grey, size: 40)
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(path), fit: BoxFit.cover),
              ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isVideo) {
                  consultationVideos.remove(path);
                } else {
                  consultationPhotos.remove(path);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFF45A5C7).withOpacity(0.2),
        highlightColor: const Color(0xFF45A5C7).withOpacity(0.1),
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
      ),
    );
  }

  // ==== STEP 5: RINGKASAN ====
  Widget _buildRingkasan() {
    return Column(
      children: [
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
                ...formAnswers.entries.map((e) {
                  return _buildRingkasanRow(
                      _getQuestionLabel(e.key), e.value.toString());
                }),
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

  String _getQuestionLabel(String key) {
    if (selectedService == null) return key;
    final data = serviceConfig[selectedService] ?? {};
    for (var tab in data.values) {
      for (var q in tab) {
        if (q.key == key) return q.question;
      }
    }
    return key;
  }

  Widget _buildRingkasanRow(String label, String value) {
    if (value == 'true') value = 'Ya';
    if (value == 'false') value = 'Tidak';
    if (value.isEmpty || value == 'null') value = '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 12))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ==== STEP 6: HASIL SKRINING ====
  Widget _buildHasilSkrining() {
    bool isDarurat = _isEmergency();
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

  bool _isEmergency() {
    final daruratKeys = serviceConfig[selectedService]?['Darurat']?.map((e) => e.key).toList() ?? [];
    for (var key in daruratKeys) {
      if (formAnswers[key] == true) return true;
    }
    return false;
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
    bool isDarurat = _isEmergency();
    String category = isDarurat ? 'Darurat' : 'Ringan';

    // Prepare JSON data to pass to DoctorListScreen
    // Store JSON in 'main_complaints' to match existing SQLite schema without altering it
    final complaintData = {
      'service_type': selectedService,
      'main_complaints': jsonEncode(formAnswers),
    };

    Navigator.pushNamed(context, AppRoutes.doctorList, arguments: {
      'pet_id': selectedPet!['id'],
      'complaint': formAnswers['keluhan_utama'] ?? selectedService,
      'complaint_data': complaintData,
      'screening_data': {'result_category': category},
    });
  }
}
