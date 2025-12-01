/// Modelo para gestionar búsquedas y filtros
class SearchQuery {
  final String? query;
  final List<int>? genreIds;
  final List<int>? platformIds;
  final String? ordering;
  final int page;
  final int pageSize;

  SearchQuery({
    this.query,
    this.genreIds,
    this.platformIds,
    this.ordering,
    this.page = 1,
    this.pageSize = 20,
  });

  // Ordering options
  static const String orderByRating = '-rating';
  static const String orderByReleased = '-released';
  static const String orderByMetacritic = '-metacritic';
  static const String orderByName = 'name';
  static const String orderByAdded = '-added';

  bool get hasFilters =>
      query != null ||
      (genreIds != null && genreIds!.isNotEmpty) ||
      (platformIds != null && platformIds!.isNotEmpty);

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (query != null && query!.isNotEmpty) {
      params['search'] = query!;
    }

    if (genreIds != null && genreIds!.isNotEmpty) {
      params['genres'] = genreIds!.join(',');
    }

    if (platformIds != null && platformIds!.isNotEmpty) {
      params['platforms'] = platformIds!.join(',');
    }

    if (ordering != null) {
      params['ordering'] = ordering!;
    }

    params['page'] = page.toString();
    params['page_size'] = pageSize.toString();

    return params;
  }

  SearchQuery copyWith({
    String? query,
    List<int>? genreIds,
    List<int>? platformIds,
    String? ordering,
    int? page,
    int? pageSize,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      genreIds: genreIds ?? this.genreIds,
      platformIds: platformIds ?? this.platformIds,
      ordering: ordering ?? this.ordering,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  SearchQuery clearFilters() {
    return SearchQuery(
      query: query,
      page: 1,
      pageSize: pageSize,
    );
  }

  @override
  String toString() {
    return 'SearchQuery(query: $query, genres: $genreIds, platforms: $platformIds, ordering: $ordering, page: $page)';
  }
}

/// Modelo para historial de búsquedas
class SearchHistory {
  final int? id;
  final String query;
  final DateTime timestamp;
  final int resultsCount;

  SearchHistory({
    this.id,
    required this.query,
    required this.timestamp,
    this.resultsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'results_count': resultsCount,
    };
  }

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      id: map['id'],
      query: map['query'],
      timestamp: DateTime.parse(map['timestamp']),
      resultsCount: map['results_count'] ?? 0,
    );
  }
}

/// Modelo para filtros de búsqueda
class SearchFilters {
  final List<int> selectedGenres;
  final List<int> selectedPlatforms;
  final String? ordering;
  final DateRange? releaseDate;
  final RatingRange? rating;

  SearchFilters({
    this.selectedGenres = const [],
    this.selectedPlatforms = const [],
    this.ordering,
    this.releaseDate,
    this.rating,
  });

  bool get hasActiveFilters =>
      selectedGenres.isNotEmpty ||
      selectedPlatforms.isNotEmpty ||
      ordering != null ||
      releaseDate != null ||
      rating != null;

  int get activeFiltersCount {
    int count = 0;
    if (selectedGenres.isNotEmpty) count++;
    if (selectedPlatforms.isNotEmpty) count++;
    if (ordering != null) count++;
    if (releaseDate != null) count++;
    if (rating != null) count++;
    return count;
  }

  SearchFilters copyWith({
    List<int>? selectedGenres,
    List<int>? selectedPlatforms,
    String? ordering,
    DateRange? releaseDate,
    RatingRange? rating,
  }) {
    return SearchFilters(
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
      ordering: ordering ?? this.ordering,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
    );
  }

  SearchFilters clear() {
    return SearchFilters();
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_genres': selectedGenres,
      'selected_platforms': selectedPlatforms,
      'ordering': ordering,
      'release_date': releaseDate?.toJson(),
      'rating': rating?.toJson(),
    };
  }
}

/// Rango de fechas
class DateRange {
  final DateTime? start;
  final DateTime? end;

  DateRange({this.start, this.end});

  bool get isValid => start != null || end != null;

  Map<String, dynamic> toJson() {
    return {
      'start': start?.toIso8601String(),
      'end': end?.toIso8601String(),
    };
  }

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: json['start'] != null ? DateTime.parse(json['start']) : null,
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
    );
  }
}

/// Rango de rating
class RatingRange {
  final double? min;
  final double? max;

  RatingRange({this.min, this.max});

  bool get isValid => min != null || max != null;

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  factory RatingRange.fromJson(Map<String, dynamic> json) {
    return RatingRange(
      min: json['min']?.toDouble(),
      max: json['max']?.toDouble(),
    );
  }
}

/// Resultado de búsqueda con metadata
class SearchResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;
  final String? query;

  SearchResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    this.query,
  });

  int get totalPages => (totalCount / pageSize).ceil();
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}