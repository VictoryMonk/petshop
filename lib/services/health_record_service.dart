import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/health_record.dart';

class HealthRecordService {
  final DatabaseHelper dbHelper;
  HealthRecordService(this.dbHelper);

  Future<int> createHealthRecord(HealthRecord record) async {
    final db = await dbHelper.database;
    return await db.insert('health_records', record.toMap());
  }

  Future<List<HealthRecord>> getHealthRecordsForPet(int petId) async {
    final db = await dbHelper.database;
    final result = await db.query('health_records', where: 'petId = ?', whereArgs: [petId], orderBy: 'date DESC');
    return result.map((map) => HealthRecord.fromMap(map)).toList();
  }

  Future<int> updateHealthRecord(HealthRecord record) async {
    final db = await dbHelper.database;
    return await db.update('health_records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteHealthRecord(int id) async {
    final db = await dbHelper.database;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }
}
