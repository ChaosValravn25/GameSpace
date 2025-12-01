import '../../core/network/api_service.dart';
import '../../core/network/connectivity_service.dart';
import '../local/database_helper.dart';
import '../models/game.dart';
import '../models/genre.dart' hide Genre;
import '../models/search.dart';

/// Repositorio para gestionar datos de juegos
/// Implementa patrón Repository para abstraer la fuente de datos
class GameRepository {
  final ApiService _apiService;
  final DatabaseHelper _dbHelper;
  final ConnectivityService _connectivityService;

  GameRepository({
    required ApiService apiService,
    required DatabaseHelper dbHelper,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService,
        _dbHelper = dbHelper,
        _connectivityService = connectivityService;

  /// Obtener juegos con búsqueda y filtros
  Future<GamesResponse> getGames({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? genres,
    String? platforms,
    String? ordering,
  }) async {
    try {
      // Verificar conectividad
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        // Obtener desde API
        final response = await _apiService.getGames(
          page: page,
          pageSize: pageSize,
          search: search,
          genres: genres,
          platforms: platforms,
          ordering: ordering,
        );

        // Cachear resultados
        await _cacheGames(response.results);

        return response;
      } else {
        // Obtener desde caché local
        final cachedGames = await _dbHelper.getAllGames();

        // Aplicar filtros localmente si es necesario
        List<Game> filteredGames = cachedGames;

        if (search != null && search.isNotEmpty) {
          filteredGames = filteredGames
              .where((game) =>
                  game.name.toLowerCase().contains(search.toLowerCase()))
              .toList();
        }

        return GamesResponse(
          count: filteredGames.length,
          next: null,
          previous: null,
          results: filteredGames,
        );
      }
    } catch (e) {
      // En caso de error, intentar retornar caché
      final cachedGames = await _dbHelper.getAllGames();
      return GamesResponse(
        count: cachedGames.length,
        next: null,
        previous: null,
        results: cachedGames,
      );
    }
  }

  /// Obtener detalle de un juego
  Future<Game> getGameDetail(int gameId) async {
    try {
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        // Obtener desde API
        final game = await _apiService.getGameDetail(gameId);

        // Verificar si está en favoritos
        final isFavorite = await _dbHelper.isGameFavorite(gameId);
        final gameWithFavorite = game.copyWith(isFavorite: isFavorite);

        // Cachear juego
        await _dbHelper.insertGame(gameWithFavorite);

        return gameWithFavorite;
      } else {
        // Obtener desde caché
        final cachedGame = await _dbHelper.getGameById(gameId);
        if (cachedGame != null) {
          return cachedGame;
        }
        throw Exception('Game not found in cache');
      }
    } catch (e) {
      // Intentar obtener desde caché como fallback
      final cachedGame = await _dbHelper.getGameById(gameId);
      if (cachedGame != null) {
        return cachedGame;
      }
      rethrow;
    }
  }

  /// Buscar juegos
  Future<GamesResponse> searchGames(String query, {int page = 1}) async {
    try {
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        final response = await _apiService.searchGames(query, page: page);

        // Guardar búsqueda en historial
        await _dbHelper.addSearchQuery(query);

        // Cachear resultados
        await _cacheGames(response.results);

        return response;
      } else {
        // Buscar en caché local
        final allGames = await _dbHelper.getAllGames();
        final results = allGames
            .where((game) =>
                game.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return GamesResponse(
          count: results.length,
          next: null,
          previous: null,
          results: results,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener juegos populares
  Future<GamesResponse> getPopularGames({int page = 1}) async {
    return getGames(ordering: '-rating', page: page);
  }

  /// Obtener juegos recientes
  Future<GamesResponse> getRecentGames({int page = 1}) async {
    return getGames(ordering: '-released', page: page);
  }

  /// Obtener juegos mejor valorados
  Future<GamesResponse> getTopRatedGames({int page = 1}) async {
    return getGames(ordering: '-metacritic', page: page);
  }

  /// Obtener géneros
  Future<List<Genre>> getGenres() async {
    try {
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        return await _apiService.getGenres();
      } else {
        // TODO: Implementar caché de géneros en DatabaseHelper
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtener plataformas
  Future<List<PlatformInfo>> getPlatforms() async {
    try {
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        return await _apiService.getPlatforms();
      } else {
        // TODO: Implementar caché de plataformas
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtener screenshots de un juego
  Future<List<Screenshot>> getGameScreenshots(int gameId) async {
    try {
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        return await _apiService.getGameScreenshots(gameId);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtener historial de búsquedas
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    return await _dbHelper.getRecentSearches(limit: limit);
  }

  /// Limpiar historial de búsquedas
  Future<void> clearSearchHistory() async {
    await _dbHelper.clearSearchHistory();
  }

  /// Métodos privados

  /// Cachear lista de juegos
  Future<void> _cacheGames(List<Game> games) async {
    for (final game in games) {
      await _dbHelper.insertGame(game);
    }
  }

  /// Verificar si hay conexión
  Future<bool> hasConnection() async {
    return await _connectivityService.hasConnection();
  }

  /// Obtener estado de conexión
  Future<String> getConnectionStatus() async {
    return await _connectivityService.getConnectionStatus();
  }

  /// Búsqueda avanzada con filtros
  Future<SearchResult<Game>> advancedSearch(SearchQuery query) async {
    try {
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        final response = await _apiService.getGames(
          page: query.page,
          pageSize: query.pageSize,
          search: query.query,
          genres: query.genreIds?.join(','),
          platforms: query.platformIds?.join(','),
          ordering: query.ordering,
        );

        await _cacheGames(response.results);

        return SearchResult(
          items: response.results,
          totalCount: response.count,
          page: query.page,
          pageSize: query.pageSize,
          hasMore: response.next != null,
          query: query.query,
        );
      } else {
        // Búsqueda local
        final allGames = await _dbHelper.getAllGames();
        List<Game> filteredGames = allGames;

        if (query.query != null && query.query!.isNotEmpty) {
          filteredGames = filteredGames
              .where((game) =>
                  game.name.toLowerCase().contains(query.query!.toLowerCase()))
              .toList();
        }

        return SearchResult(
          items: filteredGames,
          totalCount: filteredGames.length,
          page: 1,
          pageSize: filteredGames.length,
          hasMore: false,
          query: query.query,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Refrescar caché
  Future<void> refreshCache() async {
    try {
      final isOnline = await _connectivityService.hasConnection();

      if (isOnline) {
        // Limpiar caché existente
        await _dbHelper.clearAllData();

        // Obtener juegos populares para cachear
        final popularGames = await getPopularGames();
        await _cacheGames(popularGames.results);

        // Obtener juegos recientes
        final recentGames = await getRecentGames();
        await _cacheGames(recentGames.results);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadísticas de caché
  Future<Map<String, int>> getCacheStats() async {
    final totalGames = await _dbHelper.getGamesCount();
    final favorites = await _dbHelper.getFavoriteGames();

    return {
      'total_games': totalGames,
      'favorites': favorites.length,
    };
  }
}