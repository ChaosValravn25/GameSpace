import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gamespace/l10n/app_localizations.dart';


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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider(
            apiService: apiService,
            dbHelper: dbHelper,
            connectivityService: connectivityService,
          ),
        ),
        // Proveer repositorios
        Provider<GameRepository>.value(value: gameRepository),
        Provider<CollectionRepository>.value(value: collectionRepository),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'GameSpace',
            debugShowCheckedModeBanner: false,
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Localization
            locale: localeProvider.locale,
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
            
            // Routing
            initialRoute: AppRoutes.main,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}