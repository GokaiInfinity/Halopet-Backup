import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';

class PetVaccinationsScreen extends StatefulWidget {
  const PetVaccinationsScreen({super.key, required this.pet});
  final Map<String, Object?> pet;

  @override
  State<PetVaccinationsScreen> createState() => _PetVaccinationsScreenState();
}

class _PetVaccinationsScreenState extends State<PetVaccinationsScreen> {
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
    final vaccinations = p.vaccinations;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Vaksinasi',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: p.loadingDetails
          ? const Center(child: CircularProgressIndicator())
          : vaccinations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vaccinations.length,
                  itemBuilder: (context, index) {
                    final vaccination = vaccinations[index];
                    return _buildVaccinationCard(vaccination);
                  },
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color(0xFF45A5C7),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Tambah Vaksin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
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
            child: const Icon(Icons.shield_outlined,
                size: 64, color: Color(0xFF45A5C7)),
          ),
          const SizedBox(height: 24),
          const Text('Belum ada riwayat vaksin',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0F2646))),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(Map<String, Object?> vaccination) {
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
              Text(
                '${vaccination['vaccine_name']}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F2646)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16)),
                child: const Text('Selesai',
                    style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF7A93AA)),
              const SizedBox(width: 6),
              Text('${vaccination['date']}',
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
              Text('${vaccination['clinic_name'] ?? '-'}',
                  style:
                      const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
