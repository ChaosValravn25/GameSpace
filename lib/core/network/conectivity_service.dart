import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gamespace/core/network/api_service.dart';
import 'package:gamespace/core/network/rawg_service.dart';

/// Servicio para comprobar el estado de conectividad de la red.
class ConnectivityService {
	final Connectivity _connectivity = Connectivity();

	/// Stream que notifica cambios en la conectividad.
	/// Se usa `dynamic` para evitar incompatibilidades entre versiones del paquete.
	Stream<dynamic> get onConnectivityChanged => _connectivity.onConnectivityChanged;

	/// Comprueba si hay conexión a la red (no garantiza acceso a internet real).
	Future<bool> get isConnected async {
		final result = await _connectivity.checkConnectivity();
		return result != ConnectivityResult.none;
	}

	/// Método auxiliar para cerrar recursos si es necesario en el futuro.
	void dispose() {
		// Connectivity plugin no requiere dispose, pero dejamos el método
		// por si se añade lógica adicional más adelante.
	}
}

final api = ApiService(baseUrl: 'https://jsonplaceholder.typicode.com');
final key = 'ca6598e717504ae1a8cc647dc7d443ff';
final rawg = RawgService(apiKey: key);

void testApi() async {
  try {
    final posts = await api.get<List<dynamic>>('/posts');
    print('Posts count: ${posts.length}');
  } catch (e) {
    print('API error: $e');
  }
}

void testRawg() async {
  try {
    final games = await rawg.fetchGames(apiKey: key);
    print('Found ${games.length} games');
    if (games.isNotEmpty) print(games[0]);
  } catch (e) {
    print('RAWG error: $e');
  }
}
