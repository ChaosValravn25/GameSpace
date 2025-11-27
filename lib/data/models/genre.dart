import 'package:json_annotation/json_annotation.dart';

part 'genre.g.dart';

@JsonSerializable()
class Genre {
  final int id;
  final String name;
  final String slug;
  
  @JsonKey(name: 'games_count')
  final int? gamesCount;
  
  @JsonKey(name: 'image_background')
  final String? imageBackground;
  
  final String? description;

  Genre({
    required this.id,
    required this.name,
    required this.slug,
    this.gamesCount,
    this.imageBackground,
    this.description,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@JsonSerializable()
class GenresResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Genre> results;

  GenresResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory GenresResponse.fromJson(Map<String, dynamic> json) =>
      _$GenresResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GenresResponseToJson(this);
}