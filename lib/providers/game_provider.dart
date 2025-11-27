import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gamespace/core/network/Connectivity_Service.dart';
import 'package:gamespace/data/local/Database_Helper.dart';
import '../core/network/Api_Service.dart';
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

  // Fetch Game Detail
  Future<void> fetchGameDetail(int gameId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_isOnline) {
        _selectedGame = await _apiService.getGameDetail(gameId);
        
        // Check if favorite
        final isFav = await _dbHelper.isGameFavorite(gameId);
        _selectedGame = _selectedGame!.copyWith(isFavorite: isFav);
      } else {
        _selectedGame = await _dbHelper.getGameById(gameId);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _selectedGame = await _dbHelper.getGameById(gameId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(Game game) async {
    try {
      final newStatus = !game.isFavorite;
      
      if (newStatus) {
        await _dbHelper.insertGame(game.copyWith(isFavorite: true));
      } else {
        await _dbHelper.updateFavoriteStatus(game.id, false);
      }
      
      // Update local state
      if (_selectedGame?.id == game.id) {
        _selectedGame = _selectedGame!.copyWith(isFavorite: newStatus);
      }
      
      await loadFavorites();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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

  // Add to Collection
  Future<void> addToCollection(Game game, String collectionType) async {
    try {
      final updatedGame = game.copyWith(collectionType: collectionType);
      await _dbHelper.insertGame(updatedGame);
      
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
}