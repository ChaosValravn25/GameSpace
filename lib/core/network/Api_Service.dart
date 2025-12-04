import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/Api_Constants.dart';
import '../../data/models/game.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // 🔧 LÍNEAS 12-60 MODIFICADAS
  // GET Games with filters
  Future<GamesResponse> getGames({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? genres,
    String? platforms,
    String? ordering,
    // 🆕 LÍNEA 23: Agregados parámetros opcionales para listas
    List<int>? genresList,
    List<int>? platformsList,
  }) async {
    try {
      // 🔧 LÍNEAS 28-35 REEMPLAZADAS: Query params simplificados
      final queryParams = <String, String>{
        'key': ApiConstants.apiKey,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      // 🔧 LÍNEAS 37-51 NUEVAS: Lógica correcta de filtros
      // Search
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Ordering
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }

      // Genres - Acepta tanto String como List<int>
      if (genres != null && genres.isNotEmpty) {
        queryParams['genres'] = genres;
      } else if (genresList != null && genresList.isNotEmpty) {
        queryParams['genres'] = genresList.join(',');
      }

      // Platforms - Acepta tanto String como List<int>
      if (platforms != null && platforms.isNotEmpty) {
        queryParams['platforms'] = platforms;
      } else if (platformsList != null && platformsList.isNotEmpty) {
        queryParams['platforms'] = platformsList.join(',');
      }

      // 🔧 LÍNEAS 54-60 REEMPLAZADAS: Construcción de URL simplificada
      final url = ApiConstants.buildUrl(
        ApiConstants.gamesEndpoint,
        queryParams: queryParams,
      );

      print('🌐 API Request: $url'); // Debug

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GamesResponse.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to load games: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ API Error: $e'); // Debug
      throw ApiException('Error fetching games: $e');
    }
  }

  // GET Game Detail by ID
  Future<Game> getGameDetail(int gameId) async {
    try {
      final url = ApiConstants.buildUrl(
        '${ApiConstants.gameDetailEndpoint}/$gameId',
      );

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Game.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // 🆕 LÍNEAS 96-98: Manejo específico de 404
        throw ApiException(
          'Game not found',
          404,
        );
      } else {
        throw ApiException(
          'Failed to load game detail: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error fetching game detail: $e');
    }
  }

  // GET Game Screenshots
  Future<List<Screenshot>> getGameScreenshots(int gameId) async {
    try {
      final url = ApiConstants.buildUrl(
        ApiConstants.screenshotsEndpoint.replaceAll('{id}', gameId.toString()),
      );

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List;
        return results.map((json) => Screenshot.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to load screenshots: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error fetching screenshots: $e');
    }
  }

  // GET Genres
  Future<List<Genre>> getGenres() async {
    try {
      final url = ApiConstants.buildUrl(ApiConstants.genresEndpoint);

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List;
        return results.map((json) => Genre.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to load genres: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error fetching genres: $e');
    }
  }

  // GET Platforms
  Future<List<PlatformInfo>> getPlatforms() async {
    try {
      final url = ApiConstants.buildUrl(ApiConstants.platformsEndpoint);

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List;
        return results.map((json) => PlatformInfo.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to load platforms: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error fetching platforms: $e');
    }
  }

  // Search Games
  Future<GamesResponse> searchGames(String query, {int page = 1}) async {
    return getGames(search: query, page: page);
  }

  // Get Popular Games
  Future<GamesResponse> getPopularGames({int page = 1}) async {
    return getGames(ordering: '-rating', page: page);
  }

  // Get Recent Games
  Future<GamesResponse> getRecentGames({int page = 1}) async {
    return getGames(ordering: '-released', page: page);
  }

  // Get Top Rated Games
  Future<GamesResponse> getTopRatedGames({int page = 1}) async {
    return getGames(ordering: '-metacritic', page: page);
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status Code: $statusCode)';
    }
    return 'ApiException: $message';
  }
}