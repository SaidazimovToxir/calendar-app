import 'package:calendar_app/data/models/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/event_repository.dart';
import '../datasource/local/sqlite_database.dart';

class EventRepositoryImpl implements EventRepository {
  final SQLiteDatabase _database;
  final _uuid = const Uuid();

  EventRepositoryImpl(this._database);

  @override
  Future<List<EventModel>> getEvents(DateTime start, DateTime end) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'startTime BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(
      maps.length,
      (i) => EventModel.fromMap(
        maps[i],
      ),
    );
  }

  @override
  Future<void> addEvent(EventModel event) async {
    final db = await _database.database;
    await db.insert(
      'events',
      {...event.toMap(), 'id': _uuid.v4()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    final db = await _database.database;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  @override
  Future<void> deleteEvent(String id) async {
    final db = await _database.database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
