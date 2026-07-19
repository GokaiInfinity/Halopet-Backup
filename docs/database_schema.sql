-- Database SQLite HaloPet / VetCare
-- Dibuat sesuai rancangan SRS: users, doctors, pets, doctor_schedules, consultations,
-- consultation_messages, medical_records, products, carts, orders, order_details,
-- payments, reviews, notifications.

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
);

CREATE TABLE doctors (
  id_doctor INTEGER PRIMARY KEY AUTOINCREMENT,
  id_user INTEGER NOT NULL,
  license_number TEXT,
  specialization TEXT,
  experience TEXT,
  consultation_fee REAL DEFAULT 0,
  rating REAL DEFAULT 0,
  verification_status TEXT DEFAULT 'menunggu'
);

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
);

CREATE TABLE doctor_schedules (
  id_schedule INTEGER PRIMARY KEY AUTOINCREMENT,
  id_doctor INTEGER NOT NULL,
  day TEXT NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  status TEXT NOT NULL
);

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
);

CREATE TABLE consultation_messages (
  id_message INTEGER PRIMARY KEY AUTOINCREMENT,
  id_consultation INTEGER NOT NULL,
  sender_id INTEGER NOT NULL,
  message TEXT NOT NULL,
  attachment TEXT,
  sent_at TEXT NOT NULL
);

CREATE TABLE medical_records (
  id_record INTEGER PRIMARY KEY AUTOINCREMENT,
  id_consultation INTEGER NOT NULL,
  id_pet INTEGER NOT NULL,
  doctor_note TEXT,
  condition_summary TEXT,
  recommendation TEXT,
  medicine_suggestion TEXT,
  record_date TEXT NOT NULL
);

CREATE TABLE products (
  id_product INTEGER PRIMARY KEY AUTOINCREMENT,
  product_name TEXT NOT NULL,
  category TEXT,
  description TEXT,
  price REAL DEFAULT 0,
  stock INTEGER DEFAULT 0,
  product_image TEXT,
  status TEXT NOT NULL
);

CREATE TABLE carts (
  id_cart INTEGER PRIMARY KEY AUTOINCREMENT,
  id_user INTEGER NOT NULL,
  id_product INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE orders (
  id_order INTEGER PRIMARY KEY AUTOINCREMENT,
  id_user INTEGER NOT NULL,
  order_date TEXT NOT NULL,
  total_price REAL DEFAULT 0,
  shipping_address TEXT,
  order_status TEXT NOT NULL
);

CREATE TABLE order_details (
  id_order_detail INTEGER PRIMARY KEY AUTOINCREMENT,
  id_order INTEGER NOT NULL,
  id_product INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  price REAL DEFAULT 0,
  subtotal REAL DEFAULT 0
);

CREATE TABLE payments (
  id_payment INTEGER PRIMARY KEY AUTOINCREMENT,
  id_user INTEGER NOT NULL,
  payment_type TEXT NOT NULL,
  reference_id INTEGER NOT NULL,
  payment_method TEXT,
  total_payment REAL DEFAULT 0,
  payment_status TEXT NOT NULL,
  payment_date TEXT NOT NULL
);

CREATE TABLE reviews (
  id_review INTEGER PRIMARY KEY AUTOINCREMENT,
  id_user INTEGER NOT NULL,
  id_doctor INTEGER NOT NULL,
  id_consultation INTEGER NOT NULL,
  rating INTEGER NOT NULL,
  comment TEXT,
  review_date TEXT NOT NULL
);

CREATE TABLE notifications (
  id_notification INTEGER PRIMARY KEY AUTOINCREMENT,
  id_user INTEGER NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
);
