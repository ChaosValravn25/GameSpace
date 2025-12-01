import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gamespace/l10n/app_localizations.dart';

import 'config/theme.dart';
import 'config/app_routes.dart';
import 'core/network/Api_Service.dart';
import 'core/network/Connectivity_Service.dart';
import 'data/local/Database_Helper.dart';
import 'data/repositories/game_repository.dart';
import 'data/repositories/collection_repository.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
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
      gameRepository: gameRepository,
      collectionRepository: collectionRepository,
    ),
  );
}

class GameSpaceApp extends StatelessWidget {
  final GameRepository gameRepository;
  final CollectionRepository collectionRepository;

  const GameSpaceApp({
    super.key,
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
            apiService: gameRepository._apiService,
            dbHelper: gameRepository._dbHelper,
            connectivityService: gameRepository._connectivityService,
          ),
        ),
        // Providers adicionales pueden agregarse aquí
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

// Extension para acceder a los repositorios desde cualquier parte
extension GameRepositoryExtension on GameRepository {
  ApiService get _apiService {
    // Esto es un hack temporal, idealmente los repositorios deberían
    // ser inmutables y accesibles directamente
    return ApiService();
  }
  
  DatabaseHelper get _dbHelper {
    return DatabaseHelper.instance;
  }
  
  ConnectivityService get _connectivityService {
    return ConnectivityService();
  }
}