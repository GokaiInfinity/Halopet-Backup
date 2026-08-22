import 'package:postgres/postgres.dart';

class PgExecutor {
  final Session session;
  PgExecutor(this.session);

  String _convertQuery(String sql) {
    int count = 1;
    return sql.replaceAllMapped(RegExp(r'\?'), (match) => '\$${count++}');
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    final converted = _convertQuery(sql);
    // Convert SQLite syntax to PostgreSQL
    final cleanSql = converted
        .replaceAll('INTEGER PRIMARY KEY AUTOINCREMENT', 'SERIAL PRIMARY KEY')
        .replaceAll('AUTOINCREMENT', 'SERIAL');
    await session.execute(
      Sql(cleanSql),
      parameters: arguments?.map(_mapParam).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final converted = _convertQuery(sql);
    final result = await session.execute(
      Sql(converted),
      parameters: arguments?.map(_mapParam).toList(),
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final cols = columns != null && columns.isNotEmpty ? columns.join(', ') : '*';
    var sql = 'SELECT $cols FROM $table';
    if (where != null) {
      final convertedWhere = _convertQuery(where);
      sql += ' WHERE $convertedWhere';
    }
    if (orderBy != null) {
      sql += ' ORDER BY $orderBy';
    }
    if (limit != null) {
      sql += ' LIMIT $limit';
    }
    if (offset != null) {
      sql += ' OFFSET $offset';
    }
    return rawQuery(sql, whereArgs);
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    if (values.isEmpty) return 0;
    final columnsList = values.keys.join(', ');
    final placeholders = List.generate(values.length, (i) => '\$${i + 1}').join(', ');
    final sql = 'INSERT INTO $table ($columnsList) VALUES ($placeholders) RETURNING id';
    
    final result = await session.execute(
      Sql(sql),
      parameters: values.values.map(_mapParam).toList(),
    );
    if (result.isNotEmpty && result.first.isNotEmpty) {
      return result.first[0] as int;
    }
    return 0;
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (values.isEmpty) return 0;
    
    int paramIndex = 1;
    final setClause = values.keys.map((k) => '$k = \$${paramIndex++}').join(', ');
    
    var sql = 'UPDATE $table SET $setClause';
    final List<Object?> params = values.values.map(_mapParam).toList();
    
    if (where != null) {
      final convertedWhere = where.replaceAllMapped(RegExp(r'\?'), (m) => '\$${paramIndex++}');
      sql += ' WHERE $convertedWhere';
      if (whereArgs != null) {
        params.addAll(whereArgs.map(_mapParam));
      }
    }
    
    final result = await session.execute(Sql(sql), parameters: params);
    return result.affectedRows;
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    var sql = 'DELETE FROM $table';
    if (where != null) {
      final convertedWhere = _convertQuery(where);
      sql += ' WHERE $convertedWhere';
    }
    final result = await session.execute(
      Sql(sql),
      parameters: whereArgs?.map(_mapParam).toList(),
    );
    return result.affectedRows;
  }
  
  Object? _mapParam(Object? p) {
    if (p is bool) return p ? 1 : 0; 
    return p;
  }
}

class PgDatabase extends PgExecutor {
  final Connection conn;
  PgDatabase(this.conn) : super(conn);

  Future<T> transaction<T>(Future<T> Function(PgExecutor txn) action) async {
    return await conn.runTx((ctx) async {
      return await action(PgExecutor(ctx));
    });
  }
}
