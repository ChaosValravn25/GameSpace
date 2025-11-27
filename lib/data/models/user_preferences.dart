/// Modelo para preferencias del usuario
class UserPreferences {
  final String languageCode;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool offlineModeEnabled;
  final GridViewType gridViewType;
  final SortOrder defaultSortOrder;

  UserPreferences({
    this.languageCode = 'es',
    this.themeMode = ThemeMode.dark,
    this.notificationsEnabled = true,
    this.offlineModeEnabled = true,
    this.gridViewType = GridViewType.grid,
    this.defaultSortOrder = SortOrder.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'language_code': languageCode,
      'theme_mode': themeMode.toString(),
      'notifications_enabled': notificationsEnabled,
      'offline_mode_enabled': offlineModeEnabled,
      'grid_view_type': gridViewType.toString(),
      'default_sort_order': defaultSortOrder.toString(),
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      languageCode: json['language_code'] ?? 'es',
      themeMode: _themeModeFromString(json['theme_mode']),
      notificationsEnabled: json['notifications_enabled'] ?? true,
      offlineModeEnabled: json['offline_mode_enabled'] ?? true,
      gridViewType: _gridViewTypeFromString(json['grid_view_type']),
      defaultSortOrder: _sortOrderFromString(json['default_sort_order']),
    );
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  static GridViewType _gridViewTypeFromString(String? value) {
    switch (value) {
      case 'GridViewType.grid':
        return GridViewType.grid;
      case 'GridViewType.list':
        return GridViewType.list;
      default:
        return GridViewType.grid;
    }
  }

  static SortOrder _sortOrderFromString(String? value) {
    switch (value) {
      case 'SortOrder.rating':
        return SortOrder.rating;
      case 'SortOrder.releaseDate':
        return SortOrder.releaseDate;
      case 'SortOrder.name':
        return SortOrder.name;
      case 'SortOrder.metacritic':
        return SortOrder.metacritic;
      default:
        return SortOrder.rating;
    }
  }

  UserPreferences copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? offlineModeEnabled,
    GridViewType? gridViewType,
    SortOrder? defaultSortOrder,
  }) {
    return UserPreferences(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      offlineModeEnabled: offlineModeEnabled ?? this.offlineModeEnabled,
      gridViewType: gridViewType ?? this.gridViewType,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
    );
  }
}

enum ThemeMode {
  light,
  dark,
  system,
}

enum GridViewType {
  grid,
  list,
}

enum SortOrder {
  rating,
  releaseDate,
  name,
  metacritic,
}

extension SortOrderExtension on SortOrder {
  String get apiValue {
    switch (this) {
      case SortOrder.rating:
        return '-rating';
      case SortOrder.releaseDate:
        return '-released';
      case SortOrder.name:
        return 'name';
      case SortOrder.metacritic:
        return '-metacritic';
    }
  }

  String get displayName {
    switch (this) {
      case SortOrder.rating:
        return 'Valoración';
      case SortOrder.releaseDate:
        return 'Fecha de Lanzamiento';
      case SortOrder.name:
        return 'Nombre';
      case SortOrder.metacritic:
        return 'Metacritic';
    }
  }
}