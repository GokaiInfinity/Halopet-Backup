import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/role_scaffolds.dart';
import '../../../database/database_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/consultation_provider.dart';
import '../../../providers/doctor_provider.dart';
import '../../../providers/pet_provider.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});
  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context
        .read<PetProvider>()
        .load(context.read<AuthProvider>().user!.id));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PetProvider>();
    final ownerId = context.read<AuthProvider>().user!.id;
    return OwnerScaffold(
      title: 'Daftar Hewan',
      index: 1,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined,
              color: Color(0xFF0F2646)),
        ),
      ],
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.error != null
              ? ErrorState(message: p.error!, onRetry: () => p.load(ownerId))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (p.pets.isEmpty)
                      const EmptyState(
                          title: 'Belum ada hewan',
                          message:
                              'Tambahkan data hewan agar dapat membuat konsultasi.',
                          icon: Icons.pets)
                    else
                      ...p.pets.map((pet) => _buildPetCard(context, pet)),
                    const SizedBox(height: 16),
                    _buildAddButton(context, ownerId),
                    const SizedBox(height: 24),
                    _buildBannerCard(),
                  ],
                ),
    );
  }

  Widget _buildPetCard(BuildContext context, Map<String, Object?> pet) {
    final isMale = (pet['gender'] == 'Jantan');
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.petDetail, arguments: pet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E5EC)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE8E2D6),
              child: Icon(
                  pet['species'] == 'Anjing'
                      ? Icons.pets
                      : Icons.catching_pokemon,
                  color: Colors.white,
                  size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pet['name']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF0F2646))),
                  Text('${pet['breed']}',
                      style: const TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 12)),
                  Text('${pet['age']} Tahun',
                      style: const TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isMale ? Icons.male : Icons.female,
              color: isMale ? const Color(0xFF45A5C7) : const Color(0xFFE57373),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, int ownerId) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, AppRoutes.petAdd);
        if (mounted) context.read<PetProvider>().load(ownerId);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF45A5C7),
              width: 1.5,
              style: BorderStyle.none),
        ),
        // Since Flutter doesn't have dashed border natively in basic container, we'll use a dotted look or just regular outline
        // To approximate dashed, we can use an outline border but let's just keep it simple outlined
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Color(0xFF45A5C7)),
                SizedBox(width: 8),
                Text('Tambah Hewan',
                    style: TextStyle(
                        color: Color(0xFF45A5C7),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.pets, color: Color(0xFF45A5C7)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kelola semua hewan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2646),
                            fontSize: 14)),
                    SizedBox(height: 8),
                    Text(
                        'Tambah profil, lengkapi rekam medis, dan pantau kesehatan setiap hewan.',
                        style:
                            TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Data tersimpan aman di akunmu.',
              style: TextStyle(
                  color: Color(0xFF45A5C7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF45A5C7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 8.0;
    const dashSpace = 4.0;

    // Top
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Bottom
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height),
          Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
    // Left
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Right
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY),
          Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
