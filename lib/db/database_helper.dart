import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the open database, initializing it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('petcare.db');
    return _database!;
  }

  /// Call this at app startup to ensure the DB is created.
  Future<void> initializeDB() async {
    await database;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 4,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Turn on foreign‑key constraints
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create all tables and seed initial data
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL,
        email    TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL,
        role     TEXT    NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE pets (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL,
        species  TEXT    NOT NULL,
        breed    TEXT    NOT NULL,
        age      INTEGER NOT NULL,
        ownerId  INTEGER NOT NULL,
        FOREIGN KEY(ownerId) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY(petId) REFERENCES pets(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE petshop_services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        petId INTEGER NOT NULL,
        serviceId INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(petId) REFERENCES pets(id) ON DELETE CASCADE,
        FOREIGN KEY(serviceId) REFERENCES petshop_services(id) ON DELETE CASCADE
      );
    ''');
    // Seed some example services
    final existing = await db.query('petshop_services');
    if (existing.isEmpty) {
      await db.insert('petshop_services', {
        'name': 'Grooming',
        'description': 'Full pet grooming including bath, haircut, and nail trim.',
        'price': 50.0,
        'category': 'Grooming',
      });
      await db.insert('petshop_services', {
        'name': 'Boarding',
        'description': 'Overnight boarding in a safe, clean environment.',
        'price': 100.0,
        'category': 'Boarding',
      });
      await db.insert('petshop_services', {
        'name': 'Daycare',
        'description': 'Daytime care and play for your pet.',
        'price': 30.0,
        'category': 'Daycare',
      });
    }

    // Seed default admin user
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@petcare.com',
      'password': 'admin123',
      'role': 'admin',
    });
  }

  /// Handle DB migrations when you bump [version]
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          petId INTEGER NOT NULL,
          type TEXT NOT NULL,
          description TEXT NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY(petId) REFERENCES pets(id) ON DELETE CASCADE
        );
      ''');
    }
    // Add imagePath column to pets if upgrading to version 4
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE pets ADD COLUMN imagePath TEXT;
      ''');
    }
  }

  // ─── EXAMPLE CRUD METHODS ─────────────────────────────────────────

  /// Insert a new user; returns the new row id.
  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  /// Fetch all users.
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  /// Insert a new pet; returns the new row id.
  Future<int> createPet(Map<String, dynamic> pet) async {
    final db = await instance.database;
    return await db.insert('pets', pet);
  }

  /// Fetch all pets for a given owner.
  Future<List<Map<String, dynamic>>> fetchPetsForOwner(int ownerId) async {
    final db = await instance.database;
    return await db.query(
      'pets',
      where: 'ownerId = ?',
      whereArgs: [ownerId],
    );
  }

  /// Close the database (call on app dispose).
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
