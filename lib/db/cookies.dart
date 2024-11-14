import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(SqliteMigration(1, (tx) async {
    await tx.execute(
        'CREATE TABLE cookies(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT, datatype INTEGER)');
  }));

enum COOKIE_TYPE { STRING, INT, BOOL, STRING_LIST, INT_LIST }

class Cookies {
  final Database = SqliteDatabase(path: 'cookies.db');
  Map<String, dynamic> cache = {};

  Future<void> initialize() async {
    await migrations.migrate(Database);
  }

  Future<void> loadCache() async {
    final result = await Database.getAll('SELECT * FROM cookies');
    for (var row in result) {
      String key = row['key'] as String;
      int datatype = row['datatype'] as int;
      dynamic value = StringToDataType(datatype, row['value'] as String);
      cache[key] = value;
    }
  }

  DataTypeToString(int datatype, var value) {
    switch (datatype) {
      case COOKIE_TYPE.STRING:
        return value;
      case COOKIE_TYPE.INT:
        return value.toString();
      case COOKIE_TYPE.BOOL:
        return value ? 'true' : 'false';
      case COOKIE_TYPE.STRING_LIST:
        return value.join('|-|');
      case COOKIE_TYPE.INT_LIST:
        return value.join('|-|');
      default:
        return "";
    }
  }

  StringToDataType(int datatype, String value) {
    switch (datatype) {
      case COOKIE_TYPE.STRING:
        return value;
      case COOKIE_TYPE.INT:
        return int.parse(value);
      case COOKIE_TYPE.BOOL:
        return value == 'true';
      case COOKIE_TYPE.STRING_LIST:
        return value.split('|-|');
      case COOKIE_TYPE.INT_LIST:
        return value.split('|-|').map((e) => int.parse(e)).toList();
      default:
        return null;
    }
  }

  Future<void> setCookie(String key, var value, COOKIE_TYPE type) async {
    cache[key] = value;

    await Database.writeTransaction((tx) async {
      await tx.execute(
          'INSERT INTO cookies(key, value, datatype) VALUES(?, ?, ?)',
          [key, DataTypeToString(type.index, value), type.index]);
    });
  }

  dynamic getCookie(String key) {
    return cache[key];
  }

  Future<void> removeCookie(String key) async {
    await Database.writeTransaction((tx) async {
      await tx.execute('DELETE FROM cookies WHERE key = ?', [key]);
    });
  }
}
