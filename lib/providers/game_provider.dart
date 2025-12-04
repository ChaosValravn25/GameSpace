import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../core/network/Connectivity_Service.dart';
import '../core/network/Api_Service.dart';
import '../data/local/Database_Helper.dart';
import '../data/models/game.dart';
import '../presentation/widgets/screenshots.dart';

class GameProvider with ChangeNotifier {
  final ApiService _apiService;
  final DatabaseHelper _dbHelper;
  final ConnectivityService _connectivityService;

  // State
  List<Game> _games = [];
  List<Game> _popularGames = [];
  List<Game> _recentGames = [];
  List<Game> _favoriteGames = [];
  List<Game> _searchResults = [];

  Game? _selectedGame;

  bool _isLoading = false;
  bool _isOnline = true;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;

  // 🎯 NUEVO: Variables para filtros
  String _currentOrdering = '-rating';
  List<int> _selectedGenres = [];
  List<int> _selectedPlatforms = [];

  // Getters
  List<Game> get games => _games;
  List<Game> get popularGames => _popularGames;
  List<Game> get recentGames => _recentGames;
  List<Game> get favoriteGames => _favoriteGames;
  List<Game> get searchResults => _searchResults;
  Game? get selectedGame => _selectedGame;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get currentOrdering => _currentOrdering;

