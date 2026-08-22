import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

void main() async {
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

  final result = await conn.execute(Sql('SELECT * FROM users'));
  print('Total users: \${result.length}');
  for (final row in result) {
    print(row.toColumnMap());
  }

  await conn.close();
  exit(0);
}
