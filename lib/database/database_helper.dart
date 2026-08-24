import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';
import 'pg_wrapper.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  PgDatabase? _database;

  Future<PgDatabase> get database async => _database ??= await _init();

  int? _firstIntValue(List<Map<String, dynamic>> list) {
    if (list.isNotEmpty && list.first.isNotEmpty) {
      final value = list.first.values.first;
      if (value is int) return value;
      if (value != null) return int.tryParse(value.toString());
    }
    return null;
  }

    Future<PgDatabase> _init() async {
      final conn = await Connection.open(
      Endpoint(
        host: dotenv.env['DB_HOST'] ?? 'localhost',
        port: int.parse(dotenv.env['DB_PORT'] ?? '5432'),
        database: dotenv.env['DB_NAME'] ?? 'postgres',
        username: dotenv.env['DB_USER'] ?? 'postgres',
        password: dotenv.env['DB_PASSWORD'],
      ),
      settings: ConnectionSettings(sslMode: SslMode.require),
    );

    final pgDb = PgDatabase(conn);
    
      // Check if DB is in a broken state (users exists but doctors doesn't)
      bool brokenState = false;
      try {
        final u = await pgDb.rawQuery("SELECT 1 FROM information_schema.tables WHERE table_name = 'users'");
        final d = await pgDb.rawQuery("SELECT 1 FROM information_schema.tables WHERE table_name = 'doctors'");
        if (u.isNotEmpty && d.isEmpty) brokenState = true;
      } catch(_) {}

      if (brokenState) {
        // WIPE DB ONCE to fix broken state
        final tables = [
          'reviews', 'monitoring_logs', 'medicine_orders', 'prescription_items',
          'prescriptions', 'consultation_results', 'notifications', 'medical_records',
          'messages', 'screenings', 'complaints', 'consultations', 'schedules',
          'diseases', 'vaccinations', 'pets', 'doctors', 'help_tickets', 'users',
          'services', 'medicines'
        ];
        for (var t in tables) {
          try { await pgDb.execute('DROP TABLE IF EXISTS $t CASCADE'); } catch(_) {}
        }
      }

      try {
        await _onCreate(pgDb, 1);
        // Wait for table creation then try seeding
        await _seed(pgDb);

    } catch (e) {
      print('Database init error: $e');
    }
    
    return pgDb;
  }

  Future<void> _onCreate(PgDatabase db, int version) async {
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS users(id SERIAL PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, phone TEXT DEFAULT '', photo TEXT DEFAULT '', role TEXT NOT NULL, created_at TEXT NOT NULL)''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS doctors(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL UNIQUE, specialist TEXT NOT NULL, license TEXT NOT NULL, rating REAL DEFAULT 0, experience INTEGER DEFAULT 0, bio TEXT DEFAULT '', consultation_fee REAL DEFAULT 50000, verified INTEGER DEFAULT 1, FOREIGN KEY(user_id) REFERENCES users(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS pets(id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id INTEGER NOT NULL, name TEXT NOT NULL, species TEXT NOT NULL, breed TEXT DEFAULT '', gender TEXT DEFAULT '', age INTEGER DEFAULT 0, weight REAL DEFAULT 0, photo TEXT DEFAULT '', tanggal_lahir TEXT DEFAULT '', warna_ciri TEXT DEFAULT '', status_steril TEXT DEFAULT 'Belum Steril', alergi TEXT DEFAULT '', additional_photos TEXT DEFAULT '[]', microchip_id TEXT DEFAULT '', blood_type TEXT DEFAULT '', FOREIGN KEY(owner_id) REFERENCES users(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS vaccinations(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, name TEXT NOT NULL, date TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Aktif', next_date TEXT DEFAULT '', brand TEXT DEFAULT '', batch_number TEXT DEFAULT '', FOREIGN KEY(pet_id) REFERENCES pets(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS diseases(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, name TEXT NOT NULL, date TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Sembuh', FOREIGN KEY(pet_id) REFERENCES pets(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS schedules(id INTEGER PRIMARY KEY AUTOINCREMENT, doctor_id INTEGER NOT NULL, date TEXT NOT NULL, time TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'available', max_patients INTEGER NOT NULL DEFAULT 1, FOREIGN KEY(doctor_id) REFERENCES doctors(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS consultations(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, doctor_id INTEGER NOT NULL, schedule_id INTEGER, complaint TEXT NOT NULL, method TEXT DEFAULT 'Chat', status TEXT NOT NULL DEFAULT 'waiting', is_control INTEGER DEFAULT 0, parent_consultation_id INTEGER, created_at TEXT NOT NULL, FOREIGN KEY(pet_id) REFERENCES pets(id), FOREIGN KEY(doctor_id) REFERENCES doctors(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS complaints(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, service_type TEXT DEFAULT '', main_complaints TEXT DEFAULT '', duration TEXT DEFAULT '', appetite TEXT DEFAULT '', activity TEXT DEFAULT '', urine TEXT DEFAULT '', feces TEXT DEFAULT '', vomit INTEGER DEFAULT 0, respiratory TEXT DEFAULT '', skin_coat TEXT DEFAULT '', medication TEXT DEFAULT '', photos_videos TEXT DEFAULT '', water_intake TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS screenings(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, difficulty_breathing INTEGER DEFAULT 0, seizures INTEGER DEFAULT 0, unconscious INTEGER DEFAULT 0, heavy_bleeding INTEGER DEFAULT 0, severe_trauma INTEGER DEFAULT 0, cannot_stand INTEGER DEFAULT 0, poisoning INTEGER DEFAULT 0, cannot_urinate INTEGER DEFAULT 0, continuous_vomiting INTEGER DEFAULT 0, result_category TEXT DEFAULT 'Ringan', mucous_membrane TEXT DEFAULT '', crt TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, sender_id INTEGER NOT NULL, message TEXT NOT NULL, is_read INTEGER DEFAULT 0, created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS medical_records(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, doctor_id INTEGER NOT NULL, consultation_id INTEGER, diagnosis TEXT NOT NULL, treatment TEXT DEFAULT '', medicine TEXT DEFAULT '', notes TEXT DEFAULT '', date TEXT NOT NULL, temperature REAL DEFAULT 0, heart_rate INTEGER DEFAULT 0, respiratory_rate INTEGER DEFAULT 0, weight_at_visit REAL DEFAULT 0, FOREIGN KEY(pet_id) REFERENCES pets(id), FOREIGN KEY(doctor_id) REFERENCES doctors(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT NOT NULL, message TEXT NOT NULL, is_read INTEGER DEFAULT 0, created_at TEXT NOT NULL)''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS consultation_results(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, observation TEXT DEFAULT '', diagnosis TEXT DEFAULT '', advice TEXT DEFAULT '', forbidden TEXT DEFAULT '', warning_signs TEXT DEFAULT '', follow_up TEXT DEFAULT '', control_decision TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS prescriptions(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, notes TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS prescription_items(id INTEGER PRIMARY KEY AUTOINCREMENT, prescription_id INTEGER NOT NULL, medicine_name TEXT NOT NULL, form TEXT DEFAULT '', dose TEXT DEFAULT '', frequency TEXT DEFAULT '', duration TEXT DEFAULT '', method TEXT DEFAULT '', qty TEXT DEFAULT '', FOREIGN KEY(prescription_id) REFERENCES prescriptions(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS medicine_orders(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, delivery_address TEXT NOT NULL, medicine_price REAL DEFAULT 0, delivery_fee REAL DEFAULT 0, total_price REAL DEFAULT 0, status TEXT NOT NULL DEFAULT 'waiting_payment', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS monitoring_logs(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, date TEXT NOT NULL, appetite TEXT DEFAULT '', activity TEXT DEFAULT '', condition TEXT DEFAULT '', symptoms TEXT DEFAULT '', medicine_effects TEXT DEFAULT '', photo TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS reviews(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL UNIQUE, rating_doctor REAL DEFAULT 0, rating_info REAL DEFAULT 0, rating_app REAL DEFAULT 0, rating_quality REAL DEFAULT 0, review_text TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS help_tickets(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, category TEXT NOT NULL, description TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open', admin_reply TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id))''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS services(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, category TEXT NOT NULL, price REAL NOT NULL, status TEXT DEFAULT 'Aktif')''');
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS medicines(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, category TEXT NOT NULL, stock INTEGER NOT NULL, price REAL NOT NULL, status TEXT DEFAULT 'Tersedia')''');

    await _seed(db);
  }

  Future<void> _onUpgrade(PgDatabase db, int oldVersion, int newVersion) async {
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE schedules ADD COLUMN max_patients INTEGER NOT NULL DEFAULT 1');
      } catch (e) {
        // column might exist
      }
    }
    if (oldVersion < 9) {
      try {
        await db.execute('ALTER TABLE messages ADD COLUMN is_read INTEGER DEFAULT 0');
      } catch (e) {
        // column might exist
      }
    }
    if (oldVersion < 2) {
      await db
          .execute('ALTER TABLE pets ADD COLUMN tanggal_lahir TEXT DEFAULT ""');
      await db
          .execute('ALTER TABLE pets ADD COLUMN warna_ciri TEXT DEFAULT ""');
      await db.execute(
          'ALTER TABLE pets ADD COLUMN status_steril TEXT DEFAULT "Belum Steril"');
      await db.execute('ALTER TABLE pets ADD COLUMN alergi TEXT DEFAULT ""');

      await db.execute(
          '''CREATE TABLE vaccinations(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, name TEXT NOT NULL, date TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Aktif', next_date TEXT DEFAULT '', FOREIGN KEY(pet_id) REFERENCES pets(id))''');
      await db.execute(
          '''CREATE TABLE diseases(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, name TEXT NOT NULL, date TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Sembuh', FOREIGN KEY(pet_id) REFERENCES pets(id))''');

      final rows =
          await db.query('pets', where: 'name = ?', whereArgs: ['Milo']);
      if (rows.isNotEmpty) {
        final petId = rows.first['id'];
        await db.update(
            'pets',
            {
              'tanggal_lahir': '12 Mei 2023',
              'warna_ciri': 'Bulu coklat keemasan'
            },
            where: 'id = ?',
            whereArgs: [petId]);
        await db.insert('vaccinations', {
          'pet_id': petId,
          'name': 'Vaksin Rabies',
          'date': '10 Jan 2025',
          'status': 'Aktif',
          'next_date': '10 Jan 2026'
        });
        await db.insert('vaccinations', {
          'pet_id': petId,
          'name': 'Vaksin DHPPI',
          'date': '10 Jan 2025',
          'status': 'Aktif',
          'next_date': ''
        });
        await db.insert('vaccinations', {
          'pet_id': petId,
          'name': 'Vaksin Leptospirosis',
          'date': '17 Feb 2025',
          'status': 'Aktif',
          'next_date': ''
        });
        await db.insert('diseases', {
          'pet_id': petId,
          'name': 'Dermatitis',
          'date': '5 Des 2024',
          'status': 'Sembuh'
        });
        await db.insert('diseases', {
          'pet_id': petId,
          'name': 'Infeksi Telinga',
          'date': '12 Nov 2024',
          'status': 'Sembuh'
        });
      }
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE doctors ADD COLUMN consultation_fee REAL DEFAULT 50000');
      await db.execute(
          '''CREATE TABLE complaints(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, service_type TEXT DEFAULT '', main_complaints TEXT DEFAULT '', duration TEXT DEFAULT '', appetite TEXT DEFAULT '', activity TEXT DEFAULT '', urine TEXT DEFAULT '', feces TEXT DEFAULT '', vomit INTEGER DEFAULT 0, respiratory TEXT DEFAULT '', skin_coat TEXT DEFAULT '', medication TEXT DEFAULT '', photos_videos TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
      await db.execute(
          '''CREATE TABLE screenings(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, difficulty_breathing INTEGER DEFAULT 0, seizures INTEGER DEFAULT 0, unconscious INTEGER DEFAULT 0, heavy_bleeding INTEGER DEFAULT 0, severe_trauma INTEGER DEFAULT 0, cannot_stand INTEGER DEFAULT 0, poisoning INTEGER DEFAULT 0, cannot_urinate INTEGER DEFAULT 0, continuous_vomiting INTEGER DEFAULT 0, result_category TEXT DEFAULT 'Ringan', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');

      // Update dummy doctor fee
      await db.update('doctors', {'consultation_fee': 75000});
    }
    if (oldVersion < 4) {
      await db.execute(
          "ALTER TABLE consultations ADD COLUMN method TEXT DEFAULT 'Chat'");
    }
    if (oldVersion < 5) {
      await db.execute(
          '''CREATE TABLE consultation_results(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, observation TEXT DEFAULT '', diagnosis TEXT DEFAULT '', advice TEXT DEFAULT '', forbidden TEXT DEFAULT '', warning_signs TEXT DEFAULT '', follow_up TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
      await db.execute(
          '''CREATE TABLE prescriptions(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, notes TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
      await db.execute(
          '''CREATE TABLE prescription_items(id INTEGER PRIMARY KEY AUTOINCREMENT, prescription_id INTEGER NOT NULL, medicine_name TEXT NOT NULL, form TEXT DEFAULT '', dose TEXT DEFAULT '', frequency TEXT DEFAULT '', duration TEXT DEFAULT '', method TEXT DEFAULT '', qty TEXT DEFAULT '', FOREIGN KEY(prescription_id) REFERENCES prescriptions(id))''');
      await db.execute(
          '''CREATE TABLE medicine_orders(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, delivery_address TEXT NOT NULL, medicine_price REAL DEFAULT 0, delivery_fee REAL DEFAULT 0, total_price REAL DEFAULT 0, status TEXT NOT NULL DEFAULT 'waiting_payment', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
      await db.execute(
          '''CREATE TABLE monitoring_logs(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, date TEXT NOT NULL, appetite TEXT DEFAULT '', activity TEXT DEFAULT '', condition TEXT DEFAULT '', symptoms TEXT DEFAULT '', medicine_effects TEXT DEFAULT '', photo TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    }
    if (oldVersion < 6) {
      await db.execute(
          "ALTER TABLE consultations ADD COLUMN is_control INTEGER DEFAULT 0");
      await db.execute(
          "ALTER TABLE consultations ADD COLUMN parent_consultation_id INTEGER");
      await db.execute(
          "ALTER TABLE consultation_results ADD COLUMN control_decision TEXT DEFAULT ''");
      await db.execute(
          '''CREATE TABLE reviews(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL UNIQUE, rating_doctor REAL DEFAULT 0, rating_info REAL DEFAULT 0, rating_app REAL DEFAULT 0, rating_quality REAL DEFAULT 0, review_text TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
      await db.execute(
          '''CREATE TABLE help_tickets(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, category TEXT NOT NULL, description TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open', admin_reply TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id))''');
    }
    if (oldVersion < 7) {
      await db.execute("ALTER TABLE users ADD COLUMN photo TEXT DEFAULT ''");
    }
    if (oldVersion < 8) {
      await db.execute("ALTER TABLE pets ADD COLUMN additional_photos TEXT DEFAULT '[]'");
    }
    if (oldVersion < 10) {
      final now = DateTime.now().toIso8601String();
      final doc2Id = await db.insert('users', {
        'name': 'drh. Budi Santoso',
        'email': 'doctor2@halopet.com',
        'password_hash': hashPassword('123456'),
        'phone': '081234567893',
        'role': 'doctor',
        'created_at': now
      });
      await db.insert('doctors', {
        'user_id': doc2Id,
        'specialist': 'Hewan Besar',
        'license': 'SIP-HP-002',
        'rating': 4.9,
        'experience': 10,
        'bio': 'Spesialis hewan ternak dan hewan besar dengan pengalaman 10 tahun.',
        'consultation_fee': 100000,
        'verified': 1
      });
      final doc3Id = await db.insert('users', {
        'name': 'drh. Citra Lestari',
        'email': 'doctor3@halopet.com',
        'password_hash': hashPassword('123456'),
        'phone': '081234567894',
        'role': 'doctor',
        'created_at': now
      });
      await db.insert('doctors', {
        'user_id': doc3Id,
        'specialist': 'Hewan Eksotik',
        'license': 'SIP-HP-003',
        'rating': 4.7,
        'experience': 5,
        'bio': 'Penyayang hewan eksotik, siap membantu reptil dan burung kesayangan Anda.',
        'consultation_fee': 150000,
        'verified': 1
      });
    }
    if (oldVersion < 12) {
      await db.execute(
          '''CREATE TABLE services(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, category TEXT NOT NULL, price REAL NOT NULL, status TEXT DEFAULT 'Aktif')''');
      await db.execute(
          '''CREATE TABLE medicines(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, category TEXT NOT NULL, stock INTEGER NOT NULL, price REAL NOT NULL, status TEXT DEFAULT 'Tersedia')''');
      // Tambah dummy services
      await db.insert('services', {'name': 'Vaksinasi Rabies', 'category': 'Vaksin', 'price': 150000});
      await db.insert('services', {'name': 'Sterilisasi Kucing', 'category': 'Operasi', 'price': 500000});
      await db.insert('services', {'name': 'Grooming Lengkap', 'category': 'Perawatan', 'price': 100000});
      // Tambah dummy medicines
      await db.insert('medicines', {'name': 'Amoxicillin 250mg', 'category': 'Antibiotik', 'stock': 120, 'price': 50000});
      await db.insert('medicines', {'name': 'Vaksin Feline Trio', 'category': 'Vaksin', 'stock': 35, 'price': 200000});
      await db.insert('medicines', {'name': 'Drontal Cat', 'category': 'Obat Cacing', 'stock': 0, 'price': 25000, 'status': 'Habis'});
    }
    if (oldVersion < 13) {
      await db.execute("ALTER TABLE pets ADD COLUMN microchip_id TEXT DEFAULT ''");
      await db.execute("ALTER TABLE pets ADD COLUMN blood_type TEXT DEFAULT ''");
      
      await db.execute("ALTER TABLE medical_records ADD COLUMN temperature REAL DEFAULT 0");
      await db.execute("ALTER TABLE medical_records ADD COLUMN heart_rate INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE medical_records ADD COLUMN respiratory_rate INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE medical_records ADD COLUMN weight_at_visit REAL DEFAULT 0");
      
      await db.execute("ALTER TABLE vaccinations ADD COLUMN brand TEXT DEFAULT ''");
      await db.execute("ALTER TABLE vaccinations ADD COLUMN batch_number TEXT DEFAULT ''");
      
      await db.execute("ALTER TABLE screenings ADD COLUMN mucous_membrane TEXT DEFAULT ''");
      await db.execute("ALTER TABLE screenings ADD COLUMN crt TEXT DEFAULT ''");
      
      await db.execute("ALTER TABLE complaints ADD COLUMN water_intake TEXT DEFAULT ''");
    }
  }

  String hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> _seed(PgDatabase db) async {
    final count = _firstIntValue(
            await db.rawQuery("SELECT COUNT(*) FROM users WHERE email = 'owner@halopet.com'")) ??
        0;
    if (count > 0) return; // Only return if owner is already seeded

    final now = DateTime.now().toIso8601String();
    
    // Use raw queries with ON CONFLICT DO NOTHING to avoid crashing if partially seeded
    await db.execute('''
      INSERT INTO users (name, email, password_hash, phone, role, created_at) 
      VALUES ('Adel Pemilik', 'owner@halopet.com', '${hashPassword('123456')}', '081234567890', 'owner', '$now')
      ON CONFLICT (email) DO NOTHING
    ''');
    
    final ownerRows = await db.rawQuery("SELECT id FROM users WHERE email = 'owner@halopet.com'");
    if (ownerRows.isEmpty) return;
    final ownerId = ownerRows.first['id'] as int;
    final doctorUserId = await db.insert('users', {
      'name': 'drh. Andi Pratama',
      'email': 'doctor@halopet.com',
      'password_hash': hashPassword('123456'),
      'phone': '081234567891',
      'role': 'doctor',
      'created_at': now
    });
    await db.insert('users', {
      'name': 'Administrator HaloPet',
      'email': 'admin@halopet.com',
      'password_hash': hashPassword('123456'),
      'phone': '081234567892',
      'role': 'admin',
      'created_at': now
    });
    final doctorId = await db.insert('doctors', {
      'user_id': doctorUserId,
      'specialist': 'Hewan Kecil',
      'license': 'SIP-HP-001',
      'rating': 4.8,
      'experience': 7,
      'bio': 'Dokter hewan dengan fokus pada kesehatan kucing dan anjing.',
      'consultation_fee': 75000,
      'verified': 1
    });

    final doc2Id = await db.insert('users', {
      'name': 'drh. Budi Santoso',
      'email': 'doctor2@halopet.com',
      'password_hash': hashPassword('123456'),
      'phone': '081234567893',
      'role': 'doctor',
      'created_at': now
    });
    await db.insert('doctors', {
      'user_id': doc2Id,
      'specialist': 'Hewan Besar',
      'license': 'SIP-HP-002',
      'rating': 4.9,
      'experience': 10,
      'bio': 'Spesialis hewan ternak dan hewan besar dengan pengalaman 10 tahun.',
      'consultation_fee': 100000,
      'verified': 1
    });

    final doc3Id = await db.insert('users', {
      'name': 'drh. Citra Lestari',
      'email': 'doctor3@halopet.com',
      'password_hash': hashPassword('123456'),
      'phone': '081234567894',
      'role': 'doctor',
      'created_at': now
    });
    await db.insert('doctors', {
      'user_id': doc3Id,
      'specialist': 'Hewan Eksotik',
      'license': 'SIP-HP-003',
      'rating': 4.7,
      'experience': 5,
      'bio': 'Penyayang hewan eksotik, siap membantu reptil dan burung kesayangan Anda.',
      'consultation_fee': 150000,
      'verified': 1
    });
    final petId = await db.insert('pets', {
      'owner_id': ownerId,
      'name': 'Milo',
      'species': 'Kucing',
      'breed': 'Persia',
      'gender': 'Jantan',
      'age': 2,
      'weight': 4.2,
      'photo': '',
      'tanggal_lahir': '12 Mei 2023',
      'warna_ciri': 'Bulu coklat keemasan',
      'status_steril': 'Belum Steril',
      'alergi': ''
    });

    // Seed new tables
    await db.insert('vaccinations', {
      'pet_id': petId,
      'name': 'Vaksin Rabies',
      'date': '10 Jan 2025',
      'status': 'Aktif',
      'next_date': '10 Jan 2026'
    });
    await db.insert('vaccinations', {
      'pet_id': petId,
      'name': 'Vaksin DHPPI',
      'date': '10 Jan 2025',
      'status': 'Aktif',
      'next_date': ''
    });
    await db.insert('vaccinations', {
      'pet_id': petId,
      'name': 'Vaksin Leptospirosis',
      'date': '17 Feb 2025',
      'status': 'Aktif',
      'next_date': ''
    });
    await db.insert('diseases', {
      'pet_id': petId,
      'name': 'Dermatitis',
      'date': '5 Des 2024',
      'status': 'Sembuh'
    });
    await db.insert('diseases', {
      'pet_id': petId,
      'name': 'Infeksi Telinga',
      'date': '12 Nov 2024',
      'status': 'Sembuh'
    });

    final dates =
        List.generate(14, (i) => DateTime.now().add(Duration(days: i + 1)))
            .where((d) => d.weekday >= 1 && d.weekday <= 5)
            .toList();
    for (final date in dates) {
      final ds =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      for (final time in ['09:00', '11:00', '14:00']) {
        await db.insert('schedules', {
          'doctor_id': doctorId,
          'date': ds,
          'time': time,
          'status': 'available'
        });
      }
    }
    await db.insert('medical_records', {
      'pet_id': petId,
      'doctor_id': doctorId,
      'consultation_id': null,
      'diagnosis': 'Pemeriksaan rutin',
      'treatment': 'Pemeriksaan fisik dan suhu tubuh',
      'medicine': 'Vitamin hewan',
      'notes': 'Kondisi sehat. Jaga pola makan dan hidrasi.',
      'date': now
    });
  }

  Future<Map<String, Object?>?> login(String email, String password) async {
    final db = await database;
    final rows = await db.query('users',
        where: 'LOWER(email) = ? AND password_hash = ?',
        whereArgs: [email.toLowerCase().trim(), hashPassword(password)],
        limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> registerOwner(
      {required String name,
      required String email,
      required String password,
      required String phone}) async {
    final db = await database;

    final existing = await db.query('users',
        where: 'LOWER(email) = ? OR phone = ?',
        whereArgs: [email.toLowerCase().trim(), phone],
        limit: 1);
        
    if (existing.isNotEmpty) {
      final row = existing.first;
      if ((row['email'] as String).toLowerCase() == email.toLowerCase().trim()) {
        throw Exception('Email sudah terdaftar.');
      }
      if (row['phone'] == phone) {
        throw Exception('Nomor telepon sudah terdaftar.');
      }
    }

    return db.insert('users', {
      'name': name,
      'email': email.toLowerCase().trim(),
      'password_hash': hashPassword(password),
      'phone': phone,
      'role': 'owner',
      'created_at': DateTime.now().toIso8601String()
    });
  }

  Future<List<Map<String, Object?>>> getPets(int ownerId) async =>
      (await database).query('pets',
          where: 'owner_id = ?', whereArgs: [ownerId], orderBy: 'id DESC');
  Future<int> addPet(Map<String, Object?> data) async =>
      (await database).insert('pets', data);
  Future<int> updatePet(int id, Map<String, Object?> data) async =>
      (await database).update('pets', data, where: 'id = ?', whereArgs: [id]);
  Future<int> deletePet(int id) async =>
      (await database).delete('pets', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, Object?>>> getVaccinations(int petId) async =>
      (await database).query('vaccinations',
          where: 'pet_id = ?', whereArgs: [petId], orderBy: 'id DESC');
  Future<int> addVaccination(Map<String, Object?> data) async =>
      (await database).insert('vaccinations', data);
  Future<int> deleteVaccination(int id) async =>
      (await database).delete('vaccinations', where: 'id = ?', whereArgs: [id]);
  Future<int> clearVaccinations(int petId) async =>
      (await database).delete('vaccinations', where: 'pet_id = ?', whereArgs: [petId]);

  Future<List<Map<String, Object?>>> getDiseases(int petId) async =>
      (await database).query('diseases',
          where: 'pet_id = ?', whereArgs: [petId], orderBy: 'id DESC');
  Future<int> addDisease(Map<String, Object?> data) async =>
      (await database).insert('diseases', data);
  Future<int> deleteDisease(int id) async =>
      (await database).delete('diseases', where: 'id = ?', whereArgs: [id]);
  Future<int> clearDiseases(int petId) async =>
      (await database).delete('diseases', where: 'pet_id = ?', whereArgs: [petId]);

  Future<List<Map<String, Object?>>> getDoctors() async {
    return (await database).rawQuery(
        '''SELECT d.*, u.name, u.email, u.phone FROM doctors d JOIN users u ON u.id=d.user_id WHERE d.verified=1 ORDER BY d.rating DESC''');
  }

  Future<Map<String, Object?>?> getDoctorByUser(int userId) async {
    final rows = await (await database).rawQuery(
        '''SELECT d.*, u.name, u.email, u.phone FROM doctors d JOIN users u ON u.id=d.user_id WHERE d.user_id=? LIMIT 1''',
        [userId]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> getSchedules(int doctorId) async =>
      (await database).query('schedules',
          where: 'doctor_id=?', whereArgs: [doctorId], orderBy: 'date, time');

  Future<int> insertSchedule(Map<String, dynamic> schedule) async {
    return (await database).insert('schedules', schedule);
  }

  Future<int> deleteSchedule(int id) async =>
      (await database).delete('schedules', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getDoctorCalendarEvents(int doctorId) async {
    final rows = await (await database).rawQuery(
        '''SELECT s.id as schedule_id, s.date, s.time, s.status as schedule_status, s.max_patients, 
                  c.status as consultation_status, c.is_control, 
                  p.name as pet_name, p.breed 
           FROM schedules s 
           LEFT JOIN consultations c ON c.schedule_id = s.id 
           LEFT JOIN pets p ON p.id = c.pet_id 
           WHERE s.doctor_id=? 
           ORDER BY s.date, s.time''',
        [doctorId]);
        
    return rows.map((r) {
       return {
          'schedule_id': r['schedule_id'],
          'date': r['date'],
          'time': r['time'],
          'max_patients': r['max_patients'] ?? 1,
          'pet': r['pet_name'] ?? 'Tersedia',
          'breed': r['breed'] ?? '-',
          'type': (r['is_control'] == 1) ? 'Kontrol' : 'Konsultasi Online',
          'status': r['consultation_status'] ?? r['schedule_status'],
       };
    }).toList();
  }

  Future<int> createConsultation(
      {required int petId,
      required int doctorId,
      required int scheduleId,
      required String complaint,
      String method = 'Chat',
      int isControl = 0,
      int? parentConsultationId}) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert('consultations', {
        'pet_id': petId,
        'doctor_id': doctorId,
        'schedule_id': scheduleId,
        'complaint': complaint,
        'method': method,
        'status': 'waiting_payment',
        'is_control': isControl,
        'parent_consultation_id': parentConsultationId,
        'created_at': DateTime.now().toIso8601String()
      });
      await txn.update('schedules', {'status': 'booked'},
          where: 'id=?', whereArgs: [scheduleId]);
      return id;
    });
  }

  Future<int> createConsultationWithDetails({
    required int petId,
    required int doctorId,
    required int scheduleId,
    required String complaint, // This maps to legacy "complaint" field
    required String method,
    required Map<String, Object?> complaintData,
    required Map<String, Object?> screeningData,
    int isControl = 0,
    int? parentConsultationId,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert('consultations', {
        'pet_id': petId,
        'doctor_id': doctorId,
        'schedule_id': scheduleId,
        'complaint': complaint,
        'method': method,
        'status': 'waiting_payment',
        'is_control': isControl,
        'parent_consultation_id': parentConsultationId,
        'created_at': DateTime.now().toIso8601String()
      });

      complaintData['consultation_id'] = id;
      screeningData['consultation_id'] = id;

      await txn.insert('complaints', complaintData);
      await txn.insert('screenings', screeningData);

      await txn.update('schedules', {'status': 'booked'},
          where: 'id=?', whereArgs: [scheduleId]);
      return id;
    });
  }

  Future<List<Map<String, Object?>>> getOwnerConsultations(int ownerId) async {
    return (await database).rawQuery(
        '''SELECT c.*, p.name pet_name, p.species, u.name doctor_name, d.specialist, s.date schedule_date, s.time schedule_time, r.id as review_id FROM consultations c JOIN pets p ON p.id=c.pet_id JOIN doctors d ON d.id=c.doctor_id JOIN users u ON u.id=d.user_id LEFT JOIN schedules s ON s.id=c.schedule_id LEFT JOIN reviews r ON r.consultation_id=c.id WHERE p.owner_id=? ORDER BY c.id DESC''',
        [ownerId]);
  }

  Future<Map<String, dynamic>> getConsultationDetails(int consultationId) async {
    final db = await database;
    final complaints = await db.query('complaints', where: 'consultation_id=?', whereArgs: [consultationId]);
    final screenings = await db.query('screenings', where: 'consultation_id=?', whereArgs: [consultationId]);
    
    return {
      'complaint': complaints.isNotEmpty ? complaints.first : null,
      'screening': screenings.isNotEmpty ? screenings.first : null,
    };
  }

  Future<List<Map<String, dynamic>>> getDoctorPatients(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT p.id as pet_id, p.name as pet_name, p.breed as pet_breed, u.name as owner_name
      FROM consultations c
      JOIN pets p ON c.pet_id = p.id
      JOIN users u ON p.owner_id = u.id
      WHERE c.doctor_id = ?
    ''', [doctorId]);
    return maps;
  }

  Future<List<Map<String, Object?>>> getDoctorConsultations(
      int doctorId) async {
    return (await database).rawQuery(
        '''SELECT c.*, p.name pet_name, p.species, p.breed, u.name owner_name, s.date schedule_date, s.time schedule_time FROM consultations c JOIN pets p ON p.id=c.pet_id JOIN users u ON u.id=p.owner_id LEFT JOIN schedules s ON s.id=c.schedule_id WHERE c.doctor_id=? ORDER BY c.id DESC''',
        [doctorId]);
  }

  Future<List<Map<String, Object?>>> getConsultationsByPetId(int petId) async {
    return (await database).rawQuery(
        '''SELECT c.*, s.date schedule_date, s.time schedule_time, 
                  cr.diagnosis, cr.advice, p.notes as prescription,
                  comp.main_complaints
           FROM consultations c 
           LEFT JOIN schedules s ON s.id = c.schedule_id
           LEFT JOIN consultation_results cr ON cr.consultation_id = c.id
           LEFT JOIN prescriptions p ON p.consultation_id = c.id
           LEFT JOIN complaints comp ON comp.consultation_id = c.id
           WHERE c.pet_id=? AND c.status='finished' ORDER BY c.id DESC''',
        [petId]);
  }

  Future<int> updateConsultationStatus(int id, String status) async =>
      (await database).update('consultations', {'status': status},
          where: 'id=?', whereArgs: [id]);
  Future<List<Map<String, Object?>>> getMessages(int consultationId) async =>
      (await database).query('messages',
          where: 'consultation_id=?',
          whereArgs: [consultationId],
          orderBy: 'id');
  Future<int> addMessage(
          int consultationId, int senderId, String message) async =>
      (await database).insert('messages', {
        'consultation_id': consultationId,
        'sender_id': senderId,
        'message': message,
        'created_at': DateTime.now().toIso8601String()
      });

  Future<void> markMessagesAsRead(int consultationId, int userId) async {
    await (await database).update(
      'messages',
      {'is_read': 1},
      where: 'consultation_id = ? AND sender_id != ? AND is_read = 0',
      whereArgs: [consultationId, userId],
    );
  }

  Future<void> deleteMessage(int messageId) async {
    await (await database).delete('messages', where: 'id = ?', whereArgs: [messageId]);
  }

  Future<List<Map<String, Object?>>> getMedicalRecordsForOwner(
      int ownerId) async {
    return (await database).rawQuery(
        '''SELECT mr.*, p.name pet_name, u.name doctor_name FROM medical_records mr JOIN pets p ON p.id=mr.pet_id JOIN doctors d ON d.id=mr.doctor_id JOIN users u ON u.id=d.user_id WHERE p.owner_id=? ORDER BY mr.date DESC''',
        [ownerId]);
  }

  Future<int> addMedicalRecord(Map<String, Object?> data) async =>
      (await database).insert('medical_records', data);

  Future<Map<String, int>> getAdminStats() async {
    final db = await database;
    Future<int> count(String table) async =>
        _firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $table')) ??
        0;
    return {
      'users': await count('users'),
      'doctors': await count('doctors'),
      'pets': await count('pets'),
      'consultations': await count('consultations'),
      'medical_records': await count('medical_records')
    };
  }

  Future<Map<String, int>> getAdminDashboardSummary({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    String consultationQuery = "SELECT COUNT(*) FROM consultations WHERE date(created_at) = '$todayStr'";
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      consultationQuery = "SELECT COUNT(*) FROM consultations WHERE date(created_at) >= '$startStr' AND date(created_at) <= '$endStr'";
    }

    // Konsultasi hari ini (atau sesuai rentang tanggal)
    final consultationsToday = _firstIntValue(
      await db.rawQuery(consultationQuery)
    ) ?? 0;
    // Jumlah Pasien (berdasarkan pet_id unik di konsultasi pada periode ini)
    String petQuery = "SELECT COUNT(DISTINCT pet_id) FROM consultations";
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      petQuery += " WHERE date(created_at) >= '$startStr' AND date(created_at) <= '$endStr'";
    } else {
      petQuery += " WHERE date(created_at) = '$todayStr'";
    }
    final totalPets = _firstIntValue(
      await db.rawQuery(petQuery)
    ) ?? 0;

    // Jumlah Dokter (berdasarkan doctor_id unik di konsultasi pada periode ini)
    String doctorQuery = "SELECT COUNT(DISTINCT doctor_id) FROM consultations";
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      doctorQuery += " WHERE date(created_at) >= '$startStr' AND date(created_at) <= '$endStr'";
    } else {
      doctorQuery += " WHERE date(created_at) = '$todayStr'";
    }
    final totalDoctors = _firstIntValue(
      await db.rawQuery(doctorQuery)
    ) ?? 0;

    // Transaksi belum lunas (status menunggu)
    String unpaidQuery = "SELECT COUNT(*) FROM consultations WHERE status = 'menunggu' OR status = 'waiting' OR status = 'scheduled'";
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      unpaidQuery = "SELECT COUNT(*) FROM consultations WHERE (status = 'menunggu' OR status = 'waiting' OR status = 'scheduled') AND date(created_at) >= '$startStr' AND date(created_at) <= '$endStr'";
    } else {
      unpaidQuery = "SELECT COUNT(*) FROM consultations WHERE (status = 'menunggu' OR status = 'waiting' OR status = 'scheduled') AND date(created_at) = '$todayStr'";
    }
    final unpaidTransactions = _firstIntValue(
      await db.rawQuery(unpaidQuery)
    ) ?? 0;

    // Pendapatan dari konsultasi yang selesai
    String revenueQuery = "SELECT SUM(d.consultation_fee) FROM consultations c JOIN doctors d ON c.doctor_id = d.id WHERE (c.status = 'completed' OR c.status = 'selesai' OR c.status = 'finished')";
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      revenueQuery += " AND date(c.created_at) >= '$startStr' AND date(c.created_at) <= '$endStr'";
    } else {
      revenueQuery += " AND date(c.created_at) = '$todayStr'";
    }
    
    final revenueResult = await db.rawQuery(revenueQuery);
    final totalRevenue = (revenueResult.first.values.first as num?)?.toInt() ?? 0;

    String statusQuery = "SELECT status, COUNT(*) as count FROM consultations";
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      statusQuery += " WHERE date(created_at) >= '$startStr' AND date(created_at) <= '$endStr'";
    } else {
      statusQuery += " WHERE date(created_at) = '$todayStr'";
    }
    statusQuery += " GROUP BY status";
    final statusResult = await db.rawQuery(statusQuery);
    
    int statusFinished = 0;
    int statusCancelled = 0;
    int statusScheduled = 0;
    int statusMenunggu = 0;
    int statusBelumLunas = 0;
    int statusProgress = 0;
    
    for (var row in statusResult) {
      final status = (row['status'] as String?)?.toLowerCase();
      final count = (row['count'] as num?)?.toInt() ?? 0;
      if (status == 'finished' || status == 'completed' || status == 'selesai') {
        statusFinished += count;
      } else if (status == 'cancelled' || status == 'batal') {
        statusCancelled += count;
      } else if (status == 'scheduled' || status == 'dijadwalkan' || status == 'booked') {
        statusScheduled += count;
      } else if (status == 'waiting_payment') {
        statusBelumLunas += count;
      } else if (status == 'menunggu' || status == 'waiting') {
        statusMenunggu += count;
      } else {
        statusProgress += count;
      }
    }

    return {
      'konsultasi_hari_ini': consultationsToday,
      'jumlah_pasien': totalPets,
      'jumlah_dokter': totalDoctors,
      'transaksi_belum_lunas': unpaidTransactions,
      'total_pendapatan': totalRevenue,
      'status_finished': statusFinished,
      'status_cancelled': statusCancelled,
      'status_scheduled': statusScheduled,
      'status_menunggu': statusMenunggu,
      'status_belum_lunas': statusBelumLunas,
      'status_progress': statusProgress,
    };
  }

  Future<Map<String, dynamic>> getAdminReportStats() async {
    final db = await database;
    
    final totalConsultations = _firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM consultations")
    ) ?? 0;
    
    final totalPets = _firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM pets")
    ) ?? 0;
    
    // In a real app we'd sum up actual transaction amounts from an invoices or payments table
    // For now we'll mock the revenue as totalConsultations * 150000 (assumed average price)
    final revenue = totalConsultations * 150000;
    
    final totalTransactions = _firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM consultations WHERE status = 'selesai' OR status = 'completed'")
    ) ?? 0;
    
    return {
      'total_konsultasi': totalConsultations,
      'total_pasien': totalPets,
      'pendapatan': revenue,
      'transaksi': totalTransactions,
    };
  }

  Future<List<Map<String, dynamic>>> getAdminChartData({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    
    // Default to last 7 days if no dates provided
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 6));
    
    final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    
    final query = '''
      SELECT 
        date(c.created_at) as date,
        COUNT(c.id) as total_consultations,
        SUM(CASE WHEN c.status IN ('completed', 'selesai', 'finished') THEN d.consultation_fee ELSE 0 END) as total_revenue
      FROM consultations c
      JOIN doctors d ON c.doctor_id = d.id
      WHERE date(c.created_at) >= '$startStr' AND date(c.created_at) <= '$endStr'
      GROUP BY date(c.created_at)
      ORDER BY date(c.created_at) ASC
    ''';
    
    final result = await db.rawQuery(query);
    
    // Fill in missing dates with zero values
    final Map<String, Map<String, dynamic>> dataMap = {};
    for (var row in result) {
      dataMap[row['date'] as String] = row;
    }
    
    final List<Map<String, dynamic>> finalData = [];
    DateTime currentDate = start;
    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dateStr = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      if (dataMap.containsKey(dateStr)) {
        finalData.add(dataMap[dateStr]!);
      } else {
        finalData.add({
          'date': dateStr,
          'total_consultations': 0,
          'total_revenue': 0,
        });
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return finalData;
  }

  Future<List<Map<String, Object?>>> getAllUsers() async =>
      (await database).query('users',
          columns: ['id', 'name', 'email', 'phone', 'role', 'created_at'],
          orderBy: 'id DESC');

  Future<List<Map<String, Object?>>> getAdminPatients({DateTime? startDate, DateTime? endDate}) async {
    String query = '''SELECT p.*, u.name as owner_name 
         FROM pets p 
         JOIN users u ON u.id = p.owner_id''';
    
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      query += " WHERE EXISTS (SELECT 1 FROM consultations c WHERE c.pet_id = p.id AND date(c.created_at) >= '$startStr' AND date(c.created_at) <= '$endStr')";
    }
    query += " ORDER BY p.id DESC";
    
    return (await database).rawQuery(query);
  }

  Future<List<Map<String, Object?>>> getAdminDoctors({DateTime? startDate, DateTime? endDate}) async {
    String query = '''SELECT d.*, u.name as name, u.email as email, u.phone as phone
         FROM doctors d 
         JOIN users u ON u.id = d.user_id''';
         
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      query += " WHERE EXISTS (SELECT 1 FROM consultations c WHERE c.doctor_id = d.id AND date(c.created_at) >= '$startStr' AND date(c.created_at) <= '$endStr')";
    }
    query += " ORDER BY d.id DESC";

    return (await database).rawQuery(query);
  }

  Future<void> updateDoctorFee(int doctorId, double newFee) async {
    await (await database).update(
      'doctors',
      {'consultation_fee': newFee},
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  Future<void> updateDoctorVerification(int doctorId, int verified) async {
    await (await database).update(
      'doctors',
      {'verified': verified},
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  Future<List<Map<String, Object?>>> getAdminTransactions() async {
    return (await database).rawQuery(
      '''SELECT c.*, p.name as pet_name, u.name as owner_name, docu.name as doctor_name
         FROM consultations c
         JOIN pets p ON p.id = c.pet_id
         JOIN users u ON u.id = p.owner_id
         JOIN doctors d ON d.id = c.doctor_id
         JOIN users docu ON docu.id = d.user_id
         ORDER BY c.created_at DESC'''
    );
  }

  Future<List<Map<String, Object?>>> getAdminFilteredTransactions({DateTime? startDate, DateTime? endDate}) async {
    String query = '''SELECT c.*, p.name as pet_name, u.name as owner_name, docu.name as doctor_name
         FROM consultations c
         JOIN pets p ON p.id = c.pet_id
         JOIN users u ON u.id = p.owner_id
         JOIN doctors d ON d.id = c.doctor_id
         JOIN users docu ON docu.id = d.user_id
         WHERE (c.status = 'menunggu' OR c.status = 'waiting' OR c.status = 'scheduled')''';
         
    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      query += " AND date(c.created_at) >= '$startStr' AND date(c.created_at) <= '$endStr'";
    }
    query += " ORDER BY c.created_at DESC";
    
    return (await database).rawQuery(query);
  }

  Future<List<Map<String, Object?>>> getAllServices() async {
    return (await database).query('services', orderBy: 'id DESC');
  }

  Future<List<Map<String, Object?>>> getAllMedicines() async {
    return (await database).query('medicines', orderBy: 'id DESC');
  }

  Future<List<Map<String, Object?>>> getAdminNotifications() async {
    // Sebagai admin, kita ambil semua notifikasi atau buat sistem log
    return (await database).query('notifications', orderBy: 'created_at DESC');
  }
  Future<List<Map<String, Object?>>> getAllConsultations({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String query = '''SELECT c.*, p.name pet_name, owner.name owner_name, doctor.name doctor_name, d.consultation_fee FROM consultations c JOIN pets p ON p.id=c.pet_id JOIN users owner ON owner.id=p.owner_id JOIN doctors d ON d.id=c.doctor_id JOIN users doctor ON doctor.id=d.user_id''';

    if (startDate != null && endDate != null) {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      query += " WHERE date(c.created_at) >= '$startStr' AND date(c.created_at) <= '$endStr'";
    }
    query += " ORDER BY c.id DESC";

    return await db.rawQuery(query);
  }
  // v5 Methods
  Future<int> saveConsultationResult(
      int consultationId, Map<String, dynamic> data) async {
    final db = await database;
    final id = await db.insert('consultation_results', {
      'consultation_id': consultationId,
      'observation': data['observation'] ?? '',
      'diagnosis': data['diagnosis'] ?? '',
      'advice': data['advice'] ?? '',
      'forbidden': data['forbidden'] ?? '',
      'warning_signs': data['warning_signs'] ?? '',
      'follow_up': data['follow_up'] ?? '',
    });

    final consRows = await db.query('consultations', where: 'id = ?', whereArgs: [consultationId], limit: 1);
    if (consRows.isNotEmpty) {
      final cons = consRows.first;
      await db.insert('medical_records', {
        'pet_id': cons['pet_id'],
        'doctor_id': cons['doctor_id'],
        'consultation_id': consultationId,
        'diagnosis': data['diagnosis'] ?? '',
        'treatment': data['advice'] ?? '',
        'medicine': '',
        'notes': data['observation'] ?? '',
        'date': cons['date'] ?? DateTime.now().toIso8601String(),
        'temperature': data['temperature'] ?? 0.0,
        'heart_rate': data['heart_rate'] ?? 0,
        'respiratory_rate': data['respiratory_rate'] ?? 0,
        'weight_at_visit': data['weight_at_visit'] ?? 0.0,
      });
    }

    return id;
  }

  Future<Map<String, Object?>?> getConsultationResult(
      int consultationId) async {
    final rows = await (await database).query('consultation_results',
        where: 'consultation_id = ?', whereArgs: [consultationId], limit: 1);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<int> savePrescription(int consultationId, String notes,
      List<Map<String, dynamic>> items) async {
    final db = await database;
    final pid = await db.insert('prescriptions', {
      'consultation_id': consultationId,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
    for (var item in items) {
      await db.insert('prescription_items', {
        'prescription_id': pid,
        'medicine_name': item['medicine_name'] ?? '',
        'form': item['form'] ?? '',
        'dose': item['dose'] ?? '',
        'frequency': item['frequency'] ?? '',
        'duration': item['duration'] ?? '',
        'method': item['method'] ?? '',
        'qty': item['qty'] ?? '',
      });
    }
    
    final medicineStr = items.map((i) => "${i['medicine_name']} (${i['dose']} - ${i['qty']})").join(', ');
    await db.update('medical_records', {'medicine': medicineStr}, where: 'consultation_id = ?', whereArgs: [consultationId]);
    
    return pid;
  }

  Future<Map<String, dynamic>?> getPrescription(int consultationId) async {
    final db = await database;
    final pRows = await db.query('prescriptions',
        where: 'consultation_id = ?', whereArgs: [consultationId], limit: 1);
    if (pRows.isEmpty) return null;
    final p = pRows.first;
    final iRows = await db.query('prescription_items',
        where: 'prescription_id = ?', whereArgs: [p['id']]);
    return {...p, 'items': iRows};
  }

  Future<List<Map<String, dynamic>>> getPrescriptionsByOwnerId(int ownerId) async {
    final db = await database;
    final query = '''
      SELECT 
        p.id as prescription_id,
        p.notes,
        p.created_at as prescription_date,
        c.id as consultation_id,
        c.complaint,
        u.name as doctor_name,
        pet.name as pet_name
      FROM prescriptions p
      JOIN consultations c ON p.consultation_id = c.id
      JOIN users u ON c.doctor_id = u.id
      JOIN pets pet ON c.pet_id = pet.id
      WHERE pet.owner_id = ?
      ORDER BY p.created_at DESC
    ''';
    
    final pRows = await db.rawQuery(query, [ownerId]);
    
    List<Map<String, dynamic>> results = [];
    for (var pRow in pRows) {
      final items = await db.query('prescription_items', 
        where: 'prescription_id = ?', 
        whereArgs: [pRow['prescription_id']]
      );
      
      results.add({
        ...pRow,
        'items': items,
      });
    }
    
    return results;
  }


  Future<int> createMedicineOrder(int consultationId, String address,
      double medPrice, double delFee) async {
    return (await database).insert('medicine_orders', {
      'consultation_id': consultationId,
      'delivery_address': address,
      'medicine_price': medPrice,
      'delivery_fee': delFee,
      'total_price': medPrice + delFee,
      'status': 'waiting_payment',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateMedicineOrderStatus(int orderId, String status) async {
    await (await database).update('medicine_orders', {'status': status},
        where: 'id = ?', whereArgs: [orderId]);
  }

  Future<Map<String, Object?>?> getMedicineOrder(int consultationId) async {
    final rows = await (await database).query('medicine_orders',
        where: 'consultation_id = ?', whereArgs: [consultationId], limit: 1);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<int> addMonitoringLog(
      int consultationId, Map<String, dynamic> data) async {
    return (await database).insert('monitoring_logs', {
      'consultation_id': consultationId,
      'date': DateTime.now().toIso8601String(),
      'appetite': data['appetite'] ?? '',
      'activity': data['activity'] ?? '',
      'condition': data['condition'] ?? '',
      'symptoms': data['symptoms'] ?? '',
      'medicine_effects': data['medicine_effects'] ?? '',
      'photo': data['photo'] ?? '',
    });
  }

  Future<List<Map<String, Object?>>> getMonitoringLogs(
      int consultationId) async {
    return (await database).query('monitoring_logs',
        where: 'consultation_id = ?',
        whereArgs: [consultationId],
        orderBy: 'id DESC');
  }

  // ==== Phase 17: Ratings & Reviews ====

  Future<int> submitReview(
      int consultationId, Map<String, dynamic> data) async {
    return (await database).insert('reviews', {
      'consultation_id': consultationId,
      'rating_doctor': data['rating_doctor'] ?? 0.0,
      'rating_info': data['rating_info'] ?? 0.0,
      'rating_app': data['rating_app'] ?? 0.0,
      'rating_quality': data['rating_quality'] ?? 0.0,
      'review_text': data['review_text'] ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, Object?>?> getReview(int consultationId) async {
    final rows = await (await database).query('reviews',
        where: 'consultation_id = ?', whereArgs: [consultationId]);
    return rows.isNotEmpty ? rows.first : null;
  }

  // ==== Phase 18: Help Center ====

  Future<int> submitHelpTicket(
      int userId, String category, String description) async {
    return (await database).insert('help_tickets', {
      'user_id': userId,
      'category': category,
      'description': description,
      'status': 'open',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> getHelpTickets(int userId) async {
    return (await database).query('help_tickets',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'id DESC');
  }

  Future<List<Map<String, Object?>>> getAllHelpTickets() async {
    final db = await database;
    return db.rawQuery('''
      SELECT t.*, u.name as user_name 
      FROM help_tickets t 
      JOIN users u ON t.user_id = u.id 
      ORDER BY t.id DESC
    ''');
  }

  Future<void> replyHelpTicket(int ticketId, String reply) async {
    await (await database).update(
        'help_tickets',
        {
          'admin_reply': reply,
          'status': 'closed',
        },
        where: 'id = ?',
        whereArgs: [ticketId]);
  }

  Future<void> updateUserProfile(int id, String name, String phone, String photo) async {
    final db = await database;
    await db.update(
        'users',
        {
          'name': name,
          'phone': phone,
          'photo': photo,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }
}
