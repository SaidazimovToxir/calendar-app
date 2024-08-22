import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'calendar_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE events(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            location TEXT,
            startTime TEXT,
            color TEXT,
            endTime TEXT
          )
        ''');
      },
    );
  }
}
