import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';

class PetAddWizardScreen extends StatefulWidget {
  const PetAddWizardScreen({super.key});

  @override
  State<PetAddWizardScreen> createState() => _PetAddWizardScreenState();
}

class _PetAddWizardScreenState extends State<PetAddWizardScreen> {
  int pageIndex = 0;

  int get currentStep {
    if (pageIndex <= 2) return 0;
    if (pageIndex == 3) return 1;
    if (pageIndex == 4) return 2;
    return 3;
  }

  final PageController _pageController = PageController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _birthDateController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        
        // Calculate age
        final now = DateTime.now();
        int calculatedAge = now.year - picked.year;
        if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
          calculatedAge--;
        }
        _ageController.text = calculatedAge.toString();
        birthDate = _birthDateController.text;
        age = _ageController.text;
      });
    }
  }

  // Step 1: Identitas
  final _identitasForm = GlobalKey<FormState>();
  String name = '';
  String species = 'Anjing';
  String breed = '';
  String gender = 'Jantan';
  String petPhoto = '';
  List<String> additionalPhotos = [];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          petPhoto = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur kamera tidak didukung di perangkat ini. Silakan pilih dari Galeri.')),
        );
      }
    }
  }

  Future<void> _pickAdditionalImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          if (additionalPhotos.length < 10) {
            additionalPhotos.add(file.path);
          }
        }
      });
    }
  }

  Future<void> _pickAdditionalImageCamera() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          if (additionalPhotos.length < 10) {
            additionalPhotos.add(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur kamera tidak didukung di perangkat ini. Silakan pilih dari Galeri.')),
        );
      }
    }
  }

  // Step 2: Fisik
  final _fisikForm = GlobalKey<FormState>();
  String birthDate = '';
  String age = '';
  String weight = '';
  String colorMarks = '';
  String sterilized = 'Belum Steril';

  // Step 3: Riwayat
  final _riwayatForm = GlobalKey<FormState>();
  List<Map<String, String>> riwayatVaksin = [];
  List<String> alergi = [];
  List<Map<String, String>> riwayatPenyakit = [];

  bool saving = false;

  void _next() async {
    if (pageIndex == 0 || pageIndex == 1) {
      // Just advance
    } else if (pageIndex == 2) {
      if (!_identitasForm.currentState!.validate()) return;
      _identitasForm.currentState!.save();
    } else if (pageIndex == 3) {
      if (!_fisikForm.currentState!.validate()) return;
      _fisikForm.currentState!.save();
    } else if (pageIndex == 4) {
      if (!_riwayatForm.currentState!.validate()) return;
      _riwayatForm.currentState!.save();
    } else if (pageIndex == 5) {
      // Save to database
      setState(() => saving = true);
      final ownerId = context.read<AuthProvider>().user!.id;
      final savedId = await context.read<PetProvider>().save({
        'owner_id': ownerId,
        'name': name,
        'species': species,
        'breed': breed,
        'gender': gender,
        'age': int.tryParse(age) ?? 0,
        'weight': double.tryParse(weight) ?? 0,
        'photo': petPhoto,
        'tanggal_lahir': birthDate,
        'warna_ciri': colorMarks,
        'status_steril': sterilized,
        'alergi': alergi.join(', '),
        'additional_photos': jsonEncode(additionalPhotos),
      });

      if (savedId != null) {
        for (final v in riwayatVaksin) {
          await context.read<PetProvider>().saveVaccination({
            'pet_id': savedId,
            'name': v['name'],
            'date': v['date'],
            'status': 'Aktif'
          });
        }
        for (final p in riwayatPenyakit) {
          await context.read<PetProvider>().saveDisease({
            'pet_id': savedId,
            'name': p['name'],
            'date': p['date'],
            'status': 'Sembuh'
          });
        }
      }
      setState(() => saving = false);
      if (savedId == null) return; // Handle error if needed

      if (context.mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      pageIndex++;
    });
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  }

  void _prev() {
    if (pageIndex > 0) {
      setState(() {
        pageIndex--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading:
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prev),
        title: Text(
          [
            'Tambah Hewan',
            'Upload Foto Hewan',
            'Identitas Hewan',
            'Fisik Hewan',
            'Riwayat Kesehatan',
            'Ringkasan Hewan'
          ][pageIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: Column(
        children: [
          if (pageIndex != 1) _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSplashStep(),
                _buildUploadPhotoStep(),
                _buildIdentitasStep(),
                _buildFisikStep(),
                _buildRiwayatStep(),
                _buildRingkasanStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: saving ? null : _next,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF45A5C7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(pageIndex == 5 ? 'Simpan' : 'Lanjut',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepIndicator(0, 'Identitas'),
          _buildLine(0),
          _buildStepIndicator(1, 'Fisik'),
          _buildLine(1),
          _buildStepIndicator(2, 'Riwayat'),
          _buildLine(2),
          _buildStepIndicator(3, 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildLine(int stepIndex) {
    return Expanded(
      child: Container(
        height: 2,
        color: currentStep > stepIndex
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE0E5EC),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label) {
    final isCompleted = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;

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

  Widget _buildSplashStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6F4F8), width: 2),
            ),
            child: const CircleAvatar(
              radius: 64,
              backgroundColor: Color(0xFF45A5C7),
              child: Icon(Icons.pets, color: Colors.white, size: 64),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Yuk, kenalan dulu\ndengan hewan kesayanganmu',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF0F2646)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lengkapi identitas dasar hewan\nuntuk memulai profil kesehatan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7A93AA), fontSize: 14),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E5EC)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4F8),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.add, color: Color(0xFF45A5C7), size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profil lengkap membantu dokter',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF0F2646))),
                      SizedBox(height: 4),
                      Text('memberi rekomendasi lebih tepat.',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF7A93AA))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6F4F8), width: 2),
            ),
            child: petPhoto.isNotEmpty
                ? CircleAvatar(
                    radius: 64,
                    backgroundImage: FileImage(File(petPhoto)),
                  )
                : const CircleAvatar(
                    radius: 64,
                    backgroundColor: Color(0xFFE6F4F8),
                    child: Icon(Icons.camera_alt, color: Color(0xFF45A5C7), size: 48),
                  ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Tambahkan foto terbaik\nhewan kesayanganmu',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF0F2646)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Foto ini akan digunakan di profil hewan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7A93AA), fontSize: 14),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Color(0xFF45A5C7)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Pilih Foto',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF45A5C7))),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.add, color: Color(0xFF0F2646)),
            label: const Text('Atau ambil foto',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Foto Tambahan (Max 10)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              Text('${additionalPhotos.length}/10',
                  style: const TextStyle(color: Color(0xFF7A93AA))),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              ...additionalPhotos.asMap().entries.map((entry) {
                int idx = entry.key;
                String path = entry.value;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(path),
                          width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            additionalPhotos.removeAt(idx);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
              if (additionalPhotos.length < 10)
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Galeri'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _pickAdditionalImages();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: const Text('Kamera'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _pickAdditionalImageCamera();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF45A5C7)),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Color(0xFF45A5C7)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Light yellow
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Color(0xFFFFA000)),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gunakan foto terang dengan wajah hewan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Color(0xFF0F2646))),
                      SizedBox(height: 4),
                      Text('terlihat jelas dan tidak terpotong.',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF7A93AA))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitasStep() {
    return Form(
      key: _identitasForm,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Nama Hewan',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Contoh: Milo',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            onSaved: (v) => name = v!,
          ),
          const SizedBox(height: 20),
          const Text('Jenis Hewan',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildChoiceChip('Anjing', species,
                      (val) => setState(() => species = val))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildChoiceChip('Kucing', species,
                      (val) => setState(() => species = val))),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Ras',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Contoh: Golden Retriever',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            onSaved: (v) => breed = v ?? '',
          ),
          const SizedBox(height: 20),
          const Text('Jenis Kelamin',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildChoiceChip(
                      'Jantan', gender, (val) => setState(() => gender = val))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildChoiceChip(
                      'Betina', gender, (val) => setState(() => gender = val))),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status data\nBelum tersimpan',
                    style: TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Text('Wajib diisi',
                      style: TextStyle(
                          color: Color(0xFFE57373),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFisikStep() {
    return Form(
      key: _fisikForm,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Tanggal Lahir',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            controller: _birthDateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              hintText: 'Pilih tanggal lahir',
              prefixIcon: const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFFB0C4D9)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            onSaved: (v) => birthDate = v ?? '',
          ),
          const SizedBox(height: 20),
          const Text('Umur',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ageController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'Tahun',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            keyboardType: TextInputType.number,
            onSaved: (v) => age = v ?? '',
          ),
          const SizedBox(height: 20),
          const Text('Berat Badan',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: '12.5',
              suffixText: 'kg',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            keyboardType: TextInputType.number,
            onSaved: (v) => weight = v ?? '',
          ),
          const SizedBox(height: 20),
          const Text('Warna / Ciri Khusus',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Contoh: Bulu coklat keemasan',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            onSaved: (v) => colorMarks = v ?? '',
          ),
          const SizedBox(height: 20),
          const Text('Status Steril',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildChoiceChip('Belum Steril', sterilized,
                      (val) => setState(() => sterilized = val))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildChoiceChip('Sudah Steril', sterilized,
                      (val) => setState(() => sterilized = val))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatStep() {
    return Form(
      key: _riwayatForm,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildListField<Map<String, String>>('Riwayat Vaksinasi', riwayatVaksin, () => _showAddMapDialog('Riwayat Vaksinasi', (val) => setState(() => riwayatVaksin.add(val))), (idx) => setState(() => riwayatVaksin.removeAt(idx)), (item) => '${item['name']} (${item['date']})'),
          const SizedBox(height: 16),
          _buildListField<String>('Alergi', alergi, () => _showAddItemDialog('Alergi', (val) => setState(() => alergi.add(val))), (idx) => setState(() => alergi.removeAt(idx)), (item) => item),
          const SizedBox(height: 16),
          _buildListField<Map<String, String>>('Riwayat Penyakit', riwayatPenyakit, () => _showAddMapDialog('Riwayat Penyakit', (val) => setState(() => riwayatPenyakit.add(val))), (idx) => setState(() => riwayatPenyakit.removeAt(idx)), (item) => '${item['name']} (${item['date']})'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF2F9FA),
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.info_outline,
                      color: Color(0xFF45A5C7), size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data kesehatan membantu dokter',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2646),
                              fontSize: 12)),
                      SizedBox(height: 4),
                      Text('memahami kondisi hewan sebelum konsultasi dimulai.',
                          style: TextStyle(
                              color: Color(0xFF7A93AA), fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
      String label, String groupValue, Function(String) onSelect) {
    final isSelected = label == groupValue;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F4F8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF45A5C7)
                  : const Color(0xFFE0E5EC)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? const Color(0xFF45A5C7)
                    : const Color(0xFFB0C4D9),
                size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF45A5C7)
                        : const Color(0xFF7A93AA),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6F4F8), width: 2),
            ),
            child: petPhoto.isNotEmpty
                ? CircleAvatar(
                    radius: 48,
                    backgroundImage: FileImage(File(petPhoto)),
                  )
                : const CircleAvatar(
                    radius: 48,
                    backgroundColor: Color(0xFF45A5C7),
                    child: Icon(Icons.pets, color: Colors.white, size: 48),
                  ),
          ),
          const SizedBox(height: 32),
          _buildSummaryRow('Nama', name),
          const SizedBox(height: 16),
          _buildSummaryRow('Jenis Hewan', species),
          const SizedBox(height: 16),
          _buildSummaryRow('Ras', breed),
          const SizedBox(height: 16),
          _buildSummaryRow('Jenis Kelamin', gender),
          const SizedBox(height: 16),
          _buildSummaryRow('Tanggal Lahir', birthDate.isNotEmpty ? birthDate : '-'),
          const SizedBox(height: 16),
          _buildSummaryRow('Umur', age.isNotEmpty ? '$age Tahun' : '-'),
          const SizedBox(height: 16),
          _buildSummaryRow('Berat Badan', weight.isNotEmpty ? '$weight kg' : '-'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.bold, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2646), fontSize: 14)),
      ],
    );
  }

  Widget _buildListField<T>(String title, List<T> items, VoidCallback onAddPressed, Function(int) onRemove, String Function(T) labelBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E5EC)),
          ),
          child: Row(
            children: [
              Expanded(
                child: items.isEmpty
                    ? const Text('Belum diisi', style: TextStyle(color: Color(0xFF7A93AA)))
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items.asMap().entries.map((entry) => Chip(
                          label: Text(labelBuilder(entry.value)),
                          onDeleted: () => onRemove(entry.key),
                          backgroundColor: const Color(0xFFE6F4F8),
                          deleteIconColor: const Color(0xFF45A5C7),
                          labelStyle: const TextStyle(color: Color(0xFF0F2646), fontSize: 12),
                        )).toList(),
                      ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, color: Color(0xFF45A5C7), size: 16),
                label: const Text('Tambah', style: TextStyle(color: Color(0xFF45A5C7))),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tambah $title', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama $title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF45A5C7))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF45A5C7))),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF7A93AA), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    onAdd(controller.text);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF45A5C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMapDialog(String title, Function(Map<String, String>) onAdd) {
    final nameController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tambah $title', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama $title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF45A5C7))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF45A5C7))),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    final d = date.day.toString().padLeft(2, '0');
                    final m = date.month.toString().padLeft(2, '0');
                    final y = date.year;
                    dateController.text = '$d-$m-$y';
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Tanggal (dd-mm-yyyy)',
                  suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF45A5C7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF45A5C7))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF45A5C7))),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF7A93AA), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                    onAdd({
                      'name': nameController.text,
                      'date': dateController.text,
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF45A5C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
