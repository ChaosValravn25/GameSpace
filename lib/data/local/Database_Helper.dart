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
        updated TEXT,
        platforms TEXT,
        is_favorite INTEGER DEFAULT 0,
        collection_type TEXT,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        website TEXT,
        description_raw TEXT,
        screenshots TEXT,
        updated_at TEXT,
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
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Implementar migraciones si hay cambios en el esquema
    if (oldVersion < 2) {
      // Ejemplo de migración
      // await db.execute('ALTER TABLE games ADD COLUMN new_field TEXT');
      await db.execute('ALTER TABLE games ADD COLUMN website TEXT');
      await db.execute('ALTER TABLE games ADD COLUMN screenshots TEXT');
    }
  }

  // CRUD Operations for Games

  // Insertar o actualizar juego
  Future<int> insertGame(Game game) async {
    final db = await database;
    return await db.insert(
      'games',
      game.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todos los juegos guardados
  Future<List<Game>> getAllGames() async {
    final db = await database;
    final maps = await db.query('games', orderBy: 'added_at DESC');
    return maps.map((map) => Game.fromSqliteMap(map)).toList();
  }

 // ✅ NECESARIO: Obtener juego por ID
Future<Game?> getGameById(int id) async {
  final db = await database;
  final maps = await db.query(
    'games',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isEmpty) return null;
  
  //return Game.fromJson(maps.first) ;
  return Game.fromSqliteMap(maps.first);
}
  // ✅ NECESARIO: Insertar favorito
Future<void> insertFavorite(Game game) async {
  final db = await database;
  
  await db.insert(
    'games',
    {
      ...game.toJson(),
      'is_favorite': 1,  // ← Importante
      'updated_at': DateTime.now().toIso8601String(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  // ✅ NECESARIO: Eliminar favorito
Future<void> deleteFavorite(int id) async {
  final db = await database;
  
  // NO eliminar el juego, solo quitar marca de favorito
  await db.update(
    'games',
    {'is_favorite': 0},
    where: 'id = ?',
    whereArgs: [id],
  );
}

  // ✅ NECESARIO: Agregar a colección
Future<void> addToCollection(Game game, String collectionType) async {
  final db = await database;
  
  await db.insert(
    'games',
    {
      ...game.toJson(),
      'collection_type': collectionType,  // ← Importante
      'updated_at': DateTime.now().toIso8601String(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

 
  // ✅ NECESARIO: Obtener favoritos
Future<List<Game>> getFavoriteGames() async {
  final db = await database;
  final maps = await db.query(
    'games',
    where: 'is_favorite = ?',
    whereArgs: [1],
    orderBy: 'updated_at DESC',
  );

  //return maps.map((map) => Game.fromJson(map)).toList();
  return maps.map((map) => Game.fromSqliteMap(map)).toList();
}

 // ✅ NECESARIO: Obtener juegos de una colección
Future<List<Game>> getGamesByCollection(String collectionType) async {
  final db = await database;
  final maps = await db.query(
    'games',
    where: 'collection_type = ?',
    whereArgs: [collectionType],
    orderBy: 'updated_at DESC',
  );

 // return maps.map((map) => Game.fromJson(map)).toList();
  return maps.map((map) => Game.fromSqliteMap(map)).toList();
}

  // Actualizar estado de favorito
  Future<int> updateFavoriteStatus(int gameId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'games',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }

  // Actualizar tipo de colección
  Future<int> updateCollectionType(int gameId, String? collectionType) async {
    final db = await database;
    return await db.update(
      'games',
      {'collection_type': collectionType},
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
  }

  Future<int> getGamesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM games');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}