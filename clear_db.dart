import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

void main() async {
  // Load environment variables manually since this is a standalone script
  final envFile = File('.env');
  if (await envFile.exists()) {
    final lines = await envFile.readAsLines();
    for (var line in lines) {
      if (line.contains('=')) {
        final parts = line.split('=');
        dotenv.env[parts[0]] = parts[1];
      }
    }
  }

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

  final tables = [
    'reviews', 'monitoring_logs', 'medicine_orders', 'prescription_items',
    'prescriptions', 'consultation_results', 'notifications', 'medical_records',
    'messages', 'screenings', 'complaints', 'consultations', 'schedules',
    'diseases', 'vaccinations', 'pets', 'doctors', 'help_tickets', 'users',
    'services', 'medicines'
  ];

  for (var table in tables) {
    try {
      await conn.execute(Sql('DELETE FROM $table'));
    } catch (e) {
      print('Could not delete from $table: $e');
    }
  }

  print('Database cleared successfully (PostgreSQL)!');
  await conn.close();
  exit(0);
}
