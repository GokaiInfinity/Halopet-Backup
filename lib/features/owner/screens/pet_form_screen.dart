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
  late final TextEditingController name, breed, age, weight;
  String species = 'Kucing';
  String gender = 'Jantan';
  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    name = TextEditingController(text: '${p?['name'] ?? ''}');
    breed = TextEditingController(text: '${p?['breed'] ?? ''}');
    age = TextEditingController(text: '${p?['age'] ?? ''}');
    weight = TextEditingController(text: '${p?['weight'] ?? ''}');
    species = '${p?['species'] ?? 'Kucing'}';
    gender = '${p?['gender'] ?? 'Jantan'}';
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final ownerId = context.read<AuthProvider>().user!.id;
    final savedId = await context.read<PetProvider>().save({
      'owner_id': ownerId,
      'name': name.text,
      'species': species,
      'breed': breed.text,
      'gender': gender,
      'age': int.tryParse(age.text) ?? 0,
      'weight': double.tryParse(weight.text) ?? 0,
      'photo': ''
    }, id: widget.pet?['id'] as int?);
    if (savedId != null && mounted) Navigator.pop(context);
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            ElevatedButton(onPressed: save, child: const Text('Simpan'))
          ])));
}
