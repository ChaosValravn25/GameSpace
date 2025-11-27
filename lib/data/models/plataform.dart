import 'package:json_annotation/json_annotation.dart';

part 'platform.g.dart';

@JsonSerializable()
class PlatformInfo {
  final int id;
  final String name;
  final String slug;
  
  @JsonKey(name: 'games_count')
  final int? gamesCount;
  
  @JsonKey(name: 'image_background')
  final String? imageBackground;
  
  @JsonKey(name: 'year_start')
  final int? yearStart;
  
  @JsonKey(name: 'year_end')
  final int? yearEnd;

  PlatformInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.gamesCount,
    this.imageBackground,
    this.yearStart,
    this.yearEnd,
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
  
  final Requirements? requirements;

  Platform({
    required this.platform,
    this.releasedAt,
    this.requirements,
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
  
  @JsonKey(name: 'image')
  final String? image;
  
  @JsonKey(name: 'year_end')
  final int? yearEnd;
  
  @JsonKey(name: 'year_start')
  final int? yearStart;
  
  @JsonKey(name: 'games_count')
  final int? gamesCount;
  
  @JsonKey(name: 'image_background')
  final String? imageBackground;

  PlatformDetail({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.yearEnd,
    this.yearStart,
    this.gamesCount,
    this.imageBackground,
  });

  factory PlatformDetail.fromJson(Map<String, dynamic> json) =>
      _$PlatformDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformDetailToJson(this);
}

@JsonSerializable()
class Requirements {
  final String? minimum;
  final String? recommended;

  Requirements({
    this.minimum,
    this.recommended,
  });

  factory Requirements.fromJson(Map<String, dynamic> json) =>
      _$RequirementsFromJson(json);
  Map<String, dynamic> toJson() => _$RequirementsToJson(this);
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
class PlatformsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PlatformInfo> results;

  PlatformsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PlatformsResponse.fromJson(Map<String, dynamic> json) =>
      _$PlatformsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformsResponseToJson(this);
}