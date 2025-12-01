import 'package:gamespace/data/local/Database_Helper.dart';
import '../models/game.dart';
import '../models/collection.dart';
import '../../config/api_constants.dart';

/// Repositorio para gestionar colecciones de juegos
class CollectionRepository {
  final DatabaseHelper _dbHelper;

  CollectionRepository({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  /// Agregar juego a favoritos
  Future<void> addToFavorites(Game game) async {
    final updatedGame = game.copyWith(isFavorite: true);
    await _dbHelper.insertGame(updatedGame);
    await _dbHelper.updateFavoriteStatus(game.id, true);
  }

  /// Quitar de favoritos
  Future<void> removeFromFavorites(int gameId) async {
    await _dbHelper.updateFavoriteStatus(gameId, false);
  }

  /// Verificar si un juego está en favoritos
  Future<bool> isFavorite(int gameId) async {
    return await _dbHelper.isGameFavorite(gameId);
  }

  /// Obtener todos los favoritos
  Future<List<Game>> getFavorites() async {
    return await _dbHelper.getFavoriteGames();
  }

  /// Toggle favorito
  Future<bool> toggleFavorite(Game game) async {
    final isFavorite = await _dbHelper.isGameFavorite(game.id);

    if (isFavorite) {
      await removeFromFavorites(game.id);
      return false;
    } else {
      await addToFavorites(game);
      return true;
    }
  }

  /// Agregar juego a una colección específica
  Future<void> addToCollection(Game game, String collectionType) async {
    final updatedGame = game.copyWith(collectionType: collectionType);
    await _dbHelper.insertGame(updatedGame);
    await _dbHelper.updateCollectionType(game.id, collectionType);
  }

  /// Remover juego de una colección
  Future<void> removeFromCollection(int gameId) async {
    await _dbHelper.updateCollectionType(gameId, null);
  }

  /// Obtener juegos de una colección específica
  Future<List<Game>> getGamesByCollection(String collectionType) async {
    return await _dbHelper.getGamesByCollection(collectionType);
  }

  /// Obtener juegos que estás jugando
  Future<List<Game>> getPlayingGames() async {
    return await getGamesByCollection(AppConstants.collectionPlaying);
  }

  /// Obtener juegos completados
  Future<List<Game>> getCompletedGames() async {
    return await getGamesByCollection(AppConstants.collectionCompleted);
  }

  /// Obtener wishlist
  Future<List<Game>> getWishlistGames() async {
    return await getGamesByCollection(AppConstants.collectionWishlist);
  }

  /// Mover juego entre colecciones
  Future<void> moveToCollection(int gameId, String newCollectionType) async {
    await _dbHelper.updateCollectionType(gameId, newCollectionType);
  }

  /// Obtener estadísticas de colecciones
  Future<CollectionStats> getCollectionStats() async {
    final allGames = await _dbHelper.getAllGames();
    final favorites = await getFavorites();
    final playing = await getPlayingGames();
    final completed = await getCompletedGames();
    final wishlist = await getWishlistGames();

    // Calcular rating promedio
    double averageRating = 0.0;
    int totalPlaytime = 0;

    if (allGames.isNotEmpty) {
      final gamesWithRating = allGames.where((g) => g.rating != null).toList();
      if (gamesWithRating.isNotEmpty) {
        averageRating = gamesWithRating
                .map((g) => g.rating!)
                .reduce((a, b) => a + b) /
            gamesWithRating.length;
      }

      final gamesWithPlaytime = allGames.where((g) => g.playtime != null).toList();
      if (gamesWithPlaytime.isNotEmpty) {
        totalPlaytime = gamesWithPlaytime
            .map((g) => g.playtime!)
            .reduce((a, b) => a + b);
      }
    }

    return CollectionStats(
      totalGames: allGames.length,
      favoritesCount: favorites.length,
      playingCount: playing.length,
      completedCount: completed.length,
      wishlistCount: wishlist.length,
      averageRating: averageRating,
      totalPlaytime: totalPlaytime,
    );
  }

  /// Obtener todas las colecciones
  Future<Map<String, GameCollection>> getAllCollections() async {
    final favorites = await getFavorites();
    final playing = await getPlayingGames();
    final completed = await getCompletedGames();
    final wishlist = await getWishlistGames();

    return {
      AppConstants.collectionFavorites: GameCollection(
        id: AppConstants.collectionFavorites,
        name: 'Favoritos',
        type: AppConstants.collectionFavorites,
        games: favorites,
        createdAt: DateTime.now(),
      ),
      AppConstants.collectionPlaying: GameCollection(
        id: AppConstants.collectionPlaying,
        name: 'Jugando',
        type: AppConstants.collectionPlaying,
        games: playing,
        createdAt: DateTime.now(),
      ),
      AppConstants.collectionCompleted: GameCollection(
        id: AppConstants.collectionCompleted,
        name: 'Completados',
        type: AppConstants.collectionCompleted,
        games: completed,
        createdAt: DateTime.now(),
      ),
      AppConstants.collectionWishlist: GameCollection(
        id: AppConstants.collectionWishlist,
        name: 'Lista de Deseos',
        type: AppConstants.collectionWishlist,
        games: wishlist,
        createdAt: DateTime.now(),
      ),
    };
  }

  /// Verificar si un juego está en alguna colección
  Future<String?> getGameCollectionType(int gameId) async {
    final game = await _dbHelper.getGameById(gameId);
    return game?.collectionType;
  }

  /// Obtener conteo de juegos en cada colección
  Future<Map<String, int>> getCollectionCounts() async {
    final favorites = await getFavorites();
    final playing = await getPlayingGames();
    final completed = await getCompletedGames();
    final wishlist = await getWishlistGames();

    return {
      AppConstants.collectionFavorites: favorites.length,
      AppConstants.collectionPlaying: playing.length,
      AppConstants.collectionCompleted: completed.length,
      AppConstants.collectionWishlist: wishlist.length,
    };
  }

  /// Marcar juego como completado
  Future<void> markAsCompleted(Game game) async {
    await addToCollection(game, AppConstants.collectionCompleted);
  }

  /// Marcar juego como jugando
  Future<void> markAsPlaying(Game game) async {
    await addToCollection(game, AppConstants.collectionPlaying);
  }

  /// Agregar a wishlist
  Future<void> addToWishlist(Game game) async {
    await addToCollection(game, AppConstants.collectionWishlist);
  }

  /// Verificar si un juego está en una colección específica
  Future<bool> isInCollection(int gameId, String collectionType) async {
    final games = await getGamesByCollection(collectionType);
    return games.any((game) => game.id == gameId);
  }

  /// Eliminar juego completamente (de todas las colecciones)
  Future<void> deleteGame(int gameId) async {
    await _dbHelper.deleteGame(gameId);
  }

  /// Limpiar una colección específica
  Future<void> clearCollection(String collectionType) async {
    final games = await getGamesByCollection(collectionType);
    for (final game in games) {
      await removeFromCollection(game.id);
    }
  }

  /// Limpiar todas las colecciones
  Future<void> clearAllCollections() async {
    await _dbHelper.clearAllData();
  }

  /// Exportar colección como lista de IDs
  Future<List<int>> exportCollection(String collectionType) async {
    final games = await getGamesByCollection(collectionType);
    return games.map((game) => game.id).toList();
  }

  /// Importar colección desde lista de IDs
  /// (Requiere obtener los juegos de la API primero)
  Future<void> importCollection(
    List<int> gameIds,
    String collectionType,
  ) async {
    // TODO: Implementar obtención de juegos desde API por IDs
    // Por ahora, solo actualizar los que ya existen en DB
    for (final gameId in gameIds) {
      final game = await _dbHelper.getGameById(gameId);
      if (game != null) {
        await addToCollection(game, collectionType);
      }
    }
  }

  /// Obtener juegos recientes de una colección
  Future<List<Game>> getRecentGamesFromCollection(
    String collectionType, {
    int limit = 10,
  }) async {
    final games = await getGamesByCollection(collectionType);
    
    // Ordenar por fecha de agregado (asumiendo que el ID más alto es más reciente)
    games.sort((a, b) => b.id.compareTo(a.id));
    
    return games.take(limit).toList();
  }

  /// Buscar en una colección
  Future<List<Game>> searchInCollection(
    String collectionType,
    String query,
  ) async {
    final games = await getGamesByCollection(collectionType);
    
    if (query.isEmpty) {
      return games;
    }

    return games
        .where((game) =>
            game.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Ordenar colección
  Future<List<Game>> sortCollection(
    String collectionType, {
    required String sortBy,
    bool ascending = true,
  }) async {
    final games = await getGamesByCollection(collectionType);

    switch (sortBy) {
      case 'name':
        games.sort((a, b) => ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'rating':
        games.sort((a, b) {
          final ratingA = a.rating ?? 0;
          final ratingB = b.rating ?? 0;
          return ascending
              ? ratingA.compareTo(ratingB)
              : ratingB.compareTo(ratingA);
        });
        break;
      case 'released':
        games.sort((a, b) {
          final dateA = a.released ?? '';
          final dateB = b.released ?? '';
          return ascending
              ? dateA.compareTo(dateB)
              : dateB.compareTo(dateA);
        });
        break;
      default:
        // No ordenar
        break;
    }

    return games;
  }
}