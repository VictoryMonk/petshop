import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/petshop_service.dart';

class PetshopServiceService {
  final DatabaseHelper dbHelper;
  PetshopServiceService(this.dbHelper);

  Future<int> createService(PetshopServiceModel service) async {
    final db = await dbHelper.database;
    return await db.insert('petshop_services', service.toMap());
  }

  Future<List<PetshopServiceModel>> getAllServices() async {
    final db = await dbHelper.database;
    final result = await db.query('petshop_services');
    return result.map((map) => PetshopServiceModel.fromMap(map)).toList();
  }

  Future<int> updateService(PetshopServiceModel service) async {
    final db = await dbHelper.database;
    return await db.update('petshop_services', service.toMap(), where: 'id = ?', whereArgs: [service.id]);
  }

  Future<int> deleteService(int id) async {
    final db = await dbHelper.database;
    return await db.delete('petshop_services', where: 'id = ?', whereArgs: [id]);
  }
}
