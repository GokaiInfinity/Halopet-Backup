import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../database/database_helper.dart';
import '../../../app/routes.dart';

class DoctorAddScheduleScreen extends StatefulWidget {
  const DoctorAddScheduleScreen({super.key});

  @override
  State<DoctorAddScheduleScreen> createState() => _DoctorAddScheduleScreenState();
}

class _DoctorAddScheduleScreenState extends State<DoctorAddScheduleScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isRecurring = false;
  int _recurringWeeks = 4;
  int _maxPatients = 1;
  bool _isLoading = false;

  void _saveSchedule() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal dan waktu terlebih dahulu.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    int iterations = _isRecurring ? _recurringWeeks : 1;

    for (int i = 0; i < iterations; i++) {
      final date = _selectedDate!.add(Duration(days: i * 7));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final schedule = {
        'doctor_id': 1,
        'date': dateStr,
        'time': timeStr,
        'max_patients': _maxPatients,
        'status': 'available',
      };

      await DatabaseHelper.instance.insertSchedule(schedule);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
      );
      Navigator.pop(context, true); // Return true to indicate a refresh is needed
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
        title: const Text('Tambah Jadwal', style: TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Tanggal & Waktu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2646),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tentukan waktu ketersediaan Anda untuk menerima konsultasi.',
                    style: TextStyle(color: Color(0xFF7A93AA)),
                  ),
                  const SizedBox(height: 32),
                  // Date Picker
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E5EC)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.blue),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Pilih Tanggal'
                                  : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate == null ? const Color(0xFF7A93AA) : const Color(0xFF0F2646),
                                fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time Picker
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E5EC)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedTime == null
                                  ? 'Pilih Waktu (Jam:Menit)'
                                  : _selectedTime!.format(context),
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedTime == null ? const Color(0xFF7A93AA) : const Color(0xFF0F2646),
                                fontWeight: _selectedTime == null ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Recurring Checkbox
                  CheckboxListTile(
                    title: const Text(
                      'Ulangi jadwal ini',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2646)),
                    ),
                    subtitle: const Text(
                      'Jadwal akan disalin secara rekursif pada minggu-minggu berikutnya di hari yang sama.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7A93AA)),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _isRecurring,
                    activeColor: Colors.blue,
                    onChanged: (val) {
                      setState(() {
                        _isRecurring = val ?? false;
                      });
                    },
                  ),
                  if (_isRecurring)
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0, top: 8),
                      child: Row(
                        children: [
                          const Text('Selama: ', style: TextStyle(color: Color(0xFF0F2646))),
                          const SizedBox(width: 12),
                          DropdownButton<int>(
                            value: _recurringWeeks,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                            underline: Container(
                              height: 1,
                              color: Colors.blue,
                            ),
                            items: [2, 3, 4, 8, 12]
                                .map((w) => DropdownMenuItem(
                                      value: w,
                                      child: Text('$w minggu'),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _recurringWeeks = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  // Max Patients Input
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _maxPatients.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Maksimal Pasien',
                      labelStyle: const TextStyle(color: Color(0xFF7A93AA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      prefixIcon: const Icon(Icons.people, color: Colors.blue),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _maxPatients = int.tryParse(val) ?? 1;
                      });
                    },
                  ),
                  const Spacer(),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Simpan Jadwal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
