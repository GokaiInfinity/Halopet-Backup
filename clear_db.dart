import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  var db = await databaseFactory.openDatabase(
      'E:/github/Halopet Backup/.dart_tool/sqflite_common_ffi/databases/halopet.db');

  await db.execute('DELETE FROM consultations');
  await db.execute("UPDATE schedules SET status = 'available'");
  await db.execute('DELETE FROM consultation_results');
  await db.execute('DELETE FROM prescriptions');
  await db.execute('DELETE FROM messages');

  print('Database cleared successfully!');
  await db.close();
  exit(0);
}
