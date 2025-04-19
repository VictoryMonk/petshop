import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the open database, initializing it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('petcare.db');
    return _database!;
  }

  /// Initialize the DB at app startup.
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

  /// Enable foreign key constraints
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create tables and seed initial data
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        imageUrl TEXT,
        stock INTEGER NOT NULL,
        category TEXT
      );
    ''');

    // Seed example products if table is empty
    final existingProducts = await db.query('products');
    if (existingProducts.isEmpty) {
      await db.insert('products', {
        'name': 'Dog Food Premium',
        'description': 'High quality dry dog food for all breeds.',
        'price': 799.0,
        'imageUrl': 'https://images.pexels.com/photos/4587997/pexels-photo-4587997.jpeg?auto=compress&w=400&q=80',
        'stock': 25,
        'category': 'Food',
      });
      await db.insert('products', {
        'name': 'Cat Toy Mouse',
        'description': 'Fun plush mouse toy for cats.',
        'price': 99.0,
        'imageUrl': 'https://images.unsplash.com/photo-1518715308788-3005759c41b5?auto=format&fit=crop&w=400&q=80',
        'stock': 50,
        'category': 'Toys',
      });
      await db.insert('products', {
        'name': 'Bird Cage Deluxe',
        'description': 'Spacious cage suitable for small birds.',
        'price': 1499.0,
        'imageUrl': 'https://images.pexels.com/photos/325490/pexels-photo-325490.jpeg?auto=compress&w=400&q=80',
        'stock': 10,
        'category': 'Accessories',
      });
      await db.insert('products', {
        'name': 'Pet Shampoo',
        'description': 'Gentle shampoo for pets with sensitive skin.',
        'price': 299.0,
        'imageUrl': 'https://images.unsplash.com/photo-1518715308788-3005759c41b5?auto=format&fit=crop&w=400&q=80',
        'stock': 40,
        'category': 'Grooming',
      });
    }

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        items TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL,
        address TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT NOT NULL,
        age INTEGER NOT NULL,
        ownerId INTEGER NOT NULL,
        imagePath TEXT,
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

    // Seed petshop services
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

    // Seed admin user
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@petcare.com',
      'password': 'admin123',
      'role': 'admin',
    });
  }

  /// Migrate DB if version is upgraded
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

    // Migration: create products table if missing
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          price REAL NOT NULL,
          imageUrl TEXT,
          stock INTEGER NOT NULL,
          category TEXT
        );
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE pets ADD COLUMN imagePath TEXT;
      ''');
    }
    // Migration: add address column to orders
    if (oldVersion < 5) {
      await db.execute("ALTER TABLE orders ADD COLUMN address TEXT;");
    }
  }

  // ─── ORDER CRUD ─────────────────────────────────────

  Future<int> createOrder(Map<String, dynamic> order) async {
    final db = await instance.database;
    return await db.insert('orders', order);
  }

  Future<List<Map<String, dynamic>>> fetchOrdersForUser(int userId) async {
    final db = await instance.database;
    return await db.query('orders', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final db = await instance.database;
    return await db.query('orders', orderBy: 'date DESC');
  }

  // ─── PRODUCT CRUD ─────────────────────────────────────

  Future<int> createProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.insert('products', product);
  }

  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.update('products', product, where: 'id = ?', whereArgs: [product['id']]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ─── USER CRUD ─────────────────────────────────────

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  // ─── PET CRUD ─────────────────────────────────────

  Future<int> createPet(Map<String, dynamic> pet) async {
    final db = await instance.database;
    return await db.insert('pets', pet);
  }

  Future<List<Map<String, dynamic>>> fetchPetsForOwner(int ownerId) async {
    final db = await instance.database;
    return await db.query(
      'pets',
      where: 'ownerId = ?',
      whereArgs: [ownerId],
    );
  }

  // ─── CLOSE ─────────────────────────────────────

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
