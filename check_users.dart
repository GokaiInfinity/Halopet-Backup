import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final dbPath = 'E:/Flutter_Projects_and_SDK/Projects/Halopet/.dart_tool/sqflite_common_ffi/databases';
  final dbFile = path.join(dbPath, 'halopet_vetcare.db');
  
  if (!File(dbFile).existsSync()) {
    print('DB File not found: $dbFile');
    return;
  }
  
  final db = await openDatabase(dbFile);
  final users = await db.query('users');
  for (var u in users) {
    print(u);
  }
  await db.close();
}
