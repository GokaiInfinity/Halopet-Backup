import 'package:flutter/material.dart';
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
    return 2;
  }

  final PageController _pageController = PageController();

  // Step 1: Identitas
  final _identitasForm = GlobalKey<FormState>();
  String name = '';
  String species = 'Anjing';
  String breed = '';
  String gender = 'Jantan';

  // Step 2: Fisik
  final _fisikForm = GlobalKey<FormState>();
  String birthDate = '';
  String age = '';
  String weight = '';
  String colorMarks = '';
  String sterilized = 'Belum Steril';

  // Step 3: Riwayat
  final _riwayatForm = GlobalKey<FormState>();
  String riwayatVaksin = '';
  String alergi = '';
  String riwayatPenyakit = '';

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
        'photo': '',
        'tanggal_lahir': birthDate,
        'warna_ciri': colorMarks,
        'status_steril': sterilized,
        'alergi': alergi,
      });

      if (savedId != null) {
        if (riwayatVaksin.isNotEmpty) {
          await context.read<PetProvider>().saveVaccination({
            'pet_id': savedId,
            'name': riwayatVaksin,
            'date': DateTime.now().toIso8601String().split('T')[0],
            'status': 'Aktif'
          });
        }
        if (riwayatPenyakit.isNotEmpty) {
          await context.read<PetProvider>().saveDisease({
            'pet_id': savedId,
            'name': riwayatPenyakit,
            'date': DateTime.now().toIso8601String().split('T')[0],
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
            'Riwayat Kesehatan'
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
                  : Text(pageIndex == 4 ? 'Selesai' : 'Lanjut',
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
            child: const CircleAvatar(
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
            onPressed: () {},
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
            onPressed: () {},
            icon: const Icon(Icons.add, color: Color(0xFF0F2646)),
            label: const Text('Atau ambil foto',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
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
            decoration: InputDecoration(
              hintText: '2',
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
          const Text('Riwayat Vaksinasi',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Contoh: Vaksin Rabies',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            onSaved: (v) => riwayatVaksin = v ?? '',
          ),
          const SizedBox(height: 16),
          const Text('Alergi',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Contoh: Alergi ayam (opsional)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            onSaved: (v) => alergi = v ?? '',
          ),
          const SizedBox(height: 16),
          const Text('Riwayat Penyakit',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Contoh: Cacingan (opsional)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            ),
            onSaved: (v) => riwayatPenyakit = v ?? '',
          ),
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
}