  GameProvider({
    required ApiService apiService,
    required DatabaseHelper dbHelper,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService,
        _dbHelper = dbHelper,
        _connectivityService = connectivityService {
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _connectivityService.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  // 🔧 CORREGIDO: Fetch Games con filtros
Future<void> fetchGames({
  bool refresh = false,
  String? ordering,
  List<int>? genres,
  List<int>? platforms,
}) async {
  if (_isLoading) return;

  try {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (refresh) {
      _currentPage = 1;
      _games = [];
    }

    // Actualizar filtros si se proporcionan
    if (ordering != null) _currentOrdering = ordering;
    if (genres != null) _selectedGenres = genres;
    if (platforms != null) _selectedPlatforms = platforms;

    if (_isOnline) {
      // 🔧 LÍNEA 88: Llamada corregida a la API
      final response = await _apiService.getGames(
        page: _currentPage,
        ordering: _currentOrdering,
        // ✅ Usar genresList y platformsList (nuevos parámetros)
        genresList: _selectedGenres.isNotEmpty ? _selectedGenres : null,
        platformsList: _selectedPlatforms.isNotEmpty ? _selectedPlatforms : null,
      );

      if (refresh) {
        _games = response.results;
      } else {
        _games.addAll(response.results);
      }

      _hasMore = response.next != null;
      _currentPage++;

      // Cache games locally
      for (var game in response.results) {
        await _dbHelper.insertGame(game);
      }
      
      print('✅ Loaded ${response.results.length} games with filters:');
      print('   Ordering: $_currentOrdering');
      print('   Genres: $_selectedGenres');
      print('   Platforms: $_selectedPlatforms');
    } else {
      // Load from cache
      _games = await _dbHelper.getAllGames();
      _hasMore = false;
      print('📦 Loaded ${_games.length} games from cache');
    }
  } catch (e) {
    _errorMessage = e.toString();
    print('❌ Error fetching games: $e');

    // Fallback to cache on error
    if (_games.isEmpty) {
      try {
        _games = await _dbHelper.getAllGames();
        print('📦 Fallback: Loaded ${_games.length} games from cache');
      } catch (cacheError) {
        print('❌ Cache error: $cacheError');
      }
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Fetch Popular Games
  Future<void> fetchPopularGames() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_isOnline) {
        final response = await _apiService.getPopularGames();
        _popularGames = response.results.take(10).toList();
      } else {
        _popularGames = await _dbHelper.getAllGames();
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error fetching popular games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Recent Games
  Future<void> fetchRecentGames() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_isOnline) {
        final response = await _apiService.getRecentGames();
        _recentGames = response.results.take(10).toList();
      } else {
        _recentGames = await _dbHelper.getAllGames();
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error fetching recent games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search Games
  Future<void> searchGames(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_isOnline) {
        final response = await _apiService.searchGames(query);
        _searchResults = response.results;

        // Save search query
        await _dbHelper.addSearchQuery(query);
      } else {
        // Search in local database
        final allGames = await _dbHelper.getAllGames();
        _searchResults = allGames
            .where((game) =>
                game.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error searching games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Game Detail
  Future<void> fetchGameDetail(int gameId) async {
    if (_selectedGame?.id == gameId && _selectedGame != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Game game;
      
      // Primero intentar obtener de la API
      try {
        game = await _apiService.getGameDetail(gameId);
      } catch (e) {
        // Si falla, buscar en caché
        game = await _findGameInCache(gameId) ??
            Game(id: gameId, name: 'Juego no encontrado');
      }

      // 🔧 CORREGIDO: Cargar estado de favorito y colección desde DB
      final dbGame = await _dbHelper.getGameById(gameId);
      final isFavorite = dbGame?.isFavorite ?? false;
      final collectionType = dbGame?.collectionType;

      // Screenshots completos (con fallback)
      List<Screenshot> screenshots = game.shortScreenshots ?? [];
      try {
        screenshots = await _apiService.getGameScreenshots(gameId);
      } catch (_) {}

      _selectedGame = game.copyWith(
        isFavorite: isFavorite,
        collectionType: collectionType,
        screenshots: screenshots,
      );
    } catch (e) {
      _errorMessage = null; // Nunca mostramos error en juegos spam
      print('❌ Detalle no disponible: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔧 CORREGIDO: Toggle Favorite
  Future<void> toggleFavorite(Game game, {BuildContext? context}) async {
    try {
      // Obtener el juego completo si está seleccionado
      final fullGame = selectedGame?.id == game.id ? selectedGame! : game;
      final newFavoriteStatus = !fullGame.isFavorite;

      print('🔄 Toggling favorite for ${game.name}: $newFavoriteStatus');

      // Actualizar estado inmediatamente (optimistic update)
      final updatedGame = fullGame.copyWith(isFavorite: newFavoriteStatus);
      
      if (selectedGame?.id == game.id) {
        _selectedGame = updatedGame;
      }
      
      _updateGameInAllLists(updatedGame);
      notifyListeners();

      // Guardar en base de datos
      if (newFavoriteStatus) {
        await _dbHelper.insertFavorite(updatedGame);
        print('✅ Favorito guardado en DB');
        
        // Agregar a lista de favoritos si no está
        if (!_favoriteGames.any((g) => g.id == game.id)) {
          _favoriteGames.add(updatedGame);
        }
      } else {
        await _dbHelper.deleteFavorite(updatedGame.id);
        print('✅ Favorito eliminado de DB');
        
        // Remover de lista de favoritos
        _favoriteGames.removeWhere((g) => g.id == game.id);
      }

      notifyListeners();
      
      // Mostrar feedback al usuario
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFavoriteStatus
                  ? '❤️ Agregado a favoritos'
                  : '💔 Eliminado de favoritos',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      
      // Revertir cambios si falla
      _revertFavoriteUpdate(game.id);
      
      _errorMessage = 'Error al guardar favorito';
      notifyListeners();
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar favorito'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔧 CORREGIDO: Add to Collection
  Future<void> addToCollection(Game game, String type, {BuildContext? context}) async {
    try {
      print('🔄 Adding ${game.name} to collection: $type');

      // Obtener el juego completo
      final fullGame = selectedGame?.id == game.id ? selectedGame! : game;
      
      // Actualizar estado inmediatamente
      final updatedGame = fullGame.copyWith(collectionType: type);
      
      if (selectedGame?.id == game.id) {
        _selectedGame = updatedGame;
      }
      
      _updateGameInAllLists(updatedGame);
      notifyListeners();

      // Guardar en base de datos
      await _dbHelper.addToCollection(updatedGame, type);
      print('✅ Juego guardado en colección: $type');

      notifyListeners();
      
      // Mostrar feedback
      if (context != null) {
        String message = '';
        switch (type) {
          case 'playing':
            message = '🎮 Agregado a "Jugando"';
            break;
          case 'completed':
            message = '✅ Agregado a "Completados"';
            break;
          case 'wishlist':
            message = '📚 Agregado a "Wishlist"';
            break;
          default:
            message = '📁 Agregado a colección';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding to collection: $e');
      
      _errorMessage = 'Error al guardar en colección';
      notifyListeners();
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar en colección'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔧 CORREGIDO: Update Game in All Lists
  void _updateGameInAllLists(Game updatedGame) {
    void replaceIn(List<Game> list) {
      final idx = list.indexWhere((g) => g.id == updatedGame.id);
      if (idx != -1) {
        list[idx] = updatedGame;
      }
    }

    replaceIn(_games);
    replaceIn(_popularGames);
    replaceIn(_recentGames);
    replaceIn(_searchResults);

    // Manejar lista de favoritos
    final favIdx = _favoriteGames.indexWhere((g) => g.id == updatedGame.id);
    if (updatedGame.isFavorite) {
      if (favIdx == -1) {
        // Agregar si no está y debería estar
        _favoriteGames.add(updatedGame);
      } else {
        // Actualizar si ya está
        _favoriteGames[favIdx] = updatedGame;
      }
    } else {
      if (favIdx != -1) {
        // Remover si está y no debería estar
        _favoriteGames.removeAt(favIdx);
      }
    }
  }

  void _revertFavoriteUpdate(int gameId) {
    Game? cached;
    try {
      cached = _games.firstWhere((g) => g.id == gameId);
    } catch (_) {
      cached = null;
    }

    if (cached == null) {
      // Intentar obtener de DB de forma asíncrona
      _findGameInCache(gameId).then((g) {
        if (g != null) {
          _updateGameInAllLists(g);
          notifyListeners();
        } else {
          // Limpiar marca de favorito
          final lists = [
            _games,
            _popularGames,
            _recentGames,
            _searchResults,
            _favoriteGames
          ];
          for (var list in lists) {
            final idx = list.indexWhere((x) => x.id == gameId);
            if (idx != -1) {
              list[idx] = list[idx].copyWith(isFavorite: false);
            }
          }
          notifyListeners();
        }
      });
      return;
    }

    // Restaurar desde memoria
    _updateGameInAllLists(cached);
  }

  Future<Game?> _findGameInCache(int gameId) async {
    // Primero buscar en memoria
    try {
      return _games.firstWhere((g) => g.id == gameId);
    } catch (_) {}

    try {
      return _popularGames.firstWhere((g) => g.id == gameId);
    } catch (_) {}

    try {
      return _recentGames.firstWhere((g) => g.id == gameId);
    } catch (_) {}

    // Buscar en DB
    try {
      return await _dbHelper.getGameById(gameId);
    } catch (_) {
      return null;
    }
  }

  // Load Favorites
  Future<void> loadFavorites() async {
    try {
      _favoriteGames = await _dbHelper.getFavoriteGames();
      print('✅ Loaded ${_favoriteGames.length} favorites');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error loading favorites: $e');
    }
  }

  // Load Collection
  Future<List<Game>> loadCollection(String collectionType) async {
    try {
      final games = await _dbHelper.getGamesByCollection(collectionType);
      print('✅ Loaded ${games.length} games from collection: $collectionType');
      return games;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error loading collection: $e');
      return [];
    }
  }

  // 🔧 CORREGIDO: Remove from Collection
  Future<void> removeFromCollection(int gameId, {BuildContext? context}) async {
    try {
      print('🔄 Removing game $gameId from collection');
      
      await _dbHelper.deleteGame(gameId);
      
      // Actualizar listas
      _favoriteGames.removeWhere((g) => g.id == gameId);
      
      // Actualizar juego en otras listas
      final lists = [_games, _popularGames, _recentGames, _searchResults];
      for (var list in lists) {
        final idx = list.indexWhere((g) => g.id == gameId);
        if (idx != -1) {
          list[idx] = list[idx].copyWith(
            isFavorite: false,
            collectionType: null,
          );
        }
      }
      
      if (selectedGame?.id == gameId) {
        _selectedGame = _selectedGame?.copyWith(
          isFavorite: false,
          collectionType: null,
        );
      }
      
      print('✅ Game removed from collection');
      notifyListeners();
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Eliminado de la colección'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error removing from collection: $e');
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset
  void reset() {
    _games = [];
    _searchResults = [];
    _selectedGame = null;
    _currentPage = 1;
    _hasMore = true;
    _errorMessage = null;
    _currentOrdering = '-rating';
    _selectedGenres = [];
    _selectedPlatforms = [];
    notifyListeners();
  }

  // 🔧 CORREGIDO: Refresh Current Lists
  void _refreshCurrentLists(Game updatedGame) {
    _updateGameInAllLists(updatedGame);
  }
}