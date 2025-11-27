import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  final int id;
  final String name;
  final String? description;
  
  @JsonKey(name: 'description_raw')
  final String? descriptionRaw;
  
  @JsonKey(name: 'background_image')
  final String? backgroundImage;
  
  final double? rating;
  
  @JsonKey(name: 'rating_top')
  final int? ratingTop;
  
  @JsonKey(name: 'ratings_count')
  final int? ratingsCount;
  
  final int? metacritic;
  
  @JsonKey(name: 'playtime')
  final int? playtime;
  
  final List<Genre>? genres;
  
  @JsonKey(name: 'parent_platforms')
  final List<ParentPlatform>? parentPlatforms;
  
  final List<Platform>? platforms;
  
  @JsonKey(name: 'short_screenshots')
  final List<Screenshot>? shortScreenshots;
  
  final String? released;
  
  @JsonKey(name: 'updated')
  final String? updated;
  
  // Campos locales (no de la API)
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isFavorite;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? collectionType;

  Game({
    required this.id,
    required this.name,
    this.description,
    this.descriptionRaw,
    this.backgroundImage,
    this.rating,
    this.ratingTop,
    this.ratingsCount,
    this.metacritic,
    this.playtime,
    this.genres,
    this.parentPlatforms,
    this.platforms,
    this.shortScreenshots,
    this.released,
    this.updated,
    this.isFavorite = false,
    this.collectionType,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);
  
  // Helper para convertir a Map para SQLite
  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'name': name,
      'description': descriptionRaw ?? description,
      'background_image': backgroundImage,
      'rating': rating,
      'metacritic': metacritic,
      'released': released,
      'genres': genres?.map((g) => g.name).join(', '),
      'platforms': parentPlatforms?.map((p) => p.platform.name).join(', '),
      'is_favorite': isFavorite ? 1 : 0,
      'collection_type': collectionType,
    };
  }
  
  // Helper para crear desde SQLite
  factory Game.fromSqliteMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      name: map['name'],
      descriptionRaw: map['description'],
      backgroundImage: map['background_image'],
      rating: map['rating'],
      metacritic: map['metacritic'],
      released: map['released'],
      isFavorite: map['is_favorite'] == 1,
      collectionType: map['collection_type'],
    );
  }
  
  Game copyWith({
    bool? isFavorite,
    String? collectionType,
  }) {
    return Game(
      id: id,
      name: name,
      description: description,
      descriptionRaw: descriptionRaw,
      backgroundImage: backgroundImage,
      rating: rating,
      ratingTop: ratingTop,
      ratingsCount: ratingsCount,
      metacritic: metacritic,
      playtime: playtime,
      genres: genres,
      parentPlatforms: parentPlatforms,
      platforms: platforms,
      shortScreenshots: shortScreenshots,
      released: released,
      updated: updated,
      isFavorite: isFavorite ?? this.isFavorite,
      collectionType: collectionType ?? this.collectionType,
    );
  }
}

@JsonSerializable()
class Genre {
  final int id;
  final String name;
  final String slug;
  
  @JsonKey(name: 'games_count')
  final int? gamesCount;
  
  @JsonKey(name: 'image_background')
  final String? imageBackground;

  Genre({
    required this.id,
    required this.name,
    required this.slug,
    this.gamesCount,
    this.imageBackground,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@JsonSerializable()
class ParentPlatform {
  final PlatformInfo platform;

  ParentPlatform({required this.platform});

  factory ParentPlatform.fromJson(Map<String, dynamic> json) =>
      _$ParentPlatformFromJson(json);
  Map<String, dynamic> toJson() => _$ParentPlatformToJson(this);
}

@JsonSerializable()
class PlatformInfo {
  final int id;
  final String name;
  final String slug;

  PlatformInfo({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory PlatformInfo.fromJson(Map<String, dynamic> json) =>
      _$PlatformInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformInfoToJson(this);
}

@JsonSerializable()
class Platform {
  final PlatformDetail platform;
  
  @JsonKey(name: 'released_at')
  final String? releasedAt;

  Platform({
    required this.platform,
    this.releasedAt,
  });

  factory Platform.fromJson(Map<String, dynamic> json) =>
      _$PlatformFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformToJson(this);
}

@JsonSerializable()
class PlatformDetail {
  final int id;
  final String name;
  final String slug;

  PlatformDetail({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory PlatformDetail.fromJson(Map<String, dynamic> json) =>
      _$PlatformDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformDetailToJson(this);
}

@JsonSerializable()
class Screenshot {
  final int id;
  final String image;

  Screenshot({
    required this.id,
    required this.image,
  });

  factory Screenshot.fromJson(Map<String, dynamic> json) =>
      _$ScreenshotFromJson(json);
  Map<String, dynamic> toJson() => _$ScreenshotToJson(this);
}

@JsonSerializable()
class GamesResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Game> results;

  GamesResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory GamesResponse.fromJson(Map<String, dynamic> json) =>
      _$GamesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GamesResponseToJson(this);
}