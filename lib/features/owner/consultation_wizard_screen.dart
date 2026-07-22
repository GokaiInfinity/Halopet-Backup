import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../app/routes.dart';

enum QuestionType { text, radio, checkbox, yesNo }

class ConsultationQuestion {
  final String key;
  final String question;
  final QuestionType type;
  final List<String> options;

  ConsultationQuestion({
    required this.key,
    required this.question,
    required this.type,
    this.options = const [],
  });
}

final Map<String, Map<String, List<ConsultationQuestion>>> serviceConfig = {
  'Keluhan Kesehatan Umum': {
    'Wajib': [
      ConsultationQuestion(key: 'keluhan_utama', question: 'Keluhan utama apa yang sedang dialami?', type: QuestionType.text),
      ConsultationQuestion(key: 'sejak_kapan', question: 'Sejak kapan keluhan muncul?', type: QuestionType.radio, options: ['Kurang dari 24 jam', '1 - 3 hari', 'Lebih dari 3 hari']),
      ConsultationQuestion(key: 'muncul_tiba_tiba', question: 'Apakah keluhan muncul tiba-tiba atau bertahap?', type: QuestionType.radio, options: ['Tiba-tiba', 'Bertahap']),
      ConsultationQuestion(key: 'masih_makan', question: 'Apakah hewan masih mau makan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'masih_minum', question: 'Apakah hewan masih mau minum?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'terlihat_lemas', question: 'Apakah hewan terlihat lemas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'mengalami_muntah', question: 'Apakah hewan mengalami muntah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'mengalami_diare', question: 'Apakah hewan mengalami diare?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'batuk_bersin_sesak', question: 'Apakah ada batuk, bersin, atau sesak napas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'suhu_panas', question: 'Apakah suhu tubuh hewan terasa panas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'masih_aktif', question: 'Apakah hewan masih aktif seperti biasa?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'perubahan_perilaku', question: 'Apakah ada perubahan perilaku?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_keluhan_sama', question: 'Apakah sebelumnya pernah mengalami keluhan yang sama?', type: QuestionType.yesNo),
    ],
    'Tambahan': [
      ConsultationQuestion(key: 'pernah_diberi_obat', question: 'Apakah hewan pernah diberi obat sebelumnya?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'obat_apa', question: 'Obat apa yang sudah diberikan?', type: QuestionType.text),
      ConsultationQuestion(key: 'hewan_lain_sakit', question: 'Apakah ada hewan lain di rumah yang sakit?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'baru_bepergian', question: 'Apakah hewan baru saja bepergian atau keluar rumah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'perubahan_makanan', question: 'Apakah ada perubahan makanan dalam beberapa hari terakhir?', type: QuestionType.yesNo),
    ],
    'Darurat': [
      ConsultationQuestion(key: 'sulit_bernapas', question: 'Apakah hewan sulit bernapas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kejang', question: 'Apakah hewan kejang?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tidak_sadar', question: 'Apakah hewan tidak sadar atau sangat lemas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'muntah_diare_berdarah', question: 'Apakah ada muntah/diare berdarah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tidak_bisa_berdiri', question: 'Apakah hewan tidak bisa berdiri?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tidak_buang_air_kecil', question: 'Apakah hewan tidak buang air kecil lebih dari 24 jam?', type: QuestionType.yesNo),
    ]
  },
  'Kulit dan Bulu': {
    'Wajib': [
      ConsultationQuestion(key: 'keluhan_kulit', question: 'Keluhan kulit/bulu apa yang dialami?', type: QuestionType.text),
      ConsultationQuestion(key: 'sejak_kapan', question: 'Sejak kapan keluhan muncul?', type: QuestionType.radio, options: ['Kurang dari 24 jam', '1 - 3 hari', 'Lebih dari 3 hari']),
      ConsultationQuestion(key: 'bagian_tubuh', question: 'Bagian tubuh mana yang bermasalah?', type: QuestionType.text),
      ConsultationQuestion(key: 'sering_menggaruk', question: 'Apakah hewan sering menggaruk?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'sering_menjilat', question: 'Apakah hewan sering menjilat bagian tertentu?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'bulu_rontok', question: 'Apakah ada bulu rontok?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'luka_koreng_kemerahan', question: 'Apakah ada luka, koreng, kemerahan, atau benjolan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'bau_tidak_sedap', question: 'Apakah ada bau tidak sedap dari kulit?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'ketombe_mengelupas', question: 'Apakah ada ketombe atau kulit mengelupas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kutu_parasit', question: 'Apakah ada kutu, tungau, atau parasit yang terlihat?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'menyebar', question: 'Apakah keluhan menyebar ke bagian tubuh lain?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tampak_kesakitan', question: 'Apakah hewan tampak kesakitan saat area tersebut disentuh?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'nafsu_makan_normal', question: 'Apakah nafsu makan tetap normal?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_masalah_sebelumnya', question: 'Apakah hewan pernah mengalami masalah kulit sebelumnya?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_diberi_salep', question: 'Apakah sudah pernah diberi salep, obat, atau sampo khusus?', type: QuestionType.yesNo),
    ],
    'Tambahan': [
      ConsultationQuestion(key: 'terakhir_dimandikan', question: 'Kapan terakhir hewan dimandikan?', type: QuestionType.text),
      ConsultationQuestion(key: 'sampo_digunakan', question: 'Sampo apa yang digunakan?', type: QuestionType.text),
      ConsultationQuestion(key: 'ganti_makanan', question: 'Apakah baru mengganti makanan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'ganti_grooming', question: 'Apakah baru mengganti produk grooming?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'hewan_lain_gatal', question: 'Apakah ada hewan lain di rumah yang mengalami gatal?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pemilik_gatal', question: 'Apakah pemilik atau anggota rumah juga mengalami gatal?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'bermain_di_luar', question: 'Apakah hewan sering bermain di luar rumah?', type: QuestionType.yesNo),
    ],
    'Darurat': []
  },
  'Pencernaan': {
    'Wajib': [
      ConsultationQuestion(key: 'keluhan_pencernaan', question: 'Keluhan utama pencernaan apa yang dialami?', type: QuestionType.text),
      ConsultationQuestion(key: 'sejak_kapan', question: 'Sejak kapan keluhan muncul?', type: QuestionType.radio, options: ['Kurang dari 24 jam', '1 - 3 hari', 'Lebih dari 3 hari']),
      ConsultationQuestion(key: 'muntah', question: 'Apakah hewan muntah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kali_muntah', question: 'Berapa kali muntah dalam 24 jam terakhir?', type: QuestionType.text),
      ConsultationQuestion(key: 'warna_muntah', question: 'Warna muntah seperti apa?', type: QuestionType.text),
      ConsultationQuestion(key: 'isi_muntah', question: 'Apakah muntah berisi makanan, cairan, busa, atau darah?', type: QuestionType.text),
      ConsultationQuestion(key: 'diare', question: 'Apakah hewan mengalami diare?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kali_diare', question: 'Berapa kali diare dalam 24 jam terakhir?', type: QuestionType.text),
      ConsultationQuestion(key: 'bentuk_feses', question: 'Bagaimana bentuk fesesnya?', type: QuestionType.text),
      ConsultationQuestion(key: 'darah_lendir_feses', question: 'Apakah ada darah atau lendir pada feses?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'masih_makan', question: 'Apakah hewan masih mau makan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'masih_minum', question: 'Apakah hewan masih mau minum?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tampak_lemas', question: 'Apakah hewan tampak lemas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'perut_kembung_sakit', question: 'Apakah perut terlihat kembung atau sakit saat disentuh?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'buang_air_kecil_normal', question: 'Apakah hewan masih buang air kecil normal?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'makan_benda_asing', question: 'Apakah hewan sempat makan benda asing?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'baru_ganti_makanan', question: 'Apakah hewan baru mengganti makanan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'obat_cacing', question: 'Apakah hewan sudah diberi obat cacing?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'terakhir_obat_cacing', question: 'Kapan terakhir obat cacing diberikan?', type: QuestionType.text),
      ConsultationQuestion(key: 'pernah_terjadi_sebelumnya', question: 'Apakah keluhan pernah terjadi sebelumnya?', type: QuestionType.yesNo),
    ],
    'Tambahan': [
      ConsultationQuestion(key: 'makanan_24_jam', question: 'Makanan apa yang dimakan dalam 24 jam terakhir?', type: QuestionType.text),
      ConsultationQuestion(key: 'makan_makanan_manusia', question: 'Apakah hewan makan makanan manusia?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'makan_benda_asing_lain', question: 'Apakah hewan makan tulang, plastik, kain, tanaman, atau benda asing?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kemungkinan_keracunan', question: 'Apakah ada kemungkinan keracunan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'hewan_lain_sama', question: 'Apakah ada hewan lain di rumah yang mengalami keluhan sama?', type: QuestionType.yesNo),
    ],
    'Darurat': [
      ConsultationQuestion(key: 'muntah_terus_menerus', question: 'Apakah muntah terus-menerus?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'diare_berdarah', question: 'Apakah diare berdarah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tidak_makan_24_jam', question: 'Apakah hewan tidak mau makan sama sekali lebih dari 24 jam?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'sangat_lemas', question: 'Apakah hewan sangat lemas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'perut_membesar_kembung', question: 'Apakah perut membesar/kembung?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kesakitan_hebat', question: 'Apakah hewan tampak kesakitan hebat?', type: QuestionType.yesNo),
    ]
  },
  'Nutrisi': {
    'Wajib': [
      ConsultationQuestion(key: 'jenis_hewan', question: 'Jenis hewan apa?', type: QuestionType.text),
      ConsultationQuestion(key: 'usia_hewan', question: 'Usia hewan berapa?', type: QuestionType.text),
      ConsultationQuestion(key: 'berat_badan', question: 'Berat badan hewan saat ini?', type: QuestionType.text),
      ConsultationQuestion(key: 'tren_berat_badan', question: 'Apakah berat badan naik, turun, atau stabil?', type: QuestionType.radio, options: ['Naik', 'Turun', 'Stabil']),
      ConsultationQuestion(key: 'makanan_utama', question: 'Makanan utama yang diberikan saat ini apa?', type: QuestionType.text),
      ConsultationQuestion(key: 'merek_makanan', question: 'Merek makanan yang digunakan?', type: QuestionType.text),
      ConsultationQuestion(key: 'frekuensi_makan', question: 'Berapa kali makan dalam sehari?', type: QuestionType.text),
      ConsultationQuestion(key: 'porsi_makan', question: 'Berapa porsi makan setiap kali makan?', type: QuestionType.text),
      ConsultationQuestion(key: 'diberi_snack', question: 'Apakah hewan diberi snack/treat?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'makanan_manusia', question: 'Apakah hewan sering diberi makanan manusia?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'alergi_makanan', question: 'Apakah ada alergi makanan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'muntah_diare_setelah_makan', question: 'Apakah ada muntah atau diare setelah makan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'bulu_kusam_rontok', question: 'Apakah bulu tampak kusam atau rontok?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kondisi_tubuh', question: 'Apakah hewan terlalu kurus atau terlalu gemuk?', type: QuestionType.radio, options: ['Terlalu kurus', 'Terlalu gemuk', 'Normal']),
      ConsultationQuestion(key: 'penyakit_tertentu', question: 'Apakah hewan memiliki penyakit tertentu?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'hamil_menyusui', question: 'Apakah hewan sedang hamil atau menyusui?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'aktif_bergerak', question: 'Apakah hewan aktif bergerak?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tujuan_konsultasi', question: 'Apa tujuan konsultasi nutrisi? (Contoh: menaikkan berat badan, dll)', type: QuestionType.text),
    ],
    'Tambahan': [
      ConsultationQuestion(key: 'pilih_pilih_makanan', question: 'Apakah hewan pilih-pilih makanan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'sering_meminta_makan', question: 'Apakah hewan sering meminta makan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_diet_khusus', question: 'Apakah pernah mencoba makanan diet khusus?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'rekomendasi_dokter_sebelumnya', question: 'Apakah ada rekomendasi makanan dari dokter sebelumnya?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'preferensi_makanan', question: 'Apakah pemilik ingin makanan kering, basah, homemade, atau kombinasi?', type: QuestionType.text),
      ConsultationQuestion(key: 'batasan_budget', question: 'Apakah ada batasan budget makanan?', type: QuestionType.yesNo),
    ],
    'Darurat': []
  },
  'Perilaku': {
    'Wajib': [
      ConsultationQuestion(key: 'keluhan_perilaku', question: 'Perilaku apa yang menjadi keluhan utama?', type: QuestionType.text),
      ConsultationQuestion(key: 'sejak_kapan', question: 'Sejak kapan perilaku tersebut muncul?', type: QuestionType.text),
      ConsultationQuestion(key: 'tiba_tiba_atau_lama', question: 'Apakah perilaku muncul tiba-tiba atau sudah lama?', type: QuestionType.radio, options: ['Tiba-tiba', 'Sudah lama']),
      ConsultationQuestion(key: 'perubahan_lingkungan', question: 'Apakah ada perubahan lingkungan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pindah_rumah', question: 'Apakah baru pindah rumah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'anggota_keluarga_baru', question: 'Apakah ada anggota keluarga baru?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'hewan_baru', question: 'Apakah ada hewan baru di rumah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_trauma', question: 'Apakah hewan pernah mengalami trauma?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'jatuh_terluka', question: 'Apakah hewan pernah jatuh, tertabrak, atau terluka?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tampak_kesakitan', question: 'Apakah hewan tampak kesakitan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'menjadi_agresif', question: 'Apakah hewan menjadi agresif?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_menggigit', question: 'Apakah hewan pernah menggigit atau mencakar?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'target_agresif', question: 'Apakah agresif terjadi kepada manusia atau hewan lain?', type: QuestionType.radio, options: ['Manusia', 'Hewan lain', 'Keduanya']),
      ConsultationQuestion(key: 'sering_bersembunyi', question: 'Apakah hewan sering bersembunyi?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'vokal_berlebihan', question: 'Apakah hewan sering mengeong/menggonggong berlebihan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'buang_air_sembarangan', question: 'Apakah hewan buang air sembarangan?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pola_makan_berubah', question: 'Apakah pola makan berubah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pola_tidur_berubah', question: 'Apakah pola tidur berubah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'sudah_disteril', question: 'Apakah hewan sudah disteril?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'rutin_bermain', question: 'Apakah hewan rutin diajak bermain atau beraktivitas?', type: QuestionType.yesNo),
    ],
    'Tambahan': [
      ConsultationQuestion(key: 'pemicu_perilaku', question: 'Situasi apa yang memicu perilaku tersebut?', type: QuestionType.text),
      ConsultationQuestion(key: 'saat_ditinggal', question: 'Apakah perilaku muncul saat ditinggal sendiri?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'bertemu_orang_asing', question: 'Apakah perilaku muncul saat bertemu orang asing?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'takut_suara', question: 'Apakah hewan takut suara tertentu? (Sebutkan jika ada)', type: QuestionType.text),
      ConsultationQuestion(key: 'punya_mainan_area', question: 'Apakah hewan memiliki mainan atau area khusus?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pelatihan_tertentu', question: 'Apakah pemilik pernah mencoba pelatihan tertentu?', type: QuestionType.yesNo),
    ],
    'Darurat': []
  },
  'Vaksinasi': {
    'Wajib': [
      ConsultationQuestion(key: 'jenis_hewan', question: 'Jenis hewan apa?', type: QuestionType.text),
      ConsultationQuestion(key: 'usia_hewan', question: 'Usia hewan berapa?', type: QuestionType.text),
      ConsultationQuestion(key: 'berat_badan', question: 'Berat badan hewan berapa?', type: QuestionType.text),
      ConsultationQuestion(key: 'kondisi_sehat', question: 'Apakah hewan dalam kondisi sehat?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'gejala_sakit', question: 'Apakah ada demam, muntah, diare, batuk, atau lemas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'pernah_divaksin', question: 'Apakah hewan sudah pernah divaksin?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'jenis_vaksin_sebelumnya', question: 'Vaksin apa saja yang sudah pernah diberikan?', type: QuestionType.text),
      ConsultationQuestion(key: 'tanggal_vaksin_terakhir', question: 'Kapan tanggal vaksin terakhir?', type: QuestionType.text),
      ConsultationQuestion(key: 'punya_buku_vaksin', question: 'Apakah memiliki buku vaksin?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'sudah_obat_cacing', question: 'Apakah hewan sudah diberi obat cacing?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tanggal_obat_cacing', question: 'Kapan terakhir obat cacing diberikan?', type: QuestionType.text),
      ConsultationQuestion(key: 'reaksi_setelah_vaksin', question: 'Apakah hewan pernah mengalami reaksi setelah vaksin?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'hamil_menyusui', question: 'Apakah hewan sedang hamil atau menyusui?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'sering_keluar_rumah', question: 'Apakah hewan sering keluar rumah?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'tinggal_banyak_hewan', question: 'Apakah hewan tinggal bersama banyak hewan lain?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'ada_rencana_grooming', question: 'Apakah hewan akan grooming, boarding, atau bepergian?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'kontak_hewan_sakit', question: 'Apakah hewan pernah kontak dengan hewan sakit?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'jadwal_lanjutan', question: 'Apakah pemilik ingin membuat jadwal vaksin lanjutan?', type: QuestionType.yesNo),
    ],
    'Tambahan': [
      ConsultationQuestion(key: 'asal_hewan', question: 'Apakah hewan berasal dari shelter, pet shop, atau adopsi?', type: QuestionType.text),
      ConsultationQuestion(key: 'riwayat_vaksin_jelas', question: 'Apakah riwayat vaksin sebelumnya jelas?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'rencana_perjalanan', question: 'Apakah ada rencana perjalanan luar kota?', type: QuestionType.yesNo),
      ConsultationQuestion(key: 'syarat_vaksin_penitipan', question: 'Apakah ada syarat vaksin dari tempat penitipan/grooming?', type: QuestionType.yesNo),
    ],
    'Darurat': []
  },
};

class ConsultationWizardScreen extends StatefulWidget {
  const ConsultationWizardScreen({super.key});

  @override
  State<ConsultationWizardScreen> createState() =>
      _ConsultationWizardScreenState();
}

class _ConsultationWizardScreenState extends State<ConsultationWizardScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late TabController _tabController;
  int _currentPage = 0;

  // State
  Map<String, Object?>? selectedPet;
  String? selectedService;
  
  // Dynamic form answers
  Map<String, dynamic> formAnswers = {};
  
  // Form keys
  final _formKey = GlobalKey<FormState>();

  // Uploaded media
  List<String> consultationPhotos = [];
  List<String> consultationVideos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == 0 && selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih hewan terlebih dahulu.')));
      return;
    }
    if (_currentPage == 0 && selectedPet != null) {
      final species = (selectedPet!['species'] as String).toLowerCase();
      if (species != 'anjing' && species != 'kucing') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Layanan saat ini hanya untuk Anjing dan Kucing.')));
        return;
      }
    }
    if (_currentPage == 1 && selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih layanan terlebih dahulu.')));
      return;
    }

    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prev() {
    if (_currentPage == 4 && _tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
      return;
    }
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  int get _currentStep {
    if (_currentPage == 0) return 0; // Hewan
    if (_currentPage >= 1 && _currentPage <= 3) return 1; // Layanan
    if (_currentPage == 4) return 2; // Kuesioner
    return 3; // Selesai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentPage == 0) {
                Navigator.pop(context);
              } else {
                _prev();
              }
            }),
        title: Text(_getAppBarTitle()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              children: [
                _buildPilihHewan(), // 0
                _buildPilihLayanan(), // 1
                _buildDetailLayanan(), // 2
                _buildInfoBatas(), // 3
                _buildKuesionerMedis(), // 4
                _buildRingkasan(), // 5
                _buildHasilSkrining(), // 6
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentPage) {
      case 0:
        return 'Pilih Hewan';
      case 1:
        return 'Pilih Layanan';
      case 2:
        return 'Detail Layanan';
      case 3:
        return 'Info Batas Telemedicine';
      case 4:
        return 'Kuesioner Medis';
      case 5:
        return 'Ringkasan Keluhan';
      case 6:
        return 'Hasil Skrining';
      default:
        return 'Konsultasi';
    }
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(0, 'Hewan'),
          _buildLine(0),
          _buildStepItem(1, 'Layanan'),
          _buildLine(1),
          _buildStepItem(2, 'Kuesioner'),
          _buildLine(2),
          _buildStepItem(3, 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildLine(int stepIndex) {
    return Expanded(
      child: Container(
        height: 2,
        color: _currentStep > stepIndex
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE0E5EC),
      ),
    );
  }

  Widget _buildStepItem(int stepIndex, String label) {
    final isCompleted = _currentStep > stepIndex;
    final isActive = _currentStep == stepIndex;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : isActive
                    ? const Color(0xFF45A5C7)
                    : const Color(0xFFE0E5EC),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Center(
                  child: Text('${stepIndex + 1}',
                      style: TextStyle(
                          color:
                              isActive ? Colors.white : const Color(0xFF7A93AA),
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: isActive
                    ? const Color(0xFF45A5C7)
                    : const Color(0xFF7A93AA),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildFooter(String btnText, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF45A5C7),
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(btnText,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // ==== STEP 0: PILIH HEWAN ====
  Widget _buildPilihHewan() {
    return Consumer<PetProvider>(builder: (context, provider, child) {
      if (provider.loading)
        return const Center(child: CircularProgressIndicator());
      if (provider.pets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Anda belum memiliki data hewan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.petAdd),
                child: const Text('Tambah Hewan'),
              )
            ],
          ),
        );
      }
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Pilih hewan yang akan dikonsultasikan',
                style: TextStyle(color: Color(0xFF7A93AA))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: provider.pets.length,
              itemBuilder: (context, index) {
                final pet = provider.pets[index];
                final isSelected = selectedPet?['id'] == pet['id'];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF45A5C7)
                            : const Color(0xFFE6F4F8),
                        width: 2),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFF0F4F8),
                      child: Icon(
                          pet['species'] == 'Anjing'
                              ? Icons.pets
                              : Icons.pets_outlined,
                          color: const Color(0xFF45A5C7)),
                    ),
                    title: Text(pet['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(
                        '${pet['species']} - ${pet['age']} Tahun\n${pet['breed']}'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF45A5C7))
                        : const Icon(Icons.circle_outlined,
                            color: Color(0xFFE6F4F8)),
                    onTap: () => setState(() => selectedPet = pet),
                  ),
                );
              },
            ),
          ),
          _buildFooter('Lanjut', _next),
        ],
      );
    });
  }

