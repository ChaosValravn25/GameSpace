class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.rawg.io/api';
  
  // IMPORTANTE: Reemplaza con tu API Key de RAWG.io
  static const String apiKey = 'ca6598e717504ae1a8cc647dc7d443ff';
  
  // Endpoints
  static const String gamesEndpoint = '/games';
  static const String gameDetailEndpoint = '/games';
  static const String genresEndpoint = '/genres';
  static const String platformsEndpoint = '/platforms';
  static const String screenshotsEndpoint = '/games/{id}/screenshots';
  
  // Query Parameters
  static String get apiKeyParam => 'key=$apiKey';
  
  // Pagination
  static const int pageSize = 20;
  
  // Build Full URL
  static String buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    final params = {
      'key': apiKey,
      ...?queryParams,
    };
    return uri.replace(queryParameters: params).toString();
  }
}

class AppConstants {
  // App Info
  static const String appName = 'GameSpace';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Descubre y gestiona tu colección de videojuegos';
  
  // Database
  static const String dbName = 'gamespace.db';
  static const int dbVersion = 3;
  
  // SharedPreferences Keys
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyApiKey = 'api_key';
  
  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  
  // Collection Types
  static const String collectionFavorites = 'favorites';
  static const String collectionPlaying = 'playing';
  static const String collectionCompleted = 'completed';
  static const String collectionWishlist = 'wishlist';
}

class RouteConstants {
  static const String home = '/';
  static const String explore = '/explore';
  static const String collection = '/collection';
  static const String gameDetail = '/game-detail';
  static const String preferences = '/preferences';
  static const String about = '/about';
}