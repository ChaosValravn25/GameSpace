import 'package:gamespace/core/network/api_service.dart';

/// Servicio específico para la API de RAWG (https://rawg.io/)
class RawgService {
  final ApiService _api;

  RawgService({required String apiKey, String baseUrl = 'https://api.rawg.io/api'})
      : _api = ApiService(
          baseUrl: baseUrl,
          defaultHeaders: {'Accept': 'application/json'},
        );

  /// Obtiene juegos con parámetros opcionales `dates` y `platforms`.
  /// Devuelve la lista `results` tal como la entrega RAWG.
  Future<List<dynamic>> fetchGames({
    required String apiKey,
    String dates = '2019-09-01,2019-09-30',
    String platforms = '18,1,7',
    int pageSize = 20,
    int page = 1,
  }) async {
    final query = {
      'key': apiKey,
      'dates': dates,
      'platforms': platforms,
      'page_size': pageSize.toString(),
      'page': page.toString(),
    };

    final resp = await _api.get<Map<String, dynamic>>('/games',
        queryParameters: query);

    if (resp.containsKey('results') && resp['results'] is List) {
      return resp['results'] as List<dynamic>;
    }
    return <dynamic>[];
  }
}

/*
Usage example (do NOT commit your API key to the repo):

import 'package:gamespace/core/network/rawg_service.dart';

final key = 'ca6598e717504ae1a8cc647dc7d443ff';
final rawg = RawgService(apiKey: key);

void testRawg() async {
  try {
    final games = await rawg.fetchGames(apiKey: key);
    print('Found ${games.length} games');
    print(games.first);
  } catch (e) {
    print('RAWG error: $e');
  }
}

*/
