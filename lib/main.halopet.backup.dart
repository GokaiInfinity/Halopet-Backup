import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  runApp(const HaloPetApp());
}

class HaloPetApp extends StatelessWidget {
  const HaloPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HaloPet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}

class AppColors {
  static const lightBlue = Color(0xFFAFD8F4);
  static const primaryBlue = Color(0xFF4DA8C9);
  static const darkNavy = Color(0xFF192751);
  static const warmCream = Color(0xFFEBDDC3);
  static const background = Color(0xFFF7FAFC);
  static const border = Color(0xFFD7E3EA);
  static const textSecondary = Color(0xFF64748B);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue).copyWith(
        primary: AppColors.primaryBlue,
        secondary: AppColors.darkNavy,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkNavy,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
      ),
    );
  }
}

String nowIso() => DateTime.now().toIso8601String();
String money(num value) => 'Rp ${value.toStringAsFixed(0)}';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final dbFile = path.join(dbPath, 'halopet_vetcare.db');
    _database = await openDatabase(
      dbFile,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedData(db);
      },
    );
    return _database!;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        role TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE doctors (
        id_doctor INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        license_number TEXT,
        specialization TEXT,
        experience TEXT,
        consultation_fee REAL DEFAULT 0,
        rating REAL DEFAULT 0,
        verification_status TEXT DEFAULT 'menunggu'
      )
    ''');
    await db.execute('''
      CREATE TABLE pets (
        id_pet INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        pet_name TEXT NOT NULL,
        animal_type TEXT,
        breed TEXT,
        gender TEXT,
        age TEXT,
        weight REAL,
        medical_history TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE doctor_schedules (
        id_schedule INTEGER PRIMARY KEY AUTOINCREMENT,
        id_doctor INTEGER NOT NULL,
        day TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE consultations (
        id_consultation INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        id_doctor INTEGER NOT NULL,
        id_pet INTEGER NOT NULL,
        complaint TEXT,
        complaint_photo TEXT,
        consultation_date TEXT NOT NULL,
        status TEXT NOT NULL,
        total_fee REAL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE consultation_messages (
        id_message INTEGER PRIMARY KEY AUTOINCREMENT,
        id_consultation INTEGER NOT NULL,
        sender_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        attachment TEXT,
        sent_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE medical_records (
        id_record INTEGER PRIMARY KEY AUTOINCREMENT,
        id_consultation INTEGER NOT NULL,
        id_pet INTEGER NOT NULL,
        doctor_note TEXT,
        condition_summary TEXT,
        recommendation TEXT,
        medicine_suggestion TEXT,
        record_date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id_product INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL,
        category TEXT,
        description TEXT,
        price REAL DEFAULT 0,
        stock INTEGER DEFAULT 0,
        product_image TEXT,
        status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE carts (
        id_cart INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        id_product INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id_order INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        order_date TEXT NOT NULL,
        total_price REAL DEFAULT 0,
        shipping_address TEXT,
        order_status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE order_details (
        id_order_detail INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER NOT NULL,
        id_product INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL DEFAULT 0,
        subtotal REAL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE payments (
        id_payment INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        payment_type TEXT NOT NULL,
        reference_id INTEGER NOT NULL,
        payment_method TEXT,
        total_payment REAL DEFAULT 0,
        payment_status TEXT NOT NULL,
        payment_date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE reviews (
        id_review INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        id_doctor INTEGER NOT NULL,
        id_consultation INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        review_date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE notifications (
        id_notification INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedData(Database db) async {
    final created = nowIso();
    final adminId = await db.insert('users', {
      'name': 'Admin HaloPet',
      'email': 'admin@halopet.test',
      'password': '123456',
      'phone': '0811000001',
      'address': 'Kantor HaloPet',
      'role': 'admin',
      'status': 'aktif',
      'created_at': created,
    });
    final ownerId = await db.insert('users', {
      'name': 'Ayu Pemilik Hewan',
      'email': 'pemilik@halopet.test',
      'password': '123456',
      'phone': '0811000002',
      'address': 'Jl. Mawar No. 10',
      'role': 'pemilik',
      'status': 'aktif',
      'created_at': created,
    });
    final doctorUserId = await db.insert('users', {
      'name': 'drh. Bima Pratama',
      'email': 'dokter@halopet.test',
      'password': '123456',
      'phone': '0811000003',
      'address': 'Klinik Sahabat Hewan',
      'role': 'dokter',
      'status': 'aktif',
      'created_at': created,
    });
    final doctorUserId2 = await db.insert('users', {
      'name': 'drh. Citra Lestari',
      'email': 'citra@halopet.test',
      'password': '123456',
      'phone': '0811000004',
      'address': 'Klinik Vet Sehat',
      'role': 'dokter',
      'status': 'aktif',
      'created_at': created,
    });
    final doctorId = await db.insert('doctors', {
      'id_user': doctorUserId,
      'license_number': 'STRV-001-HP',
      'specialization': 'Hewan kecil & umum',
      'experience': '5 tahun menangani kucing, anjing, kelinci.',
      'consultation_fee': 50000,
      'rating': 4.8,
      'verification_status': 'diterima',
    });
    final doctorId2 = await db.insert('doctors', {
      'id_user': doctorUserId2,
      'license_number': 'STRV-002-HP',
      'specialization': 'Nutrisi & kulit hewan',
      'experience': '4 tahun fokus nutrisi dan kesehatan kulit.',
      'consultation_fee': 45000,
      'rating': 4.6,
      'verification_status': 'diterima',
    });
    await db.insert('doctor_schedules', {
      'id_doctor': doctorId,
      'day': 'Senin - Jumat',
      'start_time': '09:00',
      'end_time': '16:00',
      'status': 'aktif',
    });
    await db.insert('doctor_schedules', {
      'id_doctor': doctorId2,
      'day': 'Sabtu - Minggu',
      'start_time': '10:00',
      'end_time': '15:00',
      'status': 'aktif',
    });
    await db.insert('pets', {
      'id_user': ownerId,
      'pet_name': 'Milo',
      'animal_type': 'Kucing',
      'breed': 'Domestic Short Hair',
      'gender': 'Jantan',
      'age': '2 tahun',
      'weight': 4.2,
      'medical_history': 'Vaksin lengkap, pernah flu ringan.',
    });
    final products = [
      ['Vitamin Kucing', 'Vitamin', 'Suplemen harian untuk daya tahan tubuh.', 35000, 20],
      ['Obat Cacing Hewan', 'Obat', 'Obat cacing umum untuk hewan peliharaan.', 42000, 15],
      ['Shampoo Anti Kutu', 'Perawatan', 'Shampoo untuk membantu mengurangi kutu.', 55000, 12],
      ['Makanan Recovery', 'Nutrisi', 'Makanan basah untuk masa pemulihan.', 28000, 30],
    ];
    for (final p in products) {
      await db.insert('products', {
        'product_name': p[0],
        'category': p[1],
        'description': p[2],
        'price': p[3],
        'stock': p[4],
        'product_image': '',
        'status': 'aktif',
      });
    }
    await db.insert('notifications', {
      'id_user': adminId,
      'title': 'Database siap',
      'message': 'Data awal prototype berhasil dibuat.',
      'is_read': 0,
      'created_at': created,
    });
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ? AND status = ?',
      whereArgs: [email.trim(), password, 'aktif'],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email.trim()], limit: 1);
    return rows.isNotEmpty;
  }

  Future<int> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String phone = '',
    String address = '',
  }) async {
    final db = await database;
    final userId = await db.insert('users', {
      'name': name,
      'email': email.trim(),
      'password': password,
      'phone': phone,
      'address': address,
      'role': role,
      'status': 'aktif',
      'created_at': nowIso(),
    });
    if (role == 'dokter') {
      await db.insert('doctors', {
        'id_user': userId,
        'license_number': '-',
        'specialization': 'Umum',
        'experience': 'Belum diisi',
        'consultation_fee': 40000,
        'rating': 0,
        'verification_status': 'menunggu',
      });
    }
    return userId;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'pemilik@halopet.test');
  final passwordController = TextEditingController(text: '123456');
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => loading = true);
    final user = await AppDatabase.instance.login(emailController.text, passwordController.text);
    setState(() => loading = false);
    if (!mounted) return;
    if (user == null) {
      showMessage(context, 'Login gagal. Periksa email dan password.');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeRouter(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.pets, color: AppColors.darkNavy, size: 54),
                      SizedBox(height: 10),
                      Text('HaloPet', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
                      SizedBox(height: 4),
                      Text('Veterinary Telemedicine Prototype', style: TextStyle(color: AppColors.darkNavy)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: loading ? null : _login,
                  child: Text(loading ? 'Memproses...' : 'Login'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Buat Akun Baru'),
                ),
                const SizedBox(height: 18),
                const InfoBox(
                  title: 'Akun Demo',
                  body: 'Pemilik: pemilik@halopet.test / 123456\nDokter: dokter@halopet.test / 123456\nAdmin: admin@halopet.test / 123456',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String role = 'pemilik';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      showMessage(context, 'Nama, email, dan password wajib diisi.');
      return;
    }
    if (await AppDatabase.instance.emailExists(emailController.text)) {
      if (!mounted) return;
      showMessage(context, 'Email sudah digunakan.');
      return;
    }
    await AppDatabase.instance.registerUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      role: role,
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
    );
    if (!mounted) return;
    showMessage(context, 'Registrasi berhasil. Silakan login.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Registrasi',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
          const SizedBox(height: 12),
          TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'No. HP')),
          const SizedBox(height: 12),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: role,
            decoration: const InputDecoration(labelText: 'Daftar Sebagai'),
            items: const [
              DropdownMenuItem(value: 'pemilik', child: Text('Pemilik Hewan')),
              DropdownMenuItem(value: 'dokter', child: Text('Dokter Hewan')),
            ],
            onChanged: (value) => setState(() => role = value ?? 'pemilik'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: _register, child: const Text('Simpan Akun')),
        ],
      ),
    );
  }
}

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String;
    if (role == 'admin') return AdminDashboard(user: user);
    if (role == 'dokter') return DoctorDashboard(user: user);
    return OwnerDashboard(user: user);
  }
}

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  Future<Map<String, int>> _stats() async {
    final db = await AppDatabase.instance.database;
    final userId = widget.user['id_user'];
    Future<int> count(String table, String where) async {
      final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $table WHERE $where', [userId]);
      return (rows.first['total'] as int?) ?? 0;
    }
    final pets = await count('pets', 'id_user = ?');
    final consultations = await count('consultations', 'id_user = ?');
    final orders = await count('orders', 'id_user = ?');
    final recordsRows = await db.rawQuery('''
      SELECT COUNT(*) AS total FROM medical_records mr
      JOIN pets p ON p.id_pet = mr.id_pet
      WHERE p.id_user = ?
    ''', [userId]);
    return {
      'Hewan': pets,
      'Konsultasi': consultations,
      'Rekam Medis': (recordsRows.first['total'] as int?) ?? 0,
      'Pesanan': orders,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'HaloPet',
      showBack: false,
      actions: [IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout))],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            HeroHeader(name: widget.user['name'] as String, subtitle: 'Dashboard Pemilik Hewan', icon: Icons.pets),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: _stats(),
              builder: (context, snapshot) {
                final data = snapshot.data ?? {'Hewan': 0, 'Konsultasi': 0, 'Rekam Medis': 0, 'Pesanan': 0};
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.entries.map((e) => StatCard(label: e.key, value: e.value.toString())).toList(),
                );
              },
            ),
            const SizedBox(height: 18),
            ActionTile(icon: Icons.favorite, title: 'Data Hewan', subtitle: 'Tambah dan kelola hewan peliharaan', onTap: () => push(context, PetsScreen(user: widget.user))),
            ActionTile(icon: Icons.medical_services, title: 'Konsultasi Dokter', subtitle: 'Pilih dokter dan mulai simulasi chat', onTap: () => push(context, DoctorListScreen(user: widget.user))),
            ActionTile(icon: Icons.description, title: 'Rekam Medis', subtitle: 'Lihat riwayat catatan konsultasi', onTap: () => push(context, MedicalRecordsScreen(user: widget.user))),
            ActionTile(icon: Icons.shopping_bag, title: 'Toko Produk', subtitle: 'Beli obat dan kebutuhan kesehatan hewan', onTap: () => push(context, ProductsScreen(user: widget.user))),
            ActionTile(icon: Icons.receipt_long, title: 'Riwayat Pesanan', subtitle: 'Lihat status pesanan produk', onTap: () => push(context, OrdersScreen(user: widget.user))),
            ActionTile(icon: Icons.notifications, title: 'Notifikasi', subtitle: 'Lihat notifikasi lokal', onTap: () => push(context, NotificationsScreen(user: widget.user))),
          ],
        ),
      ),
    );
  }
}

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  Future<Map<String, dynamic>> _data() async {
    final db = await AppDatabase.instance.database;
    final doctorRows = await db.query('doctors', where: 'id_user = ?', whereArgs: [widget.user['id_user']], limit: 1);
    if (doctorRows.isEmpty) return {'doctor': null, 'consultations': <Map<String, dynamic>>[]};
    final doctor = doctorRows.first;
    final consultations = await db.rawQuery('''
      SELECT c.*, u.name AS owner_name, p.pet_name, p.animal_type
      FROM consultations c
      JOIN users u ON u.id_user = c.id_user
      JOIN pets p ON p.id_pet = c.id_pet
      WHERE c.id_doctor = ?
      ORDER BY c.id_consultation DESC
    ''', [doctor['id_doctor']]);
    return {'doctor': doctor, 'consultations': consultations};
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard Dokter',
      showBack: false,
      actions: [IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout))],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _data(),
          builder: (context, snapshot) {
            final doctor = snapshot.data?['doctor'];
            final consultations = (snapshot.data?['consultations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                HeroHeader(name: widget.user['name'] as String, subtitle: 'Dokter Hewan', icon: Icons.health_and_safety),
                const SizedBox(height: 16),
                if (doctor != null)
                  InfoBox(
                    title: 'Profil Dokter',
                    body: 'Spesialisasi: ${doctor['specialization']}\nBiaya: ${money(doctor['consultation_fee'] as num)}\nVerifikasi: ${doctor['verification_status']}',
                  ),
                const SizedBox(height: 12),
                ActionTile(icon: Icons.schedule, title: 'Jadwal Konsultasi', subtitle: 'Tambah, ubah, dan hapus jadwal praktik', onTap: () => push(context, DoctorScheduleScreen(user: widget.user, doctor: doctor))),
                ActionTile(icon: Icons.description, title: 'Rekam Medis', subtitle: 'Lihat catatan yang pernah dibuat', onTap: () => push(context, MedicalRecordsScreen(user: widget.user))),
                const SizedBox(height: 16),
                const SectionTitle('Daftar Konsultasi'),
                if (consultations.isEmpty) const EmptyState(text: 'Belum ada konsultasi masuk.'),
                for (final c in consultations)
                  AppCard(
                    child: ListTile(
                      leading: statusIcon(c['status'] as String),
                      title: Text('${c['pet_name']} - ${c['animal_type']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Pemilik: ${c['owner_name']}\nKeluhan: ${c['complaint']}\nStatus: ${c['status']}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => push(context, ChatScreen(user: widget.user, consultationId: c['id_consultation'] as int)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<Map<String, int>> _stats() async {
    final db = await AppDatabase.instance.database;
    Future<int> count(String table, [String? where]) async {
      final query = where == null ? 'SELECT COUNT(*) AS total FROM $table' : 'SELECT COUNT(*) AS total FROM $table WHERE $where';
      final rows = await db.rawQuery(query);
      return (rows.first['total'] as int?) ?? 0;
    }
    return {
      'User': await count('users'),
      'Dokter': await count('doctors'),
      'Menunggu': await count('doctors', "verification_status = 'menunggu'"),
      'Produk': await count('products'),
      'Konsultasi': await count('consultations'),
      'Pesanan': await count('orders'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard Admin',
      showBack: false,
      actions: [IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout))],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            HeroHeader(name: widget.user['name'] as String, subtitle: 'Pengelola Sistem HaloPet', icon: Icons.admin_panel_settings),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: _stats(),
              builder: (context, snapshot) {
                final data = snapshot.data ?? {};
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.entries.map((e) => StatCard(label: e.key, value: e.value.toString())).toList(),
                );
              },
            ),
            const SizedBox(height: 18),
            ActionTile(icon: Icons.people, title: 'Manajemen Pengguna', subtitle: 'Lihat dan nonaktifkan akun', onTap: () => push(context, AdminUsersScreen(user: widget.user))),
            ActionTile(icon: Icons.verified_user, title: 'Verifikasi Dokter', subtitle: 'Setujui atau tolak akun dokter', onTap: () => push(context, AdminDoctorsScreen(user: widget.user))),
            ActionTile(icon: Icons.inventory_2, title: 'Manajemen Produk', subtitle: 'Tambah, ubah, dan hapus produk', onTap: () => push(context, AdminProductsScreen(user: widget.user))),
            ActionTile(icon: Icons.local_shipping, title: 'Manajemen Pesanan', subtitle: 'Perbarui status pesanan', onTap: () => push(context, OrdersScreen(user: widget.user))),
            ActionTile(icon: Icons.bar_chart, title: 'Laporan dan Dashboard', subtitle: 'Ringkasan konsultasi dan transaksi', onTap: () => push(context, ReportsScreen(user: widget.user))),
          ],
        ),
      ),
    );
  }
}

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('pets', where: 'id_user = ?', whereArgs: [widget.user['id_user']], orderBy: 'id_pet DESC');
  }

  Future<void> _delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('pets', where: 'id_pet = ?', whereArgs: [id]);
    setState(() {});
  }

  Future<void> _showForm([Map<String, dynamic>? pet]) async {
    final name = TextEditingController(text: pet?['pet_name']?.toString() ?? '');
    final type = TextEditingController(text: pet?['animal_type']?.toString() ?? '');
    final breed = TextEditingController(text: pet?['breed']?.toString() ?? '');
    final gender = TextEditingController(text: pet?['gender']?.toString() ?? '');
    final age = TextEditingController(text: pet?['age']?.toString() ?? '');
    final weight = TextEditingController(text: pet?['weight']?.toString() ?? '');
    final history = TextEditingController(text: pet?['medical_history']?.toString() ?? '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet == null ? 'Tambah Hewan' : 'Ubah Hewan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama Hewan')),
              const SizedBox(height: 8),
              TextField(controller: type, decoration: const InputDecoration(labelText: 'Jenis Hewan')),
              const SizedBox(height: 8),
              TextField(controller: breed, decoration: const InputDecoration(labelText: 'Ras')),
              const SizedBox(height: 8),
              TextField(controller: gender, decoration: const InputDecoration(labelText: 'Jenis Kelamin')),
              const SizedBox(height: 8),
              TextField(controller: age, decoration: const InputDecoration(labelText: 'Umur')),
              const SizedBox(height: 8),
              TextField(controller: weight, decoration: const InputDecoration(labelText: 'Berat Badan'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: history, decoration: const InputDecoration(labelText: 'Riwayat Penyakit'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              final db = await AppDatabase.instance.database;
              final data = {
                'id_user': widget.user['id_user'],
                'pet_name': name.text.trim(),
                'animal_type': type.text.trim(),
                'breed': breed.text.trim(),
                'gender': gender.text.trim(),
                'age': age.text.trim(),
                'weight': double.tryParse(weight.text) ?? 0,
                'medical_history': history.text.trim(),
              };
              if (pet == null) {
                await db.insert('pets', data);
              } else {
                await db.update('pets', data, where: 'id_pet = ?', whereArgs: [pet['id_pet']]);
              }
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    type.dispose();
    breed.dispose();
    gender.dispose();
    age.dispose();
    weight.dispose();
    history.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Data Hewan',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final pets = snapshot.data ?? [];
          if (pets.isEmpty) return const EmptyState(text: 'Belum ada data hewan. Tekan tombol + untuk menambah.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final p = pets[index];
              return AppCard(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.pets, color: AppColors.darkNavy)),
                  title: Text(p['pet_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p['animal_type']} • ${p['breed']}\nUmur: ${p['age']} • Berat: ${p['weight']} kg'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _showForm(p);
                      if (value == 'delete') _delete(p['id_pet'] as int);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Ubah')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.rawQuery('''
      SELECT d.*, u.name, u.email,
        COALESCE((SELECT day || ' ' || start_time || '-' || end_time FROM doctor_schedules s WHERE s.id_doctor = d.id_doctor AND s.status = 'aktif' LIMIT 1), 'Belum ada jadwal') AS schedule_text
      FROM doctors d
      JOIN users u ON u.id_user = d.id_user
      WHERE d.verification_status = 'diterima' AND u.status = 'aktif'
      ORDER BY d.rating DESC
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pilih Dokter',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) return const EmptyState(text: 'Belum ada dokter yang terverifikasi.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final d = doctors[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.health_and_safety, color: AppColors.darkNavy)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(d['specialization'] as String, style: const TextStyle(color: AppColors.textSecondary)),
                            ]),
                          ),
                          Chip(label: Text('★ ${d['rating']}')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Jadwal: ${d['schedule_text']}'),
                      Text('Biaya: ${money(d['consultation_fee'] as num)}'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          onPressed: () => push(context, CreateConsultationScreen(user: user, doctor: d)),
                          label: const Text('Mulai Konsultasi'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CreateConsultationScreen extends StatefulWidget {
  const CreateConsultationScreen({super.key, required this.user, required this.doctor});
  final Map<String, dynamic> user;
  final Map<String, dynamic> doctor;

  @override
  State<CreateConsultationScreen> createState() => _CreateConsultationScreenState();
}

class _CreateConsultationScreenState extends State<CreateConsultationScreen> {
  int? selectedPetId;
  final complaintController = TextEditingController();
  final photoController = TextEditingController();

  Future<List<Map<String, dynamic>>> _pets() async {
    final db = await AppDatabase.instance.database;
    return db.query('pets', where: 'id_user = ?', whereArgs: [widget.user['id_user']]);
  }

  Future<void> _startConsultation() async {
    if (selectedPetId == null || complaintController.text.trim().isEmpty) {
      showMessage(context, 'Pilih hewan dan isi keluhan terlebih dahulu.');
      return;
    }
    final db = await AppDatabase.instance.database;
    final consultationId = await db.insert('consultations', {
      'id_user': widget.user['id_user'],
      'id_doctor': widget.doctor['id_doctor'],
      'id_pet': selectedPetId,
      'complaint': complaintController.text.trim(),
      'complaint_photo': photoController.text.trim(),
      'consultation_date': nowIso(),
      'status': 'berjalan',
      'total_fee': widget.doctor['consultation_fee'],
    });
    await db.insert('payments', {
      'id_user': widget.user['id_user'],
      'payment_type': 'konsultasi',
      'reference_id': consultationId,
      'payment_method': 'Simulasi Transfer',
      'total_payment': widget.doctor['consultation_fee'],
      'payment_status': 'berhasil',
      'payment_date': nowIso(),
    });
    await db.insert('consultation_messages', {
      'id_consultation': consultationId,
      'sender_id': widget.user['id_user'],
      'message': complaintController.text.trim(),
      'attachment': photoController.text.trim(),
      'sent_at': nowIso(),
    });
    await db.insert('notifications', {
      'id_user': widget.user['id_user'],
      'title': 'Konsultasi dimulai',
      'message': 'Pembayaran simulasi berhasil. Konsultasi dengan ${widget.doctor['name']} berjalan.',
      'is_read': 0,
      'created_at': nowIso(),
    });
    if (!mounted) return;
    showMessage(context, 'Pembayaran simulasi berhasil. Konsultasi dimulai.');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user, consultationId: consultationId)));
  }

  @override
  void dispose() {
    complaintController.dispose();
    photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Form Konsultasi',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pets(),
        builder: (context, snapshot) {
          final pets = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              InfoBox(
                title: widget.doctor['name'] as String,
                body: '${widget.doctor['specialization']}\nBiaya konsultasi: ${money(widget.doctor['consultation_fee'] as num)}',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: selectedPetId,
                decoration: const InputDecoration(labelText: 'Pilih Hewan'),
                items: pets.map((p) => DropdownMenuItem<int>(value: p['id_pet'] as int, child: Text('${p['pet_name']} - ${p['animal_type']}'))).toList(),
                onChanged: (value) => setState(() => selectedPetId = value),
              ),
              const SizedBox(height: 12),
              TextField(controller: complaintController, decoration: const InputDecoration(labelText: 'Keluhan Hewan'), maxLines: 4),
              const SizedBox(height: 12),
              TextField(controller: photoController, decoration: const InputDecoration(labelText: 'Path foto/lampiran (opsional)')),
              const SizedBox(height: 18),
              ElevatedButton.icon(onPressed: _startConsultation, icon: const Icon(Icons.payment), label: const Text('Bayar Simulasi & Mulai Chat')),
              if (pets.isEmpty) ...[
                const SizedBox(height: 12),
                const InfoBox(title: 'Belum ada hewan', body: 'Tambahkan data hewan terlebih dahulu pada menu Data Hewan.'),
              ],
            ],
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user, required this.consultationId});
  final Map<String, dynamic> user;
  final int consultationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  Future<Map<String, dynamic>> _load() async {
    final db = await AppDatabase.instance.database;
    final consultations = await db.rawQuery('''
      SELECT c.*, p.pet_name, p.animal_type, owner.name AS owner_name, doctorUser.name AS doctor_name, doctorUser.id_user AS doctor_user_id
      FROM consultations c
      JOIN pets p ON p.id_pet = c.id_pet
      JOIN users owner ON owner.id_user = c.id_user
      JOIN doctors d ON d.id_doctor = c.id_doctor
      JOIN users doctorUser ON doctorUser.id_user = d.id_user
      WHERE c.id_consultation = ?
    ''', [widget.consultationId]);
    final messages = await db.rawQuery('''
      SELECT m.*, u.name AS sender_name, u.role
      FROM consultation_messages m
      JOIN users u ON u.id_user = m.sender_id
      WHERE m.id_consultation = ?
      ORDER BY m.id_message ASC
    ''', [widget.consultationId]);
    final records = await db.query('medical_records', where: 'id_consultation = ?', whereArgs: [widget.consultationId], limit: 1);
    return {'consultation': consultations.first, 'messages': messages, 'record': records.isEmpty ? null : records.first};
  }

  Future<void> _send() async {
    if (messageController.text.trim().isEmpty) return;
    final db = await AppDatabase.instance.database;
    await db.insert('consultation_messages', {
      'id_consultation': widget.consultationId,
      'sender_id': widget.user['id_user'],
      'message': messageController.text.trim(),
      'attachment': '',
      'sent_at': nowIso(),
    });
    messageController.clear();
    setState(() {});
  }

  Future<void> _createRecord(Map<String, dynamic> consultation) async {
    final note = TextEditingController();
    final summary = TextEditingController();
    final recommendation = TextEditingController();
    final medicine = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Rekam Medis'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: note, decoration: const InputDecoration(labelText: 'Catatan Dokter'), maxLines: 2),
            const SizedBox(height: 8),
            TextField(controller: summary, decoration: const InputDecoration(labelText: 'Ringkasan Kondisi'), maxLines: 2),
            const SizedBox(height: 8),
            TextField(controller: recommendation, decoration: const InputDecoration(labelText: 'Rekomendasi'), maxLines: 2),
            const SizedBox(height: 8),
            TextField(controller: medicine, decoration: const InputDecoration(labelText: 'Saran Obat'), maxLines: 2),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = await AppDatabase.instance.database;
              await db.insert('medical_records', {
                'id_consultation': widget.consultationId,
                'id_pet': consultation['id_pet'],
                'doctor_note': note.text.trim(),
                'condition_summary': summary.text.trim(),
                'recommendation': recommendation.text.trim(),
                'medicine_suggestion': medicine.text.trim(),
                'record_date': nowIso(),
              });
              await db.update('consultations', {'status': 'selesai'}, where: 'id_consultation = ?', whereArgs: [widget.consultationId]);
              await db.insert('notifications', {
                'id_user': consultation['id_user'],
                'title': 'Konsultasi selesai',
                'message': 'Dokter telah menambahkan rekam medis untuk ${consultation['pet_name']}.',
                'is_read': 0,
                'created_at': nowIso(),
              });
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    note.dispose();
    summary.dispose();
    recommendation.dispose();
    medicine.dispose();
  }

  Future<void> _review(Map<String, dynamic> consultation) async {
    int rating = 5;
    final comment = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Beri Ulasan'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<int>(
              value: rating,
              decoration: const InputDecoration(labelText: 'Rating'),
              items: [1, 2, 3, 4, 5].map((r) => DropdownMenuItem(value: r, child: Text('$r bintang'))).toList(),
              onChanged: (v) => setLocal(() => rating = v ?? 5),
            ),
            const SizedBox(height: 8),
            TextField(controller: comment, decoration: const InputDecoration(labelText: 'Komentar'), maxLines: 2),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final db = await AppDatabase.instance.database;
                final existing = await db.query('reviews', where: 'id_consultation = ?', whereArgs: [widget.consultationId], limit: 1);
                if (existing.isEmpty) {
                  await db.insert('reviews', {
                    'id_user': widget.user['id_user'],
                    'id_doctor': consultation['id_doctor'],
                    'id_consultation': widget.consultationId,
                    'rating': rating,
                    'comment': comment.text.trim(),
                    'review_date': nowIso(),
                  });
                  final avg = await db.rawQuery('SELECT AVG(rating) AS avg_rating FROM reviews WHERE id_doctor = ?', [consultation['id_doctor']]);
                  await db.update('doctors', {'rating': (avg.first['avg_rating'] as num?)?.toDouble() ?? rating.toDouble()}, where: 'id_doctor = ?', whereArgs: [consultation['id_doctor']]);
                }
                if (mounted) Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    comment.dispose();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat Konsultasi',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final consultation = snapshot.data!['consultation'] as Map<String, dynamic>;
          final messages = (snapshot.data!['messages'] as List).cast<Map<String, dynamic>>();
          final record = snapshot.data!['record'] as Map<String, dynamic>?;
          final isDoctor = widget.user['role'] == 'dokter';
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.warmCream.withOpacity(0.7), borderRadius: BorderRadius.circular(18)),
                child: Text('Hewan: ${consultation['pet_name']} (${consultation['animal_type']})\nPemilik: ${consultation['owner_name']}\nDokter: ${consultation['doctor_name']}\nStatus: ${consultation['status']}'),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final mine = m['sender_id'] == widget.user['id_user'];
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        decoration: BoxDecoration(
                          color: mine ? AppColors.lightBlue : AppColors.warmCream,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['sender_name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                          const SizedBox(height: 4),
                          Text(m['message'] as String),
                          if ((m['attachment'] as String?)?.isNotEmpty == true) Text('Lampiran: ${m['attachment']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              if (record != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: InfoBox(title: 'Rekam Medis Tersimpan', body: 'Ringkasan: ${record['condition_summary']}\nRekomendasi: ${record['recommendation']}'),
                ),
              if (isDoctor && record == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _createRecord(consultation), icon: const Icon(Icons.save), label: const Text('Selesaikan & Buat Rekam Medis'))),
                ),
              if (!isDoctor && consultation['status'] == 'selesai')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _review(consultation), icon: const Icon(Icons.star), label: const Text('Beri Rating Dokter'))),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Row(children: [
                    Expanded(child: TextField(controller: messageController, decoration: const InputDecoration(hintText: 'Tulis pesan...'))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _send, child: const Icon(Icons.send)),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    final role = user['role'];
    if (role == 'pemilik') {
      return db.rawQuery('''
        SELECT mr.*, p.pet_name, p.animal_type, u.name AS doctor_name
        FROM medical_records mr
        JOIN pets p ON p.id_pet = mr.id_pet
        JOIN consultations c ON c.id_consultation = mr.id_consultation
        JOIN doctors d ON d.id_doctor = c.id_doctor
        JOIN users u ON u.id_user = d.id_user
        WHERE p.id_user = ?
        ORDER BY mr.id_record DESC
      ''', [user['id_user']]);
    }
    if (role == 'dokter') {
      return db.rawQuery('''
        SELECT mr.*, p.pet_name, p.animal_type, owner.name AS owner_name
        FROM medical_records mr
        JOIN pets p ON p.id_pet = mr.id_pet
        JOIN consultations c ON c.id_consultation = mr.id_consultation
        JOIN doctors d ON d.id_doctor = c.id_doctor
        JOIN users owner ON owner.id_user = c.id_user
        WHERE d.id_user = ?
        ORDER BY mr.id_record DESC
      ''', [user['id_user']]);
    }
    return db.rawQuery('''
      SELECT mr.*, p.pet_name, p.animal_type, owner.name AS owner_name
      FROM medical_records mr
      JOIN pets p ON p.id_pet = mr.id_pet
      JOIN consultations c ON c.id_consultation = mr.id_consultation
      JOIN users owner ON owner.id_user = c.id_user
      ORDER BY mr.id_record DESC
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Rekam Medis',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final records = snapshot.data ?? [];
          if (records.isEmpty) return const EmptyState(text: 'Belum ada rekam medis.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${r['pet_name']} - ${r['animal_type']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                    const SizedBox(height: 8),
                    Text('Catatan: ${r['doctor_note']}'),
                    Text('Ringkasan: ${r['condition_summary']}'),
                    Text('Rekomendasi: ${r['recommendation']}'),
                    Text('Saran obat: ${r['medicine_suggestion']}'),
                    const SizedBox(height: 6),
                    Text('Tanggal: ${r['record_date']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('products', where: 'status = ?', whereArgs: ['aktif'], orderBy: 'id_product DESC');
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    if (product['stock'] == 0) {
      showMessage(context, 'Stok habis.');
      return;
    }
    final db = await AppDatabase.instance.database;
    final existing = await db.query('carts', where: 'id_user = ? AND id_product = ?', whereArgs: [widget.user['id_user'], product['id_product']], limit: 1);
    if (existing.isEmpty) {
      await db.insert('carts', {'id_user': widget.user['id_user'], 'id_product': product['id_product'], 'quantity': 1, 'created_at': nowIso()});
    } else {
      final q = (existing.first['quantity'] as int) + 1;
      await db.update('carts', {'quantity': q}, where: 'id_cart = ?', whereArgs: [existing.first['id_cart']]);
    }
    if (!mounted) return;
    showMessage(context, 'Produk masuk keranjang.');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Toko Produk',
      actions: [IconButton(onPressed: () => push(context, CartScreen(user: widget.user)), icon: const Icon(Icons.shopping_cart))],
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          if (products.isEmpty) return const EmptyState(text: 'Belum ada produk aktif.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.medication, color: AppColors.darkNavy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p['product_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${p['category']} • Stok ${p['stock']}', style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(p['description'] as String),
                          const SizedBox(height: 8),
                          Text(money(p['price'] as num), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                        ]),
                      ),
                      IconButton(onPressed: () => _addToCart(p), icon: const Icon(Icons.add_shopping_cart, color: AppColors.primaryBlue)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.rawQuery('''
      SELECT c.*, p.product_name, p.price, p.stock, p.category
      FROM carts c
      JOIN products p ON p.id_product = c.id_product
      WHERE c.id_user = ?
      ORDER BY c.id_cart DESC
    ''', [widget.user['id_user']]);
  }

  Future<void> _checkout(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;
    final address = TextEditingController(text: widget.user['address']?.toString() ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: TextField(controller: address, decoration: const InputDecoration(labelText: 'Alamat Pengiriman'), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Bayar Simulasi')),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = await AppDatabase.instance.database;
    final total = items.fold<double>(0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));
    await db.transaction((txn) async {
      final orderId = await txn.insert('orders', {
        'id_user': widget.user['id_user'],
        'order_date': nowIso(),
        'total_price': total,
        'shipping_address': address.text.trim(),
        'order_status': 'diproses',
      });
      for (final item in items) {
        final qty = item['quantity'] as int;
        final price = (item['price'] as num).toDouble();
        await txn.insert('order_details', {
          'id_order': orderId,
          'id_product': item['id_product'],
          'quantity': qty,
          'price': price,
          'subtotal': price * qty,
        });
        await txn.rawUpdate('UPDATE products SET stock = stock - ? WHERE id_product = ?', [qty, item['id_product']]);
      }
      await txn.insert('payments', {
        'id_user': widget.user['id_user'],
        'payment_type': 'produk',
        'reference_id': orderId,
        'payment_method': 'Simulasi Transfer',
        'total_payment': total,
        'payment_status': 'berhasil',
        'payment_date': nowIso(),
      });
      await txn.delete('carts', where: 'id_user = ?', whereArgs: [widget.user['id_user']]);
      await txn.insert('notifications', {
        'id_user': widget.user['id_user'],
        'title': 'Pesanan diproses',
        'message': 'Pembayaran simulasi berhasil. Pesanan sedang diproses admin.',
        'is_read': 0,
        'created_at': nowIso(),
      });
    });
    if (!mounted) return;
    showMessage(context, 'Checkout berhasil.');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrdersScreen(user: widget.user)));
  }

  Future<void> _updateQty(int cartId, int qty) async {
    final db = await AppDatabase.instance.database;
    if (qty <= 0) {
      await db.delete('carts', where: 'id_cart = ?', whereArgs: [cartId]);
    } else {
      await db.update('carts', {'quantity': qty}, where: 'id_cart = ?', whereArgs: [cartId]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Keranjang',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final total = items.fold<double>(0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));
          if (items.isEmpty) return const EmptyState(text: 'Keranjang masih kosong.');
          return Column(children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final qty = item['quantity'] as int;
                  return AppCard(
                    child: ListTile(
                      title: Text(item['product_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${money(item['price'] as num)} x $qty'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(onPressed: () => _updateQty(item['id_cart'] as int, qty - 1), icon: const Icon(Icons.remove_circle_outline)),
                        Text('$qty'),
                        IconButton(onPressed: () => _updateQty(item['id_cart'] as int, qty + 1), icon: const Icon(Icons.add_circle_outline)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
                child: Row(children: [
                  Expanded(child: Text('Total\n${money(total)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy))),
                  ElevatedButton(onPressed: () => _checkout(items), child: const Text('Checkout')),
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    if (widget.user['role'] == 'admin') {
      return db.rawQuery('''
        SELECT o.*, u.name AS owner_name FROM orders o
        JOIN users u ON u.id_user = o.id_user
        ORDER BY o.id_order DESC
      ''');
    }
    return db.query('orders', where: 'id_user = ?', whereArgs: [widget.user['id_user']], orderBy: 'id_order DESC');
  }

  Future<void> _setStatus(int orderId, String status) async {
    final db = await AppDatabase.instance.database;
    await db.update('orders', {'order_status': status}, where: 'id_order = ?', whereArgs: [orderId]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.user['role'] == 'admin' ? 'Manajemen Pesanan' : 'Riwayat Pesanan',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) return const EmptyState(text: 'Belum ada pesanan.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('Pesanan #${o['id_order']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      StatusChip(status: o['order_status'] as String),
                    ]),
                    const SizedBox(height: 8),
                    if (widget.user['role'] == 'admin') Text('Pemilik: ${o['owner_name']}'),
                    Text('Total: ${money(o['total_price'] as num)}'),
                    Text('Alamat: ${o['shipping_address']}'),
                    const SizedBox(height: 8),
                    if (widget.user['role'] == 'admin')
                      DropdownButtonFormField<String>(
                        value: o['order_status'] as String,
                        decoration: const InputDecoration(labelText: 'Ubah Status'),
                        items: const ['diproses', 'dikirim', 'selesai', 'batal'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => _setStatus(o['id_order'] as int, v ?? 'diproses'),
                      ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key, required this.user, required this.doctor});
  final Map<String, dynamic> user;
  final Map<String, dynamic>? doctor;

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    if (widget.doctor == null) return [];
    final db = await AppDatabase.instance.database;
    return db.query('doctor_schedules', where: 'id_doctor = ?', whereArgs: [widget.doctor!['id_doctor']], orderBy: 'id_schedule DESC');
  }

  Future<void> _showForm([Map<String, dynamic>? schedule]) async {
    final day = TextEditingController(text: schedule?['day']?.toString() ?? 'Senin - Jumat');
    final start = TextEditingController(text: schedule?['start_time']?.toString() ?? '09:00');
    final end = TextEditingController(text: schedule?['end_time']?.toString() ?? '16:00');
    String status = schedule?['status']?.toString() ?? 'aktif';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: Text(schedule == null ? 'Tambah Jadwal' : 'Ubah Jadwal'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: day, decoration: const InputDecoration(labelText: 'Hari')),
          const SizedBox(height: 8),
          TextField(controller: start, decoration: const InputDecoration(labelText: 'Jam Mulai')),
          const SizedBox(height: 8),
          TextField(controller: end, decoration: const InputDecoration(labelText: 'Jam Selesai')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const ['aktif', 'nonaktif'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setLocal(() => status = v ?? 'aktif'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = await AppDatabase.instance.database;
              final data = {'id_doctor': widget.doctor!['id_doctor'], 'day': day.text, 'start_time': start.text, 'end_time': end.text, 'status': status};
              if (schedule == null) {
                await db.insert('doctor_schedules', data);
              } else {
                await db.update('doctor_schedules', data, where: 'id_schedule = ?', whereArgs: [schedule['id_schedule']]);
              }
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      )),
    );
    day.dispose();
    start.dispose();
    end.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Jadwal Dokter',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final schedules = snapshot.data ?? [];
          if (schedules.isEmpty) return const EmptyState(text: 'Belum ada jadwal.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final s = schedules[index];
              return AppCard(
                child: ListTile(
                  title: Text(s['day'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s['start_time']} - ${s['end_time']} • ${s['status']}'),
                  trailing: IconButton(onPressed: () => _showForm(s), icon: const Icon(Icons.edit)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('users', orderBy: 'id_user DESC');
  }

  Future<void> _toggle(Map<String, dynamic> user) async {
    final db = await AppDatabase.instance.database;
    final next = user['status'] == 'aktif' ? 'nonaktif' : 'aktif';
    await db.update('users', {'status': next}, where: 'id_user = ?', whereArgs: [user['id_user']]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manajemen Pengguna',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return AppCard(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.person, color: AppColors.darkNavy)),
                  title: Text(u['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${u['email']}\nRole: ${u['role']} • Status: ${u['status']}'),
                  isThreeLine: true,
                  trailing: TextButton(onPressed: () => _toggle(u), child: Text(u['status'] == 'aktif' ? 'Nonaktifkan' : 'Aktifkan')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.rawQuery('''
      SELECT d.*, u.name, u.email FROM doctors d
      JOIN users u ON u.id_user = d.id_user
      ORDER BY d.id_doctor DESC
    ''');
  }

  Future<void> _verify(int idDoctor, String status) async {
    final db = await AppDatabase.instance.database;
    await db.update('doctors', {'verification_status': status}, where: 'id_doctor = ?', whereArgs: [idDoctor]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Verifikasi Dokter',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final doctors = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final d = doctors[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${d['email']} • ${d['specialization']}'),
                    const SizedBox(height: 8),
                    StatusChip(status: d['verification_status'] as String),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => _verify(d['id_doctor'] as int, 'ditolak'), child: const Text('Tolak'))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(onPressed: () => _verify(d['id_doctor'] as int, 'diterima'), child: const Text('Setujui'))),
                    ]),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('products', orderBy: 'id_product DESC');
  }

  Future<void> _showForm([Map<String, dynamic>? product]) async {
    final name = TextEditingController(text: product?['product_name']?.toString() ?? '');
    final category = TextEditingController(text: product?['category']?.toString() ?? '');
    final desc = TextEditingController(text: product?['description']?.toString() ?? '');
    final price = TextEditingController(text: product?['price']?.toString() ?? '');
    final stock = TextEditingController(text: product?['stock']?.toString() ?? '');
    String status = product?['status']?.toString() ?? 'aktif';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Ubah Produk'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama Produk')),
          const SizedBox(height: 8),
          TextField(controller: category, decoration: const InputDecoration(labelText: 'Kategori')),
          const SizedBox(height: 8),
          TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
          const SizedBox(height: 8),
          TextField(controller: price, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: stock, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const ['aktif', 'nonaktif'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setLocal(() => status = v ?? 'aktif'),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = await AppDatabase.instance.database;
              final data = {
                'product_name': name.text.trim(),
                'category': category.text.trim(),
                'description': desc.text.trim(),
                'price': double.tryParse(price.text) ?? 0,
                'stock': int.tryParse(stock.text) ?? 0,
                'product_image': '',
                'status': status,
              };
              if (product == null) {
                await db.insert('products', data);
              } else {
                await db.update('products', data, where: 'id_product = ?', whereArgs: [product['id_product']]);
              }
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      )),
    );
    name.dispose();
    category.dispose();
    desc.dispose();
    price.dispose();
    stock.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manajemen Produk',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return AppCard(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.inventory_2, color: AppColors.darkNavy)),
                  title: Text(p['product_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p['category']} • ${money(p['price'] as num)}\nStok: ${p['stock']} • ${p['status']}'),
                  isThreeLine: true,
                  trailing: IconButton(onPressed: () => _showForm(p), icon: const Icon(Icons.edit)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  Future<Map<String, dynamic>> _load() async {
    final db = await AppDatabase.instance.database;
    final summary = await db.rawQuery('''
      SELECT
      (SELECT COUNT(*) FROM consultations) AS consultations,
      (SELECT COUNT(*) FROM medical_records) AS records,
      (SELECT COUNT(*) FROM orders) AS orders_count,
      (SELECT COALESCE(SUM(total_payment), 0) FROM payments WHERE payment_status = 'berhasil') AS revenue
    ''');
    final topProducts = await db.rawQuery('''
      SELECT p.product_name, COALESCE(SUM(od.quantity), 0) AS sold
      FROM products p
      LEFT JOIN order_details od ON od.id_product = p.id_product
      GROUP BY p.id_product
      ORDER BY sold DESC
      LIMIT 5
    ''');
    final topDoctors = await db.rawQuery('''
      SELECT u.name, COUNT(c.id_consultation) AS total
      FROM doctors d
      JOIN users u ON u.id_user = d.id_user
      LEFT JOIN consultations c ON c.id_doctor = d.id_doctor
      GROUP BY d.id_doctor
      ORDER BY total DESC
      LIMIT 5
    ''');
    return {'summary': summary.first, 'topProducts': topProducts, 'topDoctors': topDoctors};
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Laporan',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final summary = snapshot.data!['summary'] as Map<String, dynamic>;
          final topProducts = (snapshot.data!['topProducts'] as List).cast<Map<String, dynamic>>();
          final topDoctors = (snapshot.data!['topDoctors'] as List).cast<Map<String, dynamic>>();
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Wrap(spacing: 10, runSpacing: 10, children: [
                StatCard(label: 'Konsultasi', value: '${summary['consultations']}'),
                StatCard(label: 'Rekam Medis', value: '${summary['records']}'),
                StatCard(label: 'Pesanan', value: '${summary['orders_count']}'),
                StatCard(label: 'Pendapatan', value: money(summary['revenue'] as num)),
              ]),
              const SizedBox(height: 18),
              const SectionTitle('Produk Terlaris'),
              for (final p in topProducts) AppCard(child: ListTile(title: Text(p['product_name'] as String), trailing: Text('${p['sold']} terjual'))),
              const SizedBox(height: 18),
              const SectionTitle('Dokter Dengan Konsultasi Terbanyak'),
              for (final d in topDoctors) AppCard(child: ListTile(title: Text(d['name'] as String), trailing: Text('${d['total']} konsultasi'))),
            ],
          );
        },
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('notifications', where: 'id_user = ?', whereArgs: [widget.user['id_user']], orderBy: 'id_notification DESC');
  }

  Future<void> _markRead(int id) async {
    final db = await AppDatabase.instance.database;
    await db.update('notifications', {'is_read': 1}, where: 'id_notification = ?', whereArgs: [id]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Notifikasi',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const EmptyState(text: 'Belum ada notifikasi.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final n = items[index];
              final read = n['is_read'] == 1;
              return AppCard(
                child: ListTile(
                  leading: Icon(read ? Icons.notifications_none : Icons.notifications_active, color: AppColors.primaryBlue),
                  title: Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${n['message']}\n${n['created_at']}'),
                  isThreeLine: true,
                  trailing: read ? null : TextButton(onPressed: () => _markRead(n['id_notification'] as int), child: const Text('Baca')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: child,
    );
  }
}

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key, required this.name, required this.subtitle, required this.icon});
  final String name;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.lightBlue, Colors.white]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        CircleAvatar(radius: 30, backgroundColor: AppColors.darkNavy, child: Icon(icon, color: Colors.white, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(icon, color: AppColors.darkNavy)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox({super.key, required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.warmCream.withOpacity(0.7), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.warmCream)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
        const SizedBox(height: 6),
        Text(body),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.inbox, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (status == 'berhasil' || status == 'selesai' || status == 'diterima') {
      color = AppColors.success;
    } else if (status == 'menunggu' || status == 'diproses' || status == 'dikirim') {
      color = AppColors.warning;
    } else if (status == 'batal' || status == 'gagal' || status == 'ditolak') {
      color = AppColors.error;
    } else {
      color = AppColors.primaryBlue;
    }
    return Chip(
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.3)),
      label: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}

Widget statusIcon(String status) {
  final icon = status == 'selesai' ? Icons.check_circle : status == 'batal' ? Icons.cancel : Icons.chat;
  final color = status == 'selesai' ? AppColors.success : status == 'batal' ? AppColors.error : AppColors.primaryBlue;
  return CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color));
}

void push(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

void logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
