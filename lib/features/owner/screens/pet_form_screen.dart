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

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.pet});
  final Map<String, Object?>? pet;
  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, breed, age, weight, tanggalLahir, warnaCiri;
  String species = 'Kucing';
  String gender = 'Jantan';
  String statusSteril = 'Belum Steril';

  List<String> alergi = [];
  List<Map<String, String>> riwayatVaksin = [];
  List<Map<String, String>> riwayatPenyakit = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    name = TextEditingController(text: '${p?['name'] ?? ''}');
    breed = TextEditingController(text: '${p?['breed'] ?? ''}');
    age = TextEditingController(text: '${p?['age'] ?? ''}');
    weight = TextEditingController(text: '${p?['weight'] ?? ''}');
    tanggalLahir = TextEditingController(text: '${p?['tanggal_lahir'] ?? ''}');
    warnaCiri = TextEditingController(text: '${p?['warna_ciri'] ?? ''}');
    
    species = p != null ? '${p['species'] ?? 'Kucing'}' : 'Kucing';
    gender = p != null ? '${p['gender'] ?? 'Jantan'}' : 'Jantan';
    statusSteril = p != null ? '${p['status_steril'] ?? 'Belum Steril'}' : 'Belum Steril';

    final alergiStr = '${p?['alergi'] ?? ''}';
    if (alergiStr.isNotEmpty) {
      alergi = alergiStr.split(', ').toList();
    }

    if (p != null) {
      final petId = p['id'] as int;
      Future.microtask(() async {
        final pProvider = context.read<PetProvider>();
        await pProvider.loadDetails(petId);
        if (mounted) {
          setState(() {
            riwayatVaksin = pProvider.vaccinations.map((e) => {
              'name': e['name'].toString(),
              'date': e['date'].toString()
            }).toList();
            riwayatPenyakit = pProvider.diseases.map((e) => {
              'name': e['name'].toString(),
              'date': e['date'].toString()
            }).toList();
          });
        }
      });
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => isLoading = true);
    
    final ownerId = context.read<AuthProvider>().user!.id;
    final savedId = await context.read<PetProvider>().save({
      'owner_id': ownerId,
      'name': name.text,
      'species': species,
      'breed': breed.text,
      'gender': gender,
      'age': int.tryParse(age.text) ?? 0,
      'weight': double.tryParse(weight.text) ?? 0,
      'tanggal_lahir': tanggalLahir.text,
      'warna_ciri': warnaCiri.text,
      'status_steril': statusSteril,
      'alergi': alergi.join(', '),
      'photo': widget.pet?['photo'] ?? ''
    }, id: widget.pet?['id'] as int?);

    if (savedId != null) {
      // Sync vaccinations
      final petProvider = context.read<PetProvider>();
      await petProvider.clearVaccinations(savedId);
      for (final v in riwayatVaksin) {
        await petProvider.saveVaccination({
          'pet_id': savedId,
          'name': v['name'],
          'date': v['date'],
          'status': 'Aktif'
        });
      }
      // Sync diseases
      await petProvider.clearDiseases(savedId);
      for (final p in riwayatPenyakit) {
        await petProvider.saveDisease({
          'pet_id': savedId,
          'name': p['name'],
          'date': p['date'],
          'status': 'Sembuh'
        });
      }
    }

    setState(() => isLoading = false);
    if (savedId != null && mounted) Navigator.pop(context);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
    );
  }

  Widget _buildChoiceChip(String label, String groupValue, Function(String) onSelected) {
    final selected = label == groupValue;
    return InkWell(
      onTap: () => onSelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF45A5C7) : Colors.white,
          border: Border.all(color: selected ? const Color(0xFF45A5C7) : const Color(0xFFE0E5EC)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF7A93AA),
            fontWeight: FontWeight.bold,
          )),
        ),
      ),
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

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(widget.pet == null ? 'Tambah hewan' : 'Edit hewan')),
      body: Form(
          key: form,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            const Center(
                child: AvatarInitials('Pet', radius: 46, icon: Icons.pets)),
            
            _buildSectionTitle('Identitas'),
            TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama hewan'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 14),
            DropdownButtonFormField(
                value: species,
                decoration: const InputDecoration(labelText: 'Jenis'),
                items: ['Kucing', 'Anjing', 'Kelinci', 'Burung', 'Lainnya']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => species = v!)),
            const SizedBox(height: 14),
            TextField(
                controller: breed,
                decoration: const InputDecoration(labelText: 'Ras')),
            const SizedBox(height: 14),
            DropdownButtonFormField(
                value: gender,
                decoration: const InputDecoration(labelText: 'Jenis kelamin'),
                items: ['Jantan', 'Betina']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => gender = v!)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: age,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Umur (tahun)'))),
              const SizedBox(width: 12),
              Expanded(
                  child: TextField(
                      controller: weight,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Berat (kg)')))
            ]),
            
            _buildSectionTitle('Fisik'),
            TextField(
              controller: tanggalLahir,
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
                  tanggalLahir.text = '$d-$m-$y';
                }
              },
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: warnaCiri,
              decoration: const InputDecoration(labelText: 'Warna / Ciri Fisik'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceChip('Belum Steril', statusSteril, (val) => setState(() => statusSteril = val)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceChip('Sudah Steril', statusSteril, (val) => setState(() => statusSteril = val)),
                ),
              ],
            ),

            _buildSectionTitle('Riwayat'),
            _buildListField<Map<String, String>>(
              'Riwayat Vaksinasi', 
              riwayatVaksin, 
              () => _showAddMapDialog('Riwayat Vaksinasi', (val) => setState(() => riwayatVaksin.add(val))), 
              (idx) => setState(() => riwayatVaksin.removeAt(idx)), 
              (item) => '${item['name']} (${item['date']})'
            ),
            const SizedBox(height: 16),
            _buildListField<String>(
              'Alergi', 
              alergi, 
              () => _showAddItemDialog('Alergi', (val) => setState(() => alergi.add(val))), 
              (idx) => setState(() => alergi.removeAt(idx)), 
              (item) => item
            ),
            const SizedBox(height: 16),
            _buildListField<Map<String, String>>(
              'Riwayat Penyakit', 
              riwayatPenyakit, 
              () => _showAddMapDialog('Riwayat Penyakit', (val) => setState(() => riwayatPenyakit.add(val))), 
              (idx) => setState(() => riwayatPenyakit.removeAt(idx)), 
              (item) => '${item['name']} (${item['date']})'
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : save, 
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF45A5C7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
            )
          ])));
}
