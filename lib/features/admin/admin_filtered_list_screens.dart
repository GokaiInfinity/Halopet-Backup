import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../database/database_helper.dart';

class AdminFilteredPatientsScreen extends StatelessWidget {
  const AdminFilteredPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final startDate = args?['startDate'] as DateTime?;
    final endDate = args?['endDate'] as DateTime?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pasien Konsultasi',
            style: TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.getAdminPatients(startDate: startDate, endDate: endDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final patients = snapshot.data ?? [];
            if (patients.isEmpty) {
              return const Center(child: Text("Tidak ada pasien di periode ini."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                final name = patient['name'] ?? 'Unknown';
                final breed = patient['breed'] ?? patient['species'] ?? 'Unknown';
                final owner = patient['owner_name'] ?? 'Unknown';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFFE6F0F9),
                        child: Icon(Icons.pets, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF0F2646))),
                            const SizedBox(height: 4),
                            Text(breed,
                                style: const TextStyle(
                                    color: Color(0xFF7A93AA), fontSize: 12)),
                            const SizedBox(height: 2),
                            Text('Pemilik: $owner',
                                style: const TextStyle(
                                    color: Color(0xFF7A93AA), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AdminFilteredDoctorsScreen extends StatelessWidget {
  const AdminFilteredDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final startDate = args?['startDate'] as DateTime?;
    final endDate = args?['endDate'] as DateTime?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dokter Konsultasi',
            style: TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.getAdminDoctors(startDate: startDate, endDate: endDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final doctors = snapshot.data ?? [];
            if (doctors.isEmpty) {
              return const Center(child: Text("Tidak ada dokter di periode ini."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                final name = doctor['name'] ?? 'Unknown';
                final specialist = doctor['specialist'] ?? 'Unknown';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFFE6F0F9),
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF0F2646))),
                            const SizedBox(height: 4),
                            Text(specialist,
                                style: const TextStyle(
                                    color: Color(0xFF7A93AA), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AdminFilteredTransactionsScreen extends StatelessWidget {
  const AdminFilteredTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final startDate = args?['startDate'] as DateTime?;
    final endDate = args?['endDate'] as DateTime?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transaksi Belum Lunas',
            style: TextStyle(
                color: Color(0xFF0F2646),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getAdminFilteredTransactions(startDate: startDate, endDate: endDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada transaksi belum lunas'));
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final status = transaction['status']?.toString() ?? '';
                Color statusColor = Colors.orange;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('INV-${transaction['id']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, color: Color(0xFF0F2646))),
                          Text(status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(transaction['pet_name']?.toString() ?? '-',
                          style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('-',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Color(0xFF0F2646))),
                          Text(transaction['created_at']?.toString() ?? '',
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
