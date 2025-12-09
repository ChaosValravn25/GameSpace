import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gamespace/config/Api_Constants.dart';
import '../core/network/Connectivity_Service.dart';
import '../core/network/Api_Service.dart';
import '../data/local/Database_Helper.dart';
import '../data/models/game.dart';

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
  List<Game> _wishlist = [];
  List<Game> _playing = [];
  List<Game> _completed = [];

  Game? _selectedGame;

  bool _isLoading = false;
  bool _isOnline = true;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;

  String _currentOrdering = '-rating';
  List<int> _selectedGenres = [];
  List<int> _selectedPlatforms = [];

  // 🔒 NUEVO: Control de operaciones en progreso
  bool _isFavoriteOperationInProgress = false;
  bool _isCollectionOperationInProgress = false;

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
  List<Game> get wishlist => _wishlist; 
  List<Game> get playing => _playing;
  List<Game> get completed => _completed;

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

      if (ordering != null) _currentOrdering = ordering;
      if (genres != null) _selectedGenres = genres;
      if (platforms != null) _selectedPlatforms = platforms;

      if (_isOnline) {
        final response = await _apiService.getGames(
          page: _currentPage,
          ordering: _currentOrdering,
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

        for (var game in response.results) {
          await _dbHelper.insertGame(game);
        }
        
        print('✅ Loaded ${response.results.length} games with filters');
      } else {
        _games = await _dbHelper.getAllGames();
        _hasMore = false;
        print('📦 Loaded ${_games.length} games from cache');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error fetching games: $e');

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
        await _dbHelper.addSearchQuery(query);
      } else {
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

  Future<void> fetchGameDetail(int gameId) async {
    if (_selectedGame?.id == gameId && _selectedGame != null) {
      print('✅ Game already loaded: ${_selectedGame!.name}');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Fetching game detail: $gameId');
      Game game;
      
      try {
        game = await _apiService.getGameDetail(gameId);
        print('✅ API fetch successful: ${game.name}');
      } catch (e) {
        print('⚠️ API error: $e');
        final cachedGame = await _findGameInCache(gameId);
        
        if (cachedGame != null) {
          game = cachedGame;
          print('📦 Game loaded from cache: ${game.name}');
        } else {
          print('❌ Game not found in cache');
          game = Game(
            id: gameId,
            name: 'Juego no disponible',
            description: 'No se pudo cargar la información de este juego.',
          );
        }
      }

      // 🔧 CORREGIDO: Usar await para obtener estado de DB
      final dbGame = await _dbHelper.getGameById(gameId);
      final isFavorite = dbGame?.isFavorite ?? false;
      final collectionType = dbGame?.collectionType;

      print('💾 DB state - Favorite: $isFavorite, Collection: $collectionType');

      List<Screenshot> screenshots = game.shortScreenshots ?? [];
      if (_isOnline) {
        try {
          final fullScreenshots = await _apiService.getGameScreenshots(gameId);
          if (fullScreenshots.isNotEmpty) {
            screenshots = fullScreenshots;
            print('✅ Loaded ${screenshots.length} screenshots');
          }
        } catch (e) {
          print('⚠️ Could not load screenshots: $e');
        }
      }

      _selectedGame = game.copyWith(
        isFavorite: isFavorite,
        collectionType: collectionType,
        screenshots: screenshots,
      );
      
      print('✅ Game detail loaded: ${_selectedGame!.name}');
    } catch (e) {
      print('❌ Critical error: $e');
      
      final cachedGame = await _findGameInCache(gameId);
      if (cachedGame != null) {
        _selectedGame = cachedGame;
        print('📦 Loaded from cache as fallback');
      } else {
        _errorMessage = 'No se pudo cargar el juego';
        _selectedGame = Game(
          id: gameId,
          name: 'Error',
          description: 'No se pudo cargar la información.',
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔧 TOTALMENTE REESCRITO: Toggle Favorite con protección contra race conditions
  Future<void> toggleFavorite(Game game, {BuildContext? context}) async {
    // 🔒 Evitar operaciones concurrentes
    if (_isFavoriteOperationInProgress) {
      print('⚠️ Favorite operation already in progress');
      return;
    }

    _isFavoriteOperationInProgress = true;

    try {
      // 1️⃣ Obtener el juego más actualizado
      final currentGame = _selectedGame?.id == game.id 
          ? _selectedGame! 
          : await _getUpdatedGame(game.id) ?? game;

      final currentFavoriteStatus = currentGame.isFavorite;
      final newFavoriteStatus = !currentFavoriteStatus;

      print('🔄 Toggling favorite for ${currentGame.name}');
      print('   Current: $currentFavoriteStatus → New: $newFavoriteStatus');

      // 2️⃣ Crear el juego actualizado
      final updatedGame = currentGame.copyWith(isFavorite: newFavoriteStatus);

      // 3️⃣ Actualizar PRIMERO en la base de datos
      if (newFavoriteStatus) {
        await _dbHelper.insertFavorite(updatedGame);
        print('✅ Saved to favorites in DB');
      } else {
        await _dbHelper.deleteFavorite(updatedGame.id);
        print('✅ Removed from favorites in DB');
      }

      // 4️⃣ Actualizar en memoria DESPUÉS de éxito en DB
      if (_selectedGame?.id == game.id) {
        _selectedGame = updatedGame;
      }
      
      _updateGameInAllLists(updatedGame);

      // 5️⃣ Actualizar lista de favoritos
      if (newFavoriteStatus) {
        if (!_favoriteGames.any((g) => g.id == game.id)) {
          _favoriteGames.add(updatedGame);
        } else {
          final idx = _favoriteGames.indexWhere((g) => g.id == game.id);
          _favoriteGames[idx] = updatedGame;
        }
      } else {
        _favoriteGames.removeWhere((g) => g.id == game.id);
      }

      // 6️⃣ Notificar DESPUÉS de todos los cambios
      notifyListeners();

      // 7️⃣ Mostrar feedback
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFavoriteStatus
                  ? '❤️ Agregado a favoritos'
                  : '💔 Eliminado de favoritos',
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      print('✅ Favorite toggled successfully');
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      _errorMessage = 'Error al guardar favorito';
      
      // 🔄 Recargar estado desde DB
      await _reloadGameState(game.id);
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar favorito'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      _isFavoriteOperationInProgress = false;
      notifyListeners();
    }
  }

  // 🔧 TOTALMENTE REESCRITO: Add to Collection
  Future<void> addToCollection(Game game, String type, {BuildContext? context}) async {
    // 🔒 Evitar operaciones concurrentes
    if (_isCollectionOperationInProgress) {
      print('⚠️ Collection operation already in progress');
      return;
    }

    _isCollectionOperationInProgress = true;

    try {
      print('🔄 Adding ${game.name} to collection: $type');

      // 1️⃣ Obtener el juego más actualizado
      final currentGame = _selectedGame?.id == game.id 
          ? _selectedGame! 
          : await _getUpdatedGame(game.id) ?? game;
      
      // 2️⃣ Crear el juego actualizado
      final updatedGame = currentGame.copyWith(collectionType: type);

      // 3️⃣ Guardar PRIMERO en base de datos
      await _dbHelper.addToCollection(updatedGame, type);
      print('✅ Saved to collection "$type" in DB');

      // 4️⃣ Actualizar en memoria DESPUÉS de éxito en DB
      if (_selectedGame?.id == game.id) {
        _selectedGame = updatedGame;
      }
      
      _updateGameInAllLists(updatedGame);

      // 5️⃣ Actualizar lista de colección específica
      switch (type) {
        case AppConstants.collectionPlaying:
          if (!_playing.any((g) => g.id == game.id)) {
            _playing.add(updatedGame);
          }
          break;
        case AppConstants.collectionCompleted:
          if (!_completed.any((g) => g.id == game.id)) {
            _completed.add(updatedGame);
          }
          break;
        case AppConstants.collectionWishlist:
          if (!_wishlist.any((g) => g.id == game.id)) {
            _wishlist.add(updatedGame);
          }
          break;
      }

      // 6️⃣ Notificar DESPUÉS de todos los cambios
      notifyListeners();

      // 7️⃣ Mostrar feedback
      if (context != null && context.mounted) {
        String message = _getCollectionMessage(type);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      print('✅ Added to collection successfully');
    } catch (e) {
      print('❌ Error adding to collection: $e');
      _errorMessage = 'Error al guardar en colección';
      
      // 🔄 Recargar estado desde DB
      await _reloadGameState(game.id);
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar en colección'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      _isCollectionOperationInProgress = false;
      notifyListeners();
    }
  }

  // 🆕 NUEVO: Obtener juego actualizado desde DB
  Future<Game?> _getUpdatedGame(int gameId) async {
    try {
      final dbGame = await _dbHelper.getGameById(gameId);
      if (dbGame != null) {
        print('✅ Got updated game from DB: ${dbGame.name}');
        return dbGame;
      }
    } catch (e) {
      print('⚠️ Error getting updated game from DB: $e');
    }
    return null;
  }

  // 🆕 NUEVO: Recargar estado del juego desde DB
  Future<void> _reloadGameState(int gameId) async {
    try {
      final dbGame = await _dbHelper.getGameById(gameId);
      if (dbGame != null) {
        if (_selectedGame?.id == gameId) {
          _selectedGame = _selectedGame!.copyWith(
            isFavorite: dbGame.isFavorite,
            collectionType: dbGame.collectionType,
          );
        }
        _updateGameInAllLists(dbGame);
        print('✅ Reloaded game state from DB');
      }
    } catch (e) {
      print('❌ Error reloading game state: $e');
    }
  }

  // 🆕 NUEVO: Obtener mensaje de colección
  String _getCollectionMessage(String type) {
    switch (type) {
      case AppConstants.collectionPlaying:
        return '🎮 Agregado a "Jugando"';
      case AppConstants.collectionCompleted:
        return '✅ Agregado a "Completados"';
      case AppConstants.collectionWishlist:
        return '📚 Agregado a "Wishlist"';
      default:
        return '📁 Agregado a colección';
    }
  }

  // 🔧 MEJORADO: Update Game in All Lists
  void _updateGameInAllLists(Game updatedGame) {
    void updateList(List<Game> list) {
      final idx = list.indexWhere((g) => g.id == updatedGame.id);
      if (idx != -1) {
        list[idx] = updatedGame;
      }
    }

    updateList(_games);
    updateList(_popularGames);
    updateList(_recentGames);
    updateList(_searchResults);
    updateList(_wishlist);
    updateList(_playing);
    updateList(_completed);

    // Manejo especial para favoritos
    final favIdx = _favoriteGames.indexWhere((g) => g.id == updatedGame.id);
    if (updatedGame.isFavorite) {
      if (favIdx == -1) {
        _favoriteGames.add(updatedGame);
      } else {
        _favoriteGames[favIdx] = updatedGame;
      }
    } else {
      if (favIdx != -1) {
        _favoriteGames.removeAt(favIdx);
      }
    }
  }

  Future<Game?> _findGameInCache(int gameId) async {
    print('🔍 Searching game $gameId in cache...');
    
    // Buscar en memoria
    final memoryLists = [_games, _popularGames, _recentGames, _searchResults];
    for (var list in memoryLists) {
      try {
        final game = list.firstWhere((g) => g.id == gameId);
        print('✅ Found in memory: ${game.name}');
        return game;
      } catch (_) {}
    }

    // Buscar en DB
    try {
      final dbGame = await _dbHelper.getGameById(gameId);
      if (dbGame != null) {
        print('✅ Found in database: ${dbGame.name}');
        return dbGame;
      }
    } catch (e) {
      print('⚠️ DB error: $e');
    }

    print('❌ Game $gameId not found in cache');
    return null;
  }

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

  Future<List<Game>> loadCollection(String collectionType) async {
    try {
      final games = await _dbHelper.getGamesByCollection(collectionType);
      print('✅ Loaded ${games.length} games from collection: $collectionType');

      switch(collectionType) {
        case AppConstants.collectionFavorites:
          _favoriteGames = games;
          break;
        case AppConstants.collectionPlaying:
          _playing = games;
          break;
        case AppConstants.collectionCompleted: 
          _completed = games;
          break;
        case AppConstants.collectionWishlist:
          _wishlist = games;
          break;
      }

      notifyListeners();
      return games;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error loading collection: $e');
      return [];
    }
  }

  Future<void> removeFromCollection(int gameId, {BuildContext? context}) async {
    try {
      print('🔄 Removing game $gameId from collection');
      
      await _dbHelper.deleteGame(gameId);
      
      _favoriteGames.removeWhere((g) => g.id == gameId);
      _wishlist.removeWhere((g) => g.id == gameId);
      _playing.removeWhere((g) => g.id == gameId);
      _completed.removeWhere((g) => g.id == gameId);
      
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
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Eliminado de la colección'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Error removing from collection: $e');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al eliminar'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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
    _isFavoriteOperationInProgress = false;
    _isCollectionOperationInProgress = false;
    notifyListeners();
  }
}