// ==== STEP 1: PILIH LAYANAN ====
  Widget _buildPilihLayanan() {
    final layanans = [
      {
        'title': 'Keluhan Kesehatan Umum',
        'subtitle': 'Demam, batuk, diare, dll',
        'icon': Icons.medical_services
      },
      {
        'title': 'Kulit dan Bulu',
        'subtitle': 'Gatal, rontok, jamur, alergi kulit',
        'icon': Icons.pets
      },
      {
        'title': 'Pencernaan',
        'subtitle': 'Muntah, diare, sembelit, dll',
        'icon': Icons.set_meal
      },
      {
        'title': 'Nutrisi',
        'subtitle': 'Pola makan, alergi makanan',
        'icon': Icons.restaurant
      },
      {
        'title': 'Perilaku',
        'subtitle': 'Agresif, cemas, takut, dll',
        'icon': Icons.psychology
      },
      {
        'title': 'Vaksinasi',
        'subtitle': 'Konsultasi jadwal vaksinasi',
        'icon': Icons.vaccines
      },
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Pilih jenis layanan klinis',
              style: TextStyle(color: Color(0xFF7A93AA))),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: layanans.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Color(0xFFF0F4F8), height: 1),
            itemBuilder: (context, index) {
              final lay = layanans[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE6F4F8),
                  child: Icon(lay['icon'] as IconData,
                      color: const Color(0xFF45A5C7), size: 20),
                ),
                title: Text(lay['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(lay['subtitle'] as String,
                    style: const TextStyle(fontSize: 12)),
                trailing:
                    const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
                onTap: () {
                  setState(() => selectedService = lay['title'] as String);
                  _next();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==== STEP 2: DETAIL LAYANAN ====
  Widget _buildDetailLayanan() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF0F4F8)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.medical_services,
                      size: 64, color: Color(0xFF45A5C7)),
                  const SizedBox(height: 16),
                  Text(selectedService ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text(
                      'Layanan konsultasi untuk keluhan umum seperti demam, batuk, pilek, lesu, tidak nafsu makan, dll.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF7A93AA))),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Termasuk:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem('Konsultasi dengan dokter hewan'),
                  _buildCheckItem('Skrining kondisi kesehatan'),
                  _buildCheckItem('Saran penanganan awal'),
                  _buildCheckItem('Resep (jika diperlukan)'),
                  _buildCheckItem('Kontrol dan monitoring'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildFooter('Pilih Layanan Ini', _next),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF45A5C7), size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Color(0xFF0F2646))),
        ],
      ),
    );
  }

  // ==== STEP 3: INFO BATAS ====
  Widget _buildInfoBatas() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.desktop_windows,
                    size: 100, color: Color(0xFF45A5C7)),
                const SizedBox(height: 24),
                const Text('Telemedicine memiliki batasan layanan.',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _buildDotItem('Tidak untuk kondisi gawat darurat berat'),
                _buildDotItem('Tidak dapat menggantikan pemeriksaan fisik'),
                _buildDotItem('Tidak untuk tindakan medis invasif'),
                _buildDotItem('Resep sesuai kebijakan dokter hewan'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F8),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFF45A5C7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                            'Jika kondisi hewan memburuk, dokter akan menyarankan untuk pemeriksaan langsung ke klinik.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF0F2646))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFooter('Saya Mengerti, Lanjutkan', _next),
        ],
      ),
    );
  }

  Widget _buildDotItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF7A93AA)),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(text, style: const TextStyle(color: Color(0xFF0F2646)))),
        ],
      ),
    );
  }

  // ==== STEP 4: KUESIONER MEDIS (Wajib, Tambahan, Darurat) ====
  Widget _buildKuesionerMedis() {
    final serviceData = serviceConfig[selectedService] ?? {};
    final tabs = ['Wajib', 'Tambahan', 'Darurat'];

    return Column(
      children: [
        const SizedBox(height: 16),
        IgnorePointer(
          ignoring: true,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF45A5C7),
            unselectedLabelColor: const Color(0xFF7A93AA),
            indicatorColor: const Color(0xFF45A5C7),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: tabs.map((tab) {
              final questions = serviceData[tab] ?? [];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: tab == 'Wajib' ? _formKey : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (questions.isEmpty)
                        const Text('Belum ada daftar pertanyaan untuk bagian ini.', style: TextStyle(color: Colors.grey)),
                      ...questions.map((q) => _buildDynamicQuestion(q, isWajib: tab == 'Wajib', isDarurat: tab == 'Darurat')),
                      if (tab == 'Tambahan') ...[
                        const SizedBox(height: 32),
                        _buildUploadFotoSection(),
                      ]
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            String btnText = 'Lanjut ke Tambahan';
            if (_tabController.index == 1) btnText = 'Lanjut ke Darurat';
            if (_tabController.index == 2) btnText = 'Lanjut ke Ringkasan';

            return _buildFooter(btnText, () {
              if (_tabController.index == 0) {
                if (_formKey.currentState != null && !_formKey.currentState!.validate()) return;
                
                // Manual validation for all required fields (radio, yes/no)
                final wajibQuestions = serviceConfig[selectedService]?['Wajib'] ?? [];
                for (var q in wajibQuestions) {
                  if (formAnswers[q.key] == null || formAnswers[q.key].toString().trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harap jawab pertanyaan: ${q.question}')));
                    return;
                  }
                }
                
                if (_formKey.currentState != null) _formKey.currentState!.save();
                _tabController.animateTo(1);
              } else if (_tabController.index == 1) {
                _tabController.animateTo(2);
              } else {
                if (_isEmergency()) {
                  _showEmergencyDialog();
                } else {
                  _next();
                }
              }
            });
          },
        ),
      ],
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Kondisi Darurat', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
            'Hewan terindikasi dalam kondisi darurat yang membutuhkan penanganan segera!\n\nSistem akan mengarahkan Anda ke daftar dokter untuk ditangani secara langsung.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _goToDoctorList(); // Go to doctor list immediately
            },
            child: const Text('Cari Dokter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicQuestion(ConsultationQuestion q, {bool isWajib = false, bool isDarurat = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: q.question,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F2646),
              ),
              children: [
                if (isWajib)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (q.type == QuestionType.text)
            TextFormField(
              initialValue: formAnswers[q.key] as String?,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ketik jawaban di sini...'),
              onChanged: (val) => formAnswers[q.key] = val,
              validator: (val) {
                if (isWajib && (val == null || val.isEmpty)) return 'Wajib diisi';
                return null;
              },
            )
          else if (q.type == QuestionType.radio)
            ...q.options.map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  toggleable: true,
                  groupValue: formAnswers[q.key] as String?,
                  activeColor: const Color(0xFF45A5C7),
                  onChanged: (val) => setState(() => formAnswers[q.key] = val),
                ))
          else if (q.type == QuestionType.yesNo)
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Ya'),
                    value: true,
                    toggleable: true,
                    groupValue: formAnswers[q.key] as bool?,
                    activeColor: const Color(0xFF45A5C7),
                    onChanged: (val) {
                      setState(() => formAnswers[q.key] = val);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Tidak'),
                    value: false,
                    toggleable: true,
                    groupValue: formAnswers[q.key] as bool?,
                    activeColor: const Color(0xFF45A5C7),
                    onChanged: (val) => setState(() => formAnswers[q.key] = val),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUploadFotoSection() {
    List<String> suggestions = [];
    if (selectedService == 'Kulit dan Bulu') {
      suggestions = [
        'Foto jarak dekat area kulit bermasalah.',
        'Foto seluruh tubuh hewan.',
        'Foto bagian yang rontok/luka.',
        'Foto kutu/parasit jika terlihat.'
      ];
    } else if (selectedService == 'Pencernaan') {
      suggestions = [
        'Foto feses/muntahan.'
      ];
    } else if (selectedService == 'Perilaku') {
      suggestions = [
        'Video perilaku hewan saat kejadian tersebut muncul.'
      ];
    } else if (selectedService == 'Vaksinasi') {
      suggestions = [
        'Foto buku vaksin atau sertifikat kesehatan (jika ada).'
      ];
    }

    return Column(
      children: [
        const Text('Unggah Foto / Video (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text(
            'Foto atau video membantu dokter\nmemahami kondisi hewan lebih baik.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7A93AA))),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF6FE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF45A5C7).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data Foto yang Disarankan:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF45A5C7), fontSize: 14)),
                const SizedBox(height: 8),
                ...suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF45A5C7))),
                      Expanded(child: Text(s, style: const TextStyle(color: Color(0xFF0F2646), fontSize: 13))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildUploadBox(
                Icons.camera_alt, 'Tambah Foto', 'Maks. 5 MB', () => _showUploadMenu(context, isVideo: false)),
            const SizedBox(width: 16),
            _buildUploadBox(
                Icons.videocam, 'Tambah Video', 'Maks. 20 MB', () => _showUploadMenu(context, isVideo: true)),
          ],
        ),
        if (consultationPhotos.isNotEmpty || consultationVideos.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...consultationPhotos.map((path) => _buildMediaThumbnail(path, false)),
              ...consultationVideos.map((path) => _buildMediaThumbnail(path, true)),
            ],
          ),
        ]
      ],
    );
  }

  Future<void> _pickMedia(bool isVideo, ImageSource source) async {
    final picker = ImagePicker();
    try {
      if (isVideo) {
        final pickedFile = await picker.pickVideo(source: source);
        if (pickedFile != null) {
          setState(() {
            consultationVideos.add(pickedFile.path);
          });
        }
      } else {
        if (source == ImageSource.gallery) {
          final pickedFiles = await picker.pickMultiImage();
          if (pickedFiles.isNotEmpty) {
            setState(() {
              consultationPhotos.addAll(pickedFiles.map((e) => e.path));
            });
          }
        } else {
          final pickedFile = await picker.pickImage(source: source);
          if (pickedFile != null) {
            setState(() {
              consultationPhotos.add(pickedFile.path);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur kamera tidak didukung di perangkat ini (Windows/Desktop). Silakan pilih dari Galeri.')),
        );
      }
    }
  }

  void _showUploadMenu(BuildContext context, {required bool isVideo}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Pilih Sumber',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(isVideo, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(isVideo, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(String path, bool isVideo) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: isVideo 
            ? const Icon(Icons.videocam, color: Colors.grey, size: 40)
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(path), fit: BoxFit.cover),
              ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isVideo) {
                  consultationVideos.remove(path);
                } else {
                  consultationPhotos.remove(path);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFF45A5C7).withOpacity(0.2),
        highlightColor: const Color(0xFF45A5C7).withOpacity(0.1),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE6F4F8), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF45A5C7), size: 32),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
          ],
        ),
      ),
      ),
    );
  }

  // ==== STEP 5: RINGKASAN ====
  Widget _buildRingkasan() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedPet != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFF0F4F8),
                        child: Icon(
                            selectedPet!['species'] == 'Anjing'
                                ? Icons.pets
                                : Icons.pets_outlined,
                            color: const Color(0xFF45A5C7)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedPet!['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(
                              '${selectedPet!['breed']} - ${selectedPet!['age']} Tahun',
                              style: const TextStyle(color: Color(0xFF7A93AA))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                _buildRingkasanRow('Layanan', selectedService ?? '-'),
                ...formAnswers.entries.map((e) {
                  return _buildRingkasanRow(
                      _getQuestionLabel(e.key), e.value.toString());
                }),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F8),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFF45A5C7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                            'Pastikan semua informasi sudah benar sebelum melanjutkan.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF0F2646))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter('Lanjut ke Skrining', _next),
      ],
    );
  }

  String _getQuestionLabel(String key) {
    if (selectedService == null) return key;
    final data = serviceConfig[selectedService] ?? {};
    for (var tab in data.values) {
      for (var q in tab) {
        if (q.key == key) return q.question;
      }
    }
    return key;
  }

  Widget _buildRingkasanRow(String label, String value) {
    if (value == 'true') value = 'Ya';
    if (value == 'false') value = 'Tidak';
    if (value.isEmpty || value == 'null') value = '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 12))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ==== STEP 6: HASIL SKRINING ====
  Widget _buildHasilSkrining() {
    bool isDarurat = _isEmergency();
    String category = 'Ringan';
    Color iconColor = Colors.green;
    IconData icon = Icons.check_circle;
    String desc =
        'Hewanmu dalam kondisi yang aman untuk konsultasi online.\n\nSilakan lanjut memilih dokter untuk mendapatkan konsultasi.';

    if (isDarurat) {
      category = 'Darurat';
      iconColor = Colors.red;
      icon = Icons.warning;
      desc =
          'Hewanmu terindikasi dalam kondisi darurat!\nSegera lakukan tindakan dan cari pertolongan medis terdekat.';
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 100, color: iconColor),
                  const SizedBox(height: 24),
                  Text('Kondisi $category',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: iconColor)),
                  const SizedBox(height: 16),
                  Text(desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 16)),
                  if (category == 'Darurat') ...[
                    const SizedBox(height: 32),
                    const Text('Apa yang bisa dilakukan sekarang?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 12),
                    _buildEmergencyAction('Tetap tenang dan amankan hewan'),
                    _buildEmergencyAction(
                        'Lakukan pertolongan awal sesuai arahan'),
                    _buildEmergencyAction(
                        'Segera bawa ke klinik / rumah sakit hewan'),
                  ],
                ],
              ),
            ),
          ),
          if (category == 'Darurat') ...[
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cari Klinik Terdekat',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _goToDoctorList,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0F2646)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Hubungi Dokter',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
            ),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Beranda')),
          ] else ...[
            _buildFooter('Pilih Dokter', _goToDoctorList),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Beranda')),
          ],
        ],
      ),
    );
  }

  bool _isEmergency() {
    final daruratKeys = serviceConfig[selectedService]?['Darurat']?.map((e) => e.key).toList() ?? [];
    for (var key in daruratKeys) {
      if (formAnswers[key] == true) return true;
    }
    return false;
  }

  Widget _buildEmergencyAction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _goToDoctorList() {
    bool isDarurat = _isEmergency();
    String category = isDarurat ? 'Darurat' : 'Ringan';

    // Prepare JSON data to pass to DoctorListScreen
    // Store JSON in 'main_complaints' to match existing SQLite schema without altering it
    final Map<String, dynamic> complaintData = {
      'service_type': selectedService,
      'main_complaints': jsonEncode(formAnswers),
    };

    if (category == 'Darurat') {
      Navigator.pushNamed(context, AppRoutes.emergencyVisit, arguments: {
        'pet_id': selectedPet!['id'],
        'complaint': formAnswers['keluhan_utama'] ?? selectedService,
        'complaint_data': complaintData,
        'screening_data': <String, dynamic>{'result_category': category},
      });
    } else {
      Navigator.pushNamed(context, AppRoutes.doctorList, arguments: {
        'pet_id': selectedPet!['id'],
        'complaint': formAnswers['keluhan_utama'] ?? selectedService,
        'complaint_data': complaintData,
        'screening_data': <String, dynamic>{'result_category': category},
      });
    }
  }
}
