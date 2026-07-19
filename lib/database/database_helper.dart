import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async => _database ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'halopet.db');
    return openDatabase(path,
        version: 6,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async => _seed(db));
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, phone TEXT DEFAULT '', role TEXT NOT NULL, created_at TEXT NOT NULL)''');
    await db.execute(
        '''CREATE TABLE doctors(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL UNIQUE, specialist TEXT NOT NULL, license TEXT NOT NULL, rating REAL DEFAULT 0, experience INTEGER DEFAULT 0, bio TEXT DEFAULT '', consultation_fee REAL DEFAULT 50000, verified INTEGER DEFAULT 1, FOREIGN KEY(user_id) REFERENCES users(id))''');
    await db.execute(
        '''CREATE TABLE pets(id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id INTEGER NOT NULL, name TEXT NOT NULL, species TEXT NOT NULL, breed TEXT DEFAULT '', gender TEXT DEFAULT '', age INTEGER DEFAULT 0, weight REAL DEFAULT 0, photo TEXT DEFAULT '', tanggal_lahir TEXT DEFAULT '', warna_ciri TEXT DEFAULT '', status_steril TEXT DEFAULT 'Belum Steril', alergi TEXT DEFAULT '', FOREIGN KEY(owner_id) REFERENCES users(id))''');
    await db.execute(
        '''CREATE TABLE vaccinations(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, name TEXT NOT NULL, date TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Aktif', next_date TEXT DEFAULT '', FOREIGN KEY(pet_id) REFERENCES pets(id))''');
    await db.execute(
        '''CREATE TABLE diseases(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, name TEXT NOT NULL, date TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Sembuh', FOREIGN KEY(pet_id) REFERENCES pets(id))''');
    await db.execute(
        '''CREATE TABLE schedules(id INTEGER PRIMARY KEY AUTOINCREMENT, doctor_id INTEGER NOT NULL, date TEXT NOT NULL, time TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'available', FOREIGN KEY(doctor_id) REFERENCES doctors(id))''');
    await db.execute(
        '''CREATE TABLE consultations(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, doctor_id INTEGER NOT NULL, schedule_id INTEGER, complaint TEXT NOT NULL, method TEXT DEFAULT 'Chat', status TEXT NOT NULL DEFAULT 'waiting', is_control INTEGER DEFAULT 0, parent_consultation_id INTEGER, created_at TEXT NOT NULL, FOREIGN KEY(pet_id) REFERENCES pets(id), FOREIGN KEY(doctor_id) REFERENCES doctors(id))''');
    await db.execute(
        '''CREATE TABLE complaints(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, service_type TEXT DEFAULT '', main_complaints TEXT DEFAULT '', duration TEXT DEFAULT '', appetite TEXT DEFAULT '', activity TEXT DEFAULT '', urine TEXT DEFAULT '', feces TEXT DEFAULT '', vomit INTEGER DEFAULT 0, respiratory TEXT DEFAULT '', skin_coat TEXT DEFAULT '', medication TEXT DEFAULT '', photos_videos TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE screenings(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, difficulty_breathing INTEGER DEFAULT 0, seizures INTEGER DEFAULT 0, unconscious INTEGER DEFAULT 0, heavy_bleeding INTEGER DEFAULT 0, severe_trauma INTEGER DEFAULT 0, cannot_stand INTEGER DEFAULT 0, poisoning INTEGER DEFAULT 0, cannot_urinate INTEGER DEFAULT 0, continuous_vomiting INTEGER DEFAULT 0, result_category TEXT DEFAULT 'Ringan', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, sender_id INTEGER NOT NULL, message TEXT NOT NULL, created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE medical_records(id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER NOT NULL, doctor_id INTEGER NOT NULL, consultation_id INTEGER, diagnosis TEXT NOT NULL, treatment TEXT DEFAULT '', medicine TEXT DEFAULT '', notes TEXT DEFAULT '', date TEXT NOT NULL, FOREIGN KEY(pet_id) REFERENCES pets(id), FOREIGN KEY(doctor_id) REFERENCES doctors(id))''');
    await db.execute(
        '''CREATE TABLE notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT NOT NULL, message TEXT NOT NULL, is_read INTEGER DEFAULT 0, created_at TEXT NOT NULL)''');
    await db.execute(
        '''CREATE TABLE consultation_results(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, observation TEXT DEFAULT '', diagnosis TEXT DEFAULT '', advice TEXT DEFAULT '', forbidden TEXT DEFAULT '', warning_signs TEXT DEFAULT '', follow_up TEXT DEFAULT '', control_decision TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE prescriptions(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, notes TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE prescription_items(id INTEGER PRIMARY KEY AUTOINCREMENT, prescription_id INTEGER NOT NULL, medicine_name TEXT NOT NULL, form TEXT DEFAULT '', dose TEXT DEFAULT '', frequency TEXT DEFAULT '', duration TEXT DEFAULT '', method TEXT DEFAULT '', qty TEXT DEFAULT '', FOREIGN KEY(prescription_id) REFERENCES prescriptions(id))''');
    await db.execute(
        '''CREATE TABLE medicine_orders(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, delivery_address TEXT NOT NULL, medicine_price REAL DEFAULT 0, delivery_fee REAL DEFAULT 0, total_price REAL DEFAULT 0, status TEXT NOT NULL DEFAULT 'waiting_payment', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE monitoring_logs(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL, date TEXT NOT NULL, appetite TEXT DEFAULT '', activity TEXT DEFAULT '', condition TEXT DEFAULT '', symptoms TEXT DEFAULT '', medicine_effects TEXT DEFAULT '', photo TEXT DEFAULT '', FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE reviews(id INTEGER PRIMARY KEY AUTOINCREMENT, consultation_id INTEGER NOT NULL UNIQUE, rating_doctor REAL DEFAULT 0, rating_info REAL DEFAULT 0, rating_app REAL DEFAULT 0, rating_quality REAL DEFAULT 0, review_text TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(consultation_id) REFERENCES consultations(id))''');
    await db.execute(
        '''CREATE TABLE help_tickets(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, category TEXT NOT NULL, description TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open', admin_reply TEXT DEFAULT '', created_at TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id))''');

    await _seed(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
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
  }

  String hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> _seed(Database db) async {
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users')) ??
        0;
    if (count > 0) return;
    final now = DateTime.now().toIso8601String();
    final ownerId = await db.insert('users', {
      'name': 'Adel Pemilik',
      'email': 'owner@halopet.com',
      'password_hash': hashPassword('123456'),
      'phone': '081234567890',
      'role': 'owner',
      'created_at': now
    });
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
        List.generate(5, (i) => DateTime.now().add(Duration(days: i + 1)));
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

  Future<List<Map<String, Object?>>> getDiseases(int petId) async =>
      (await database).query('diseases',
          where: 'pet_id = ?', whereArgs: [petId], orderBy: 'id DESC');
  Future<int> addDisease(Map<String, Object?> data) async =>
      (await database).insert('diseases', data);
  Future<int> deleteDisease(int id) async =>
      (await database).delete('diseases', where: 'id = ?', whereArgs: [id]);

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

  Future<List<Map<String, Object?>>> getDoctorConsultations(
      int doctorId) async {
    return (await database).rawQuery(
        '''SELECT c.*, p.name pet_name, p.species, p.breed, u.name owner_name, s.date schedule_date, s.time schedule_time FROM consultations c JOIN pets p ON p.id=c.pet_id JOIN users u ON u.id=p.owner_id LEFT JOIN schedules s ON s.id=c.schedule_id WHERE c.doctor_id=? ORDER BY c.id DESC''',
        [doctorId]);
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
        Sqflite.firstIntValue(
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

  Future<List<Map<String, Object?>>> getAllUsers() async =>
      (await database).query('users',
          columns: ['id', 'name', 'email', 'phone', 'role', 'created_at'],
          orderBy: 'id DESC');
  Future<
      List<
          Map<String,
              Object?>>> getAllConsultations() async => (await database).rawQuery(
      '''SELECT c.*, p.name pet_name, owner.name owner_name, doctor.name doctor_name FROM consultations c JOIN pets p ON p.id=c.pet_id JOIN users owner ON owner.id=p.owner_id JOIN doctors d ON d.id=c.doctor_id JOIN users doctor ON doctor.id=d.user_id ORDER BY c.id DESC''');

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
}
