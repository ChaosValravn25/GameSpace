import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gamespace/l10n/app_localizations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show sqfliteFfiInit, databaseFactoryFfi;
import 'config/theme.dart';
import 'config/app_routes.dart';
import 'core/network/Api_Service.dart';
import 'core/network/Connectivity_Service.dart';
import 'package:gamespace/data/local/Database_Helper.dart';
import 'data/repositories/game_repository.dart';
import 'data/repositories/collection_repository.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
 

  // Inicializar servicios base
  final apiService = ApiService();
  final dbHelper = DatabaseHelper.instance;
  final connectivityService = ConnectivityService();

  // Inicializar repositorios
  final gameRepository = GameRepository(
    apiService: apiService,
    dbHelper: dbHelper,
    connectivityService: connectivityService,
  );

  final collectionRepository = CollectionRepository(
    dbHelper: dbHelper,
  );

 

  runApp(
    GameSpaceApp(
      apiService: apiService,
      dbHelper: dbHelper,
      connectivityService: connectivityService,
      gameRepository: gameRepository,
      collectionRepository: collectionRepository,
    ),
  );
}

class GameSpaceApp extends StatelessWidget {
  final ApiService apiService;
  final DatabaseHelper dbHelper;
  final ConnectivityService connectivityService;
  final GameRepository gameRepository;
  final CollectionRepository collectionRepository;

  const GameSpaceApp({
    super.key,
    required this.apiService,
    required this.dbHelper,
    required this.connectivityService,
    required this.gameRepository,
    required this.collectionRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔧 LÍNEA 71: ThemeProvider primero
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // 🔧 LÍNEA 75: LocaleProvider segundo
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
        // 🔧 LÍNEA 79: GameProvider tercero
        ChangeNotifierProvider(
          create: (_) => GameProvider(
            apiService: apiService,
            dbHelper: dbHelper,
            connectivityService: connectivityService,
          ),
        ),
        // Proveer repositorios (no cambiados)
        Provider<GameRepository>.value(value: gameRepository),
        Provider<CollectionRepository>.value(value: collectionRepository),
      ],
      // 🔧 LÍNEA 91: Consumer2 para escuchar cambios
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'GameSpace',
            debugShowCheckedModeBanner: false,

            // 🔧 LÍNEAS 98-100: Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // 🔧 LÍNEAS 103-113: Localization configuration
            locale: localeProvider.locale, // ← Esto hace que el idioma cambie
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', ''), // Español
              Locale('en', ''), // English
            ],

            // 🔧 LÍNEAS 116-119: Routing (sin cambios)
            initialRoute: AppRoutes.main,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}