import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../config/Api_Constants.dart';
import '../models/game.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // 🔧 LÍNEA 32: Tabla corregida
  Future<void> _createDB(Database db, int version) async {
    // Tabla de juegos favoritos y colecciones
    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        background_image TEXT,
        rating REAL,
        metacritic INTEGER,
        released TEXT,
        genres TEXT,
        platforms TEXT,
        is_favorite INTEGER DEFAULT 0,
        collection_type TEXT,
        updated_at TEXT,
        playtime INTEGER,
        ratings_count INTEGER,
        rating_top INTEGER,
        website TEXT,
        screenshots TEXT,
        short_screenshots TEXT,
        description_raw TEXT,
        UNIQUE(id),
        CHECK(is_favorite IN (0,1)),
        CHECK(collection_type IN ('playing', 'completed', 'wishlist') OR collection_type IS NULL)
      )
    ''');

    // Tabla de caché de búsquedas
    await db.execute('''
      CREATE TABLE search_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla de configuraciones
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_games_favorite ON games(is_favorite)');
    await db.execute('CREATE INDEX idx_games_collection ON games(collection_type)');
    await db.execute('CREATE INDEX idx_games_updated ON games(updated_at DESC)');
  }

  // 🔧 LÍNEA 85: Migración corregida
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columnas faltantes si existen tablas viejas
      try {
        await db.execute('ALTER TABLE games ADD COLUMN website TEXT');
      } catch (e) {
        print('Column website already exists or error: $e');
      }
      
      try {
        await db.execute('ALTER TABLE games ADD COLUMN screenshots TEXT');
      } catch (e) {
        print('Column screenshots already exists or error: $e');
      }
      
      try {
        await db.execute('ALTER TABLE games ADD COLUMN updated_at TEXT');
      } catch (e) {
        print('Column updated_at already exists or error: $e');
      }
      
      try {
        await db.execute('ALTER TABLE games ADD COLUMN playtime INTEGER');
      } catch (e) {
        print('Column playtime already exists or error: $e');
      }
      
      try {
        await db.execute('ALTER TABLE games ADD COLUMN ratings_count INTEGER');
      } catch (e) {
        print('Column ratings_count already exists or error: $e');
      }
      
      try {
        await db.execute('ALTER TABLE games ADD COLUMN rating_top INTEGER');
      } catch (e) {
        print('Column rating_top already exists or error: $e');
      }
    }
  }

  // CRUD Operations for Games

  // 🔧 LÍNEA 135: Insertar juego CORREGIDO
  Future<int> insertGame(Game game) async {
    final db = await database;
    try {
      return await db.insert(
        'games',
        game.toSqliteMap(), // Ya convierte correctamente a primitivos
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error inserting game: $e');
      rethrow;
    }
  }

  // Obtener todos los juegos guardados
  Future<List<Game>> getAllGames() async {
    final db = await database;
    final maps = await db.query('games', orderBy: 'updated_at DESC');
    return maps.map((map) => Game.fromSqliteMap(map)).toList();
  }

  // Obtener juego por ID
  Future<Game?> getGameById(int id) async {
    final db = await database;
    final maps = await db.query(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Game.fromSqliteMap(maps.first);
  }

  // 🔧 LÍNEA 175: insertFavorite CORREGIDO
  Future<void> insertFavorite(Game game) async {
    final db = await database;

    try {
      final map = game.toSqliteMap();
      map['is_favorite'] = 1;
      map['updated_at'] = DateTime.now().toIso8601String();

      await db.insert(
        'games',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('✅ Favorite saved: ${game.name}');
    } catch (e) {
      print('❌ Error saving favorite: $e');
      rethrow;
    }
  }

  // Eliminar favorito
  Future<void> deleteFavorite(int id) async {
    final db = await database;

    await db.update(
      'games',
      {
        'is_favorite': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    
    print('✅ Favorite removed: $id');
  }

  // 🔧 LÍNEA 215: addToCollection CORREGIDO
  Future<void> addToCollection(Game game, String collectionType) async {
    final db = await database;

    try {
      final map = game.toSqliteMap();
      map['collection_type'] = collectionType;
      map['updated_at'] = DateTime.now().toIso8601String();

      await db.insert(
        'games',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('✅ Added to collection "$collectionType": ${game.name}');
    } catch (e) {
      print('❌ Error adding to collection: $e');
      print('   Game: ${game.name}');
      print('   Collection: $collectionType');
      rethrow;
    }
  }

  // Obtener favoritos
  Future<List<Game>> getFavoriteGames() async {
    final db = await database;
    final maps = await db.query(
      'games',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => Game.fromSqliteMap(map)).toList();
  }

  // Obtener juegos de una colección
  Future<List<Game>> getGamesByCollection(String collectionType) async {
    final db = await database;
    final maps = await db.query(
      'games',
      where: 'collection_type = ?',
      whereArgs: [collectionType],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => Game.fromSqliteMap(map)).toList();
  }

  // Actualizar estado de favorito
  Future<int> updateFavoriteStatus(int gameId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'games',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }

  // Actualizar tipo de colección
  Future<int> updateCollectionType(int gameId, String? collectionType) async {
    final db = await database;
    return await db.update(
      'games',
      {
        'collection_type': collectionType,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }

  // Eliminar juego
  Future<int> deleteGame(int id) async {
    final db = await database;
    return await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Verificar si un juego está en favoritos
  Future<bool> isGameFavorite(int gameId) async {
    final db = await database;
    final result = await db.query(
      'games',
      where: 'id = ? AND is_favorite = ?',
      whereArgs: [gameId, 1],
    );
    return result.isNotEmpty;
  }

  // Search Cache Operations

  Future<void> addSearchQuery(String query) async {
    final db = await database;
    await db.insert('search_cache', {
      'query': query,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<String>> getRecentSearches({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'search_cache',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => map['query'] as String).toList();
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_cache');
  }

  // Settings Operations

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  // Utility Operations

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('games');
    await db.delete('search_cache');
    print('✅ All data cleared');
  }

  Future<int> getGamesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM games');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 🆕 Método para recrear tabla (si es necesario)
  Future<void> recreateGamesTable() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS games');
    await _createDB(db, AppConstants.dbVersion);
    print('✅ Games table recreated');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}