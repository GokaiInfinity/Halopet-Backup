import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';

class PetDiseasesScreen extends StatefulWidget {
  const PetDiseasesScreen({super.key, required this.pet});
  final Map<String, Object?> pet;

  @override
  State<PetDiseasesScreen> createState() => _PetDiseasesScreenState();
}

class _PetDiseasesScreenState extends State<PetDiseasesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadDetails(widget.pet['id'] as int);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PetProvider>();
    final diseases = p.diseases;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Penyakit',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
        actions: [
          TextButton(
            onPressed: () => _showAddForm(context),
            child: const Text('+ Tambah',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF45A5C7))),
          ),
        ],
      ),
      body: p.loadingDetails
          ? const Center(child: CircularProgressIndicator())
          : diseases.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: diseases.length,
                  itemBuilder: (context, index) {
                    final disease = diseases[index];
                    return _buildDiseaseCard(disease);
                  },
                ),
    );
  }

  void _showAddForm(BuildContext context) {
    final nameController = TextEditingController();
    final dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Riwayat Penyakit',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Penyakit (contoh: Dermatitis)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
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
                    final formattedDate =
                        '${date.day} ${_getMonth(date.month)} ${date.year}';
                    dateController.text = formattedDate;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Tanggal Penyakit',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      dateController.text.isNotEmpty) {
                    final data = {
                      'pet_id': widget.pet['id'],
                      'name': nameController.text,
                      'date': dateController.text,
                      'status': 'Sembuh',
                    };
                    await context.read<PetProvider>().saveDisease(data);
                    if (mounted) Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF45A5C7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt',
      'Nov', 'Des'
    ];
    return months[month - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: Color(0xFFE6F4F8), shape: BoxShape.circle),
            child: const Icon(Icons.medical_services_outlined,
                size: 64, color: Color(0xFF45A5C7)),
          ),
          const SizedBox(height: 24),
          const Text('Belum ada riwayat penyakit',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          const Text('Hewan kesayanganmu sehat!',
              style: TextStyle(color: Color(0xFF7A93AA))),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, Object?> disease) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E5EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${disease['name']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F2646)),
                ),
              ),
              const Icon(Icons.more_horiz, color: Color(0xFFB0C4D9)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF7A93AA)),
              const SizedBox(width: 6),
              Text('${disease['date']}',
                  style:
                      const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.local_hospital_outlined,
                  size: 14, color: Color(0xFF7A93AA)),
              const SizedBox(width: 6),
              Text('${disease['clinic_name'] ?? '-'}',
                  style:
                      const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Sembuh',
                    style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFF2F9FA),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Klinik',
                    style: TextStyle(
                        color: Color(0xFF45A5C7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
