import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/pet.dart';

class PetService {
  final DatabaseHelper dbHelper;

  PetService(this.dbHelper);

  Future<int> createPet(Pet pet) async {
    final db = await dbHelper.database;
    return await db.insert('pets', pet.toMap());
  }

  Future<Pet?> getPetById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query('pets', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Pet.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Pet>> getAllPets() async {
    final db = await dbHelper.database;
    final result = await db.query('pets');
    return result.map((map) => Pet.fromMap(map)).toList();
  }

  Future<List<Pet>> getPetsByOwner(int ownerId) async {
    final db = await dbHelper.database;
    final result = await db.query('pets', where: 'ownerId = ?', whereArgs: [ownerId]);
    return result.map((map) => Pet.fromMap(map)).toList();
  }

  Future<int> updatePet(Pet pet) async {
    final db = await dbHelper.database;
    return await db.update('pets', pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);
  }

  Future<int> deletePet(int id) async {
    final db = await dbHelper.database;
    return await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }
}
