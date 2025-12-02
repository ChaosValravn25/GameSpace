import 'package:flutter/material.dart';
import 'package:gamespace/presentation/main_screen.dart';

import '../presentation/screens/home_screen.dart';
import '../presentation/screens/explore_screen.dart';
import '../../presentation/screens/collection_screen.dart';
import '../../presentation/screens/game_detail_screen.dart';
import '../../presentation/screens/preferences_screen.dart';
import '../../presentation/screens/about_screen.dart';

/// Nombres de rutas constantes
class AppRoutes {
  // Rutas principales
  static const String main = '/';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String collection = '/collection';
  static const String preferences = '/preferences';
  
  // Rutas secundarias
  static const String gameDetail = '/game-detail';
  static const String about = '/about';
  
  // Prevenir instanciación
  AppRoutes._();

  /// Mapa de rutas de la aplicación
  static Map<String, WidgetBuilder> get routes {
    return {
      main: (context) => const MainScreen(),
      home: (context) => const HomeScreen(),
      explore: (context) => const ExploreScreen(),
      collection: (context) => const CollectionScreen(),
      preferences: (context) => const PreferencesScreen(),
      about: (context) => const AboutScreen(),
    };
  }

  /// Generador de rutas para rutas con parámetros
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case gameDetail:
        final gameId = settings.arguments as int?;
        if (gameId == null) {
          return _errorRoute('Game ID is required');
        }
        return MaterialPageRoute(
          builder: (context) => GameDetailScreen(gameId: gameId),
          settings: settings,
        );

      default:
        return null;
    }
  }

  /// Ruta de error
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    main,
                    (route) => false,
                  );
                },
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navegación helpers

  /// Navegar a detalle de juego
  static Future<void> toGameDetail(BuildContext context, int gameId) {
    return Navigator.pushNamed(
      context,
      gameDetail,
      arguments: gameId,
    );
  }

  /// Navegar a explorar
  static Future<void> toExplore(BuildContext context) {
    return Navigator.pushNamed(context, explore);
  }

  /// Navegar a colección
  static Future<void> toCollection(BuildContext context) {
    return Navigator.pushNamed(context, collection);
  }

  /// Navegar a preferencias
  static Future<void> toPreferences(BuildContext context) {
    return Navigator.pushNamed(context, preferences);
  }

  /// Navegar a about
  static Future<void> toAbout(BuildContext context) {
    return Navigator.pushNamed(context, about);
  }

  /// Volver a la pantalla principal
  static void toMain(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      main,
      (route) => false,
    );
  }

  /// Pop hasta ruta específica
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(
      context,
      ModalRoute.withName(routeName),
    );
  }
}

/// Extension para facilitar navegación
extension NavigationExtension on BuildContext {
  /// Navegar a una ruta
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }

  /// Navegar y remover todas las rutas anteriores
  Future<T?> pushNamedAndRemoveUntil<T>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      this,
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  /// Reemplazar ruta actual
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      this,
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Volver a la pantalla anterior
  void pop<T>([T? result]) {
    Navigator.pop(this, result);
  }

  /// Verificar si puede volver
  bool canPop() {
    return Navigator.canPop(this);
  }
}