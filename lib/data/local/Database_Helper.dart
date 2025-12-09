import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game.dart';
import '../../config/api_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gamespace.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // 🔧 INCREMENTADA para migración
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // 🔧 CORREGIDO: Tabla con collectionType separado de isFavorite
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';

    // Tabla de juegos con campos separados
    await db.execute('''
      CREATE TABLE games (
        id $idType,
        name $textType,
        backgroundImage TEXT,
        released TEXT,
        rating REAL,
        metacritic $intType,
        description TEXT,
        descriptionRaw TEXT,
        genres TEXT,
        platforms TEXT,
        screenshots TEXT,
        isFavorite $boolType,
        collectionType TEXT,
        addedAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Tabla de búsquedas
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query $textType,
        timestamp TEXT NOT NULL
      )
    ''');

    // 🔧 NUEVO: Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_games_favorite ON games(isFavorite)');
    await db.execute('CREATE INDEX idx_games_collection ON games(collectionType)');
    await db.execute('CREATE INDEX idx_games_updated ON games(updatedAt)');

    print('✅ Database created with version $version');
  }

  // 🔧 NUEVO: Migración de versiones antiguas
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from v$oldVersion to v$newVersion');

    if (oldVersion < 3) {
      // Agregar columna collectionType si no existe
      try {
        await db.execute('ALTER TABLE games ADD COLUMN collectionType TEXT');
        print('✅ Added collectionType column');
      } catch (e) {
        print('⚠️ collectionType column already exists or error: $e');
      }

      // Crear índices si no existen
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_games_favorite ON games(isFavorite)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_games_collection ON games(collectionType)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_games_updated ON games(updatedAt)');
        print('✅ Indexes created');
      } catch (e) {
        print('⚠️ Error creating indexes: $e');
      }
    }
  }

  // 🔧 CORREGIDO: Insert/Update con manejo de colecciones independientes
  Future<void> insertGame(Game game) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      // Verificar si el juego ya existe
      final existing = await getGameById(game.id);

      final gameData = {
        'id': game.id,
        'name': game.name,
        'backgroundImage': game.backgroundImage,
        'released': game.released,
        'rating': game.rating,
        'metacritic': game.metacritic,
        'description': game.description,
        'descriptionRaw': game.descriptionRaw,
        'genres': game.genres?.map((g) => g.name).join(','),
        'platforms': game.parentPlatforms?.map((p) => p.platform.name).join(','),
        'screenshots': game.screenshots?.map((s) => s.image).join(',') ??
            game.shortScreenshots?.map((s) => s.image).join(','),
        'isFavorite': existing?.isFavorite ?? game.isFavorite ? 1 : 0,
        'collectionType': existing?.collectionType ?? game.collectionType,
        'addedAt': existing?.addedAt ?? now,
        'updatedAt': now,
      };

      await db.insert(
        'games',
        gameData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Game saved: ${game.name} (Favorite: ${gameData['isFavorite']}, Collection: ${gameData['collectionType']})');
    } catch (e) {
      print('❌ Error inserting game: $e');
      rethrow;
    }
  }

  // 🔧 CORREGIDO: Favoritos independientes de colecciones
  Future<void> insertFavorite(Game game) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      // Obtener juego existente para preservar collectionType
      final existing = await getGameById(game.id);

      final gameData = {
        'id': game.id,
        'name': game.name,
        'backgroundImage': game.backgroundImage,
        'released': game.released,
        'rating': game.rating,
        'metacritic': game.metacritic,
        'description': game.description,
        'descriptionRaw': game.descriptionRaw,
        'genres': game.genres?.map((g) => g.name).join(','),
        'platforms': game.parentPlatforms?.map((p) => p.platform.name).join(','),
        'screenshots': game.screenshots?.map((s) => s.image).join(',') ??
            game.shortScreenshots?.map((s) => s.image).join(','),
        'isFavorite': 1, // ✅ Marcar como favorito
        'collectionType': existing?.collectionType ?? game.collectionType, // ✅ Preservar colección
        'addedAt': existing?.addedAt ?? now,
        'updatedAt': now,
      };

      await db.insert(
        'games',
        gameData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Added to favorites: ${game.name}');
      print('   Current collection: ${gameData['collectionType']}');
    } catch (e) {
      print('❌ Error adding to favorites: $e');
      print('   Game: ${game.name} (ID: ${game.id})');
      rethrow;
    }
  }

  // 🔧 CORREGIDO: Agregar a colección SIN afectar favoritos
  Future<void> addToCollection(Game game, String collectionType) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      // Obtener juego existente para preservar isFavorite
      final existing = await getGameById(game.id);

      final gameData = {
        'id': game.id,
        'name': game.name,
        'backgroundImage': game.backgroundImage,
        'released': game.released,
        'rating': game.rating,
        'metacritic': game.metacritic,
        'description': game.description,
        'descriptionRaw': game.descriptionRaw,
        'genres': game.genres?.map((g) => g.name).join(','),
        'platforms': game.parentPlatforms?.map((p) => p.platform.name).join(','),
        'screenshots': game.screenshots?.map((s) => s.image).join(',') ??
            game.shortScreenshots?.map((s) => s.image).join(','),
        'isFavorite': existing?.isFavorite ?? game.isFavorite ? 1 : 0, // ✅ Preservar favorito
        'collectionType': collectionType, // ✅ Actualizar colección
        'addedAt': existing?.addedAt ?? now,
        'updatedAt': now,
      };

      await db.insert(
        'games',
        gameData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Added to collection "$collectionType": ${game.name}');
      print('   Is favorite: ${gameData['isFavorite'] == 1}');
    } catch (e) {
      print('❌ Error adding to collection: $e');
      print('   Game: ${game.name} (ID: ${game.id})');
      print('   Collection: $collectionType');
      rethrow;
    }
  }

  // 🔧 CORREGIDO: Eliminar solo el favorito, preservar colección
  Future<void> deleteFavorite(int gameId) async {
    try {
      final db = await database;
      
      // Obtener juego para verificar si tiene colección
      final game = await getGameById(gameId);
      
      if (game != null) {
        if (game.collectionType != null) {
          // Si tiene colección, solo quitar favorito
          await db.update(
            'games',
            {
              'isFavorite': 0,
              'updatedAt': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [gameId],
          );
          print('✅ Removed favorite flag (kept in collection "${game.collectionType}")');
        } else {
          // Si no tiene colección, eliminar completamente
          await db.delete(
            'games',
            where: 'id = ?',
            whereArgs: [gameId],
          );
          print('✅ Removed from favorites and database');
        }
      }
    } catch (e) {
      print('❌ Error removing favorite: $e');
      rethrow;
    }
  }

  // 🔧 CORREGIDO: Eliminar de colección, preservar favorito
  Future<void> removeFromCollection(int gameId) async {
    try {
      final db = await database;
      
      // Obtener juego para verificar si es favorito
      final game = await getGameById(gameId);
      
      if (game != null) {
        if (game.isFavorite) {
          // Si es favorito, solo quitar colección
          await db.update(
            'games',
            {
              'collectionType': null,
              'updatedAt': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [gameId],
          );
          print('✅ Removed from collection (kept as favorite)');
        } else {
          // Si no es favorito, eliminar completamente
          await db.delete(
            'games',
            where: 'id = ?',
            whereArgs: [gameId],
          );
          print('✅ Removed from collection and database');
        }
      }
    } catch (e) {
      print('❌ Error removing from collection: $e');
      rethrow;
    }
  }

  // 🔧 NUEVO: Eliminar completamente un juego
  Future<void> deleteGame(int gameId) async {
    try {
      final db = await database;
      await db.delete(
        'games',
        where: 'id = ?',
        whereArgs: [gameId],
      );
      print('✅ Game deleted completely: $gameId');
    } catch (e) {
      print('❌ Error deleting game: $e');
      rethrow;
    }
  }

  // Get game by ID
  Future<Game?> getGameById(int gameId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'games',
        where: 'id = ?',
        whereArgs: [gameId],
      );

      if (maps.isEmpty) {
        print('⚠️ Game not found in DB: $gameId');
        return null;
      }

      final game = _gameFromMap(maps.first);
      print('✅ Retrieved game: ${game.name} (Favorite: ${game.isFavorite}, Collection: ${game.collectionType})');
      return game;
    } catch (e) {
      print('❌ Error getting game by ID: $e');
      return null;
    }
  }

  // Get all games
  Future<List<Game>> getAllGames() async {
    try {
      final db = await database;
      final maps = await db.query('games', orderBy: 'updatedAt DESC');
      return maps.map((map) => _gameFromMap(map)).toList();
    } catch (e) {
      print('❌ Error getting all games: $e');
      return [];
    }
  }

  // Get favorite games
  Future<List<Game>> getFavoriteGames() async {
    try {
      final db = await database;
      final maps = await db.query(
        'games',
        where: 'isFavorite = ?',
        whereArgs: [1],
        orderBy: 'updatedAt DESC',
      );
      
      final favorites = maps.map((map) => _gameFromMap(map)).toList();
      print('✅ Retrieved ${favorites.length} favorite games');
      return favorites;
    } catch (e) {
      print('❌ Error getting favorites: $e');
      return [];
    }
  }

  // 🔧 CORREGIDO: Get games by collection (independiente de favoritos)
  Future<List<Game>> getGamesByCollection(String collectionType) async {
    try {
      final db = await database;
      
      // Casos especiales
      if (collectionType == AppConstants.collectionFavorites) {
        return getFavoriteGames();
      }

      final maps = await db.query(
        'games',
        where: 'collectionType = ?',
        whereArgs: [collectionType],
        orderBy: 'updatedAt DESC',
      );
      
      final games = maps.map((map) => _gameFromMap(map)).toList();
      print('✅ Retrieved ${games.length} games from collection "$collectionType"');
      return games;
    } catch (e) {
      print('❌ Error getting games by collection: $e');
      return [];
    }
  }

  // Search history
  Future<void> addSearchQuery(String query) async {
    try {
      final db = await database;
      await db.insert(
        'search_history',
        {
          'query': query,
          'timestamp': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error adding search query: $e');
    }
  }

  Future<List<String>> getSearchHistory({int limit = 10}) async {
    try {
      final db = await database;
      final maps = await db.query(
        'search_history',
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return maps.map((map) => map['query'] as String).toList();
    } catch (e) {
      print('❌ Error getting search history: $e');
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      final db = await database;
      await db.delete('search_history');
      print('✅ Search history cleared');
    } catch (e) {
      print('❌ Error clearing search history: $e');
    }
  }

  // 🔧 MEJORADO: Conversión de mapa a Game
  Game _gameFromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int,
      name: map['name'] as String,
      backgroundImage: map['backgroundImage'] as String?,
      released: map['released'] as String?,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      metacritic: map['metacritic'] as int?,
      description: map['description'] as String?,
      descriptionRaw: map['descriptionRaw'] as String?,
      isFavorite: (map['isFavorite'] as int?) == 1,
      collectionType: map['collectionType'] as String?,
      addedAt: map['addedAt'] as String?,
      genres: _parseGenres(map['genres'] as String?),
      parentPlatforms: _parsePlatforms(map['platforms'] as String?),
      shortScreenshots: _parseScreenshots(map['screenshots'] as String?),
    );
  }

  List<Genre>? _parseGenres(String? genresString) {
    if (genresString == null || genresString.isEmpty) return null;
    return genresString
        .split(',')
        .where((g) => g.isNotEmpty)
        .map((name) => Genre(id: 0, name: name, slug: '', gamesCount: 0, imageBackground: ''))
        .toList();
  }

  List<ParentPlatform>? _parsePlatforms(String? platformsString) {
    if (platformsString == null || platformsString.isEmpty) return null;
    return platformsString
        .split(',')
        .where((p) => p.isNotEmpty)
        .map((name) => ParentPlatform(platform: PlatformInfo(id: 0, name: name, slug: '')))
        .toList();
  }

  List<Screenshot>? _parseScreenshots(String? screenshotsString) {
    if (screenshotsString == null || screenshotsString.isEmpty) return null;
    return screenshotsString
        .split(',')
        .where((s) => s.isNotEmpty)
        .map((url) => Screenshot(id: 0, image: url))
        .toList();
  }

  // 🔧 NUEVO: Método de diagnóstico
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;
      
      final totalGames = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM games')
      ) ?? 0;
      
      final favoritesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM games WHERE isFavorite = 1')
      ) ?? 0;
      
      final playingCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM games WHERE collectionType = ?', [AppConstants.collectionPlaying])
      ) ?? 0;
      
      final completedCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM games WHERE collectionType = ?', [AppConstants.collectionCompleted])
      ) ?? 0;
      
      final wishlistCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM games WHERE collectionType = ?', [AppConstants.collectionWishlist])
      ) ?? 0;

      final stats = {
        'total_games': totalGames,
        'favorites': favoritesCount,
        'playing': playingCount,
        'completed': completedCount,
        'wishlist': wishlistCount,
      };

      print('📊 Database stats: $stats');
      return stats;
    } catch (e) {
      print('❌ Error getting database stats: $e');
      return {};
    }
  }

  // 🔧 NUEVO: Verificar si un juego es favorito
  Future<bool> isGameFavorite(int gameId) async {
    final game = await getGameById(gameId);
    return game?.isFavorite ?? false;
  }

  // 🔧 NUEVO: Actualizar estado de favorito
  Future<void> updateFavoriteStatus(int gameId, bool isFavorite) async {
    try {
      final db = await database;
      await db.update(
        'games',
        {
          'isFavorite': isFavorite ? 1 : 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [gameId],
      );
      print('✅ Updated favorite status for game $gameId to $isFavorite');
    } catch (e) {
      print('❌ Error updating favorite status: $e');
      rethrow;
    }
  }

  // 🔧 NUEVO: Actualizar tipo de colección
  Future<void> updateCollectionType(int gameId, String? collectionType) async {
    try {
      final db = await database;
      await db.update(
        'games',
        {
          'collectionType': collectionType,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [gameId],
      );
      print('✅ Updated collection type for game $gameId to $collectionType');
    } catch (e) {
      print('❌ Error updating collection type: $e');
      rethrow;
    }
  }

  // 🔧 NUEVO: Obtener conteo de juegos
  Future<int> getGamesCount() async {
    final stats = await getDatabaseStats();
    return stats['total_games'] as int? ?? 0;
  }

  // 🔧 NUEVO: Limpiar todos los datos
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('games');
      await db.delete('search_history');
      print('✅ Cleared all data');
    } catch (e) {
      print('❌ Error clearing all data: $e');
      rethrow;
    }
  }

  // 🔧 NUEVO: Alias para getSearchHistory
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    return await getSearchHistory(limit: limit);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    print('✅ Database closed');
  }

  // 🔧 NUEVO: Reset database (útil para testing)
  Future<void> resetDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'gamespace.db');
      await deleteDatabase(path);
      _database = null;
      print('✅ Database reset successfully');
    } catch (e) {
      print('❌ Error resetting database: $e');
      rethrow;
    }
  }
}