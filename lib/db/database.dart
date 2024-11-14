import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(SqliteMigration(1, (tx) async {
    await tx.execute(
        'CREATE TABLE tags(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT, datatype INTEGER)');
    await tx.execute(
        'CREATE TABLE songs(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT, datatype INTEGER)');
    await tx.execute(
        'CREATE TABLE playlists(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT, datatype INTEGER)');
  }));

class Saver {
  final Database = SqliteDatabase(path: 'cookies.db');

  Future<void> initialize() async {
    await migrations.migrate(Database);
  }
}
// eigene  child klassen für  die einnzelnen  tables?
