import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gamespace/core/network/Connectivity_Service.dart';
import 'package:gamespace/main.dart';
import 'package:path/path.dart';
import '../data/local/Database_Helper.dart';
import '../core/network/Api_Service.dart';
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

  // Fetch Games
  Future<void> fetchGames({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (refresh) {
        _currentPage = 1;
        _games = [];
      }

      if (_isOnline) {
        final response = await _apiService.getGames(page: _currentPage);
        
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
      } else {
        // Load from cache
        _games = await _dbHelper.getAllGames();
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      
      // Fallback to cache on error
      if (_games.isEmpty) {
        _games = await _dbHelper.getAllGames();
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

    Future<void> fetchGameDetail(int gameId) async {
    if (_selectedGame?.id == gameId && _selectedGame != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Game game;
      try {
        game = await _apiService.getGameDetail(gameId);
      } catch (e) {
        if (e is ApiException && e.statusCode == 404) {
          // Juego spam → usamos datos básicos del listado si los tenemos
          game = await _findGameInCache(gameId) ?? Game(id: gameId, name: 'Juego no encontrado');
        } else {
          rethrow;
        }
      }

      // Preservamos favorito/colección
      final wasFavorite = _selectedGame?.isFavorite ?? false;
      final wasCollection = _selectedGame?.collectionType;

      // Screenshots completos (con fallback)
      List<Screenshot> screenshots = game.shortScreenshots ?? [];
      try {
        screenshots = await _apiService.getGameScreenshots(gameId);
      } catch (_) {}

      _selectedGame = game.copyWith(
        isFavorite: wasFavorite,
        collectionType: wasCollection,
        screenshots: screenshots,
      );
    } catch (e) {
      _errorMessage = null; // Nunca mostramos error en juegos spam
      print('Detalle no disponible: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Toggle Favorite
    Future<void> toggleFavorite(Game game, {BuildContext? context}) async {
    final fullGame = selectedGame?.id == game.id ? selectedGame! : game;
    final newFavoriteStatus = !fullGame.isFavorite;
    final updatedGame = fullGame.copyWith(isFavorite: newFavoriteStatus);

    _selectedGame = updatedGame;
    _refreshCurrentLists(updatedGame);
    notifyListeners();

    try {
      if (newFavoriteStatus) {
        await _dbHelper.insertFavorite(updatedGame);
      } else {
        await _dbHelper.deleteFavorite(updatedGame.id);
      }
    } catch (e) {
      // Revierte si falla SQLite
      _selectedGame = fullGame;
      _refreshCurrentLists(fullGame);
      notifyListeners();
      _errorMessage = 'Error al guardar favorito';
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar favorito')),
        );
      }
    }
  }

  Future<void> addToCollection(Game game, String type) async {
    final fullGame = selectedGame?.id == game.id ? selectedGame! : game;
    final updatedGame = fullGame.copyWith(collectionType: type);

    _selectedGame = updatedGame;
    _refreshCurrentLists(updatedGame);
    notifyListeners();

    await _dbHelper.addToCollection(updatedGame, type);
  }
  void _updateGameInAllLists(Game updatedGame) {
    // Actualiza en populares, recientes, búsqueda, favoritos, etc.
    void _replaceIn(List<Game> list) {
      final idx = list.indexWhere((g) => g.id == updatedGame.id);
      if (idx != -1) {
        list[idx] = updatedGame;
      }
    }

    _replaceIn(_games);
    _replaceIn(_popularGames);
    _replaceIn(_recentGames);
    _replaceIn(_searchResults);

    final favIdx = _favoriteGames.indexWhere((g) => g.id == updatedGame.id);
    if (favIdx != -1) {
      // keep favorites list consistent (if it was already favorite)
      if (updatedGame.isFavorite) {
        _favoriteGames[favIdx] = updatedGame;
      } else {
        _favoriteGames.removeAt(favIdx);
      }
    } else if (updatedGame.isFavorite) {
      _favoriteGames.add(updatedGame);
    }
  }
  void _revertFavoriteUpdate(int gameId) {
    // Intentamos restaurar el estado desde la caché si algo falla.
    // Si no hay datos de caché, simplemente marcamos como no favorito.
    Game? cached;
    try {
      cached = _games.firstWhere((g) => g.id == gameId);
    } catch (_) {
      cached = null;
    }
    if (cached == null) {
      // No estaba en memoria, intenta obtener de la DB de forma asíncrona (fire-and-forget)
      _findGameInCache(gameId).then((g) {
        if (g != null) {
          final updated = g.copyWith(isFavorite: g.isFavorite);
          _updateGameInAllLists(updated);
          notifyListeners();
        } else {
          // Si no existe en caché, limpiamos cualquier marca local
          final lists = [_games, _popularGames, _recentGames, _searchResults, _favoriteGames];
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

    // Si está en memoria, restauramos directamente
    final restored = cached.copyWith(isFavorite: cached.isFavorite);
    _updateGameInAllLists(restored);
    notifyListeners();
  }

  Future<Game?> _findGameInCache(int gameId) async {
    // Primero busca en memoria
    try {
      final mem = _games.firstWhere((g) => g.id == gameId);
      return mem;
    } catch (_) {}

    try {
      final all = await _dbHelper.getAllGames();
      try {
        final fromDb = all.firstWhere((g) => g.id == gameId);
        return fromDb;
      } catch (_) {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  // Load Favorites
  Future<void> loadFavorites() async {
    try {
      _favoriteGames = await _dbHelper.getFavoriteGames();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // Load Collection
  Future<List<Game>> loadCollection(String collectionType) async {
    try {
      return await _dbHelper.getGamesByCollection(collectionType);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // Remove from Collection
  Future<void> removeFromCollection(int gameId) async {
    try {
      await _dbHelper.deleteGame(gameId);
      await loadFavorites();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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
    notifyListeners();
  }
  
  void _refreshCurrentLists(Game updatedGame) {
    void updateList(List<Game> list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == updatedGame.id) {
          list[i] = updatedGame;
          break;
        }
      }
    }

    updateList(_games);
    updateList(_popularGames);
    updateList(_recentGames);
    updateList(_favoriteGames);
    updateList(_searchResults);

    // Si tienes más listas en el futuro (ej. topRatedGames), añádelas aquí
  }
}