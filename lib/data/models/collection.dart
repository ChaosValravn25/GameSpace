import 'game.dart';

/// Modelo para gestionar colecciones de juegos
class GameCollection {
  final String id;
  final String name;
  final String type; // favorites, playing, completed, wishlist
  final List<Game> games;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GameCollection({
    required this.id,
    required this.name,
    required this.type,
    required this.games,
    required this.createdAt,
    this.updatedAt,
  });

  // Tipos de colección predefinidos
  static const String favorites = 'favorites';
  static const String playing = 'playing';
  static const String completed = 'completed';
  static const String wishlist = 'wishlist';

  int get gamesCount => games.length;

  bool contains(int gameId) {
    return games.any((game) => game.id == gameId);
  }

  GameCollection addGame(Game game) {
    final updatedGames = List<Game>.from(games)..add(game);
    return copyWith(
      games: updatedGames,
      updatedAt: DateTime.now(),
    );
  }

  GameCollection removeGame(int gameId) {
    final updatedGames = games.where((game) => game.id != gameId).toList();
    return copyWith(
      games: updatedGames,
      updatedAt: DateTime.now(),
    );
  }

  GameCollection copyWith({
    String? id,
    String? name,
    String? type,
    List<Game>? games,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      games: games ?? this.games,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'games': games.map((game) => game.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory GameCollection.fromJson(Map<String, dynamic> json) {
    return GameCollection(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      games: (json['games'] as List)
          .map((gameJson) => Game.fromJson(gameJson))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Factory methods para colecciones predefinidas
  factory GameCollection.favoritesCollection() {
    return GameCollection(
      id: favorites,
      name: 'Favoritos',
      type: favorites,
      games: [],
      createdAt: DateTime.now(),
    );
  }

  factory GameCollection.playingCollection() {
    return GameCollection(
      id: playing,
      name: 'Jugando',
      type: playing,
      games: [],
      createdAt: DateTime.now(),
    );
  }

  factory GameCollection.completedCollection() {
    return GameCollection(
      id: completed,
      name: 'Completados',
      type: completed,
      games: [],
      createdAt: DateTime.now(),
    );
  }

  factory GameCollection.wishlistCollection() {
    return GameCollection(
      id: wishlist,
      name: 'Lista de Deseos',
      type: wishlist,
      games: [],
      createdAt: DateTime.now(),
    );
  }
}

/// Modelo para estadísticas de colección
class CollectionStats {
  final int totalGames;
  final int favoritesCount;
  final int playingCount;
  final int completedCount;
  final int wishlistCount;
  final double averageRating;
  final int totalPlaytime;

  CollectionStats({
    required this.totalGames,
    required this.favoritesCount,
    required this.playingCount,
    required this.completedCount,
    required this.wishlistCount,
    required this.averageRating,
    required this.totalPlaytime,
  });

  factory CollectionStats.empty() {
    return CollectionStats(
      totalGames: 0,
      favoritesCount: 0,
      playingCount: 0,
      completedCount: 0,
      wishlistCount: 0,
      averageRating: 0.0,
      totalPlaytime: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_games': totalGames,
      'favorites_count': favoritesCount,
      'playing_count': playingCount,
      'completed_count': completedCount,
      'wishlist_count': wishlistCount,
      'average_rating': averageRating,
      'total_playtime': totalPlaytime,
    };
  }
}