import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:halopet_vetcare/screens/admin/admin_doctors_screen.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/widgets/ui_components.dart';
import 'package:halopet_vetcare/screens/admin/admin_products_screen.dart';
import 'package:halopet_vetcare/screens/owner/products_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_dashboard.dart';
import 'package:halopet_vetcare/screens/home/home_router.dart';
import 'package:halopet_vetcare/screens/owner/doctor_list_screen.dart';
import 'package:halopet_vetcare/screens/owner/owner_profile_tab.dart';
import 'package:halopet_vetcare/screens/owner/owner_dashboard.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_profile_tab.dart';
import 'package:halopet_vetcare/screens/owner/notifications_screen.dart';
import 'package:halopet_vetcare/screens/owner/pets_screen.dart';
import 'package:halopet_vetcare/screens/owner/cart_screen.dart';
import 'package:halopet_vetcare/core/database.dart';
import 'package:halopet_vetcare/screens/owner/create_consultation_screen.dart';
import 'package:halopet_vetcare/screens/auth/login_screen.dart';
import 'package:halopet_vetcare/screens/auth/register_screen.dart';
import 'package:halopet_vetcare/screens/admin/reports_screen.dart';
import 'package:halopet_vetcare/screens/owner/medical_records_screen.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_schedule_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_profile_tab.dart';
import 'package:halopet_vetcare/core/helpers.dart';
import 'package:halopet_vetcare/screens/owner/orders_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_users_screen.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_dashboard.dart';
import 'package:halopet_vetcare/screens/owner/chat_screen.dart';

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
      where: '(LOWER(email) = ? OR phone = ?) AND password = ? AND status = ?',
      whereArgs: [email.trim().toLowerCase(), email.trim(), password, 'aktif'],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'LOWER(email) = ?', whereArgs: [email.trim().toLowerCase()], limit: 1);
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
      'email': email.trim().toLowerCase(),
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
      
      final adminRows = await db.query('users', where: 'role = ?', whereArgs: ['admin'], limit: 1);
      if (adminRows.isNotEmpty) {
        await db.insert('notifications', {
          'id_user': adminRows.first['id_user'],
          'title': 'Verifikasi Dokter Baru',
          'message': 'Dokter $name baru saja mendaftar dan menunggu verifikasi Anda.',
          'is_read': 0,
          'created_at': nowIso(),
        });
      }
    }
    return userId;
  }
}
