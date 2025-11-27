import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gamespace/l10n/app_localizations.dart';

import 'config/theme.dart';
import 'core/network/Api_Service.dart';
import 'core/network/Connectivity_Service.dart';
import 'data/local/Database_Helper.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'presentation/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  final apiService = ApiService();
  final dbHelper = DatabaseHelper.instance;
  final connectivityService = ConnectivityService();
  
  runApp(
    GameSpaceApp(
      apiService: apiService,
      dbHelper: dbHelper,
      connectivityService: connectivityService,
    ),
  );
}

class GameSpaceApp extends StatelessWidget {
  final ApiService apiService;
  final DatabaseHelper dbHelper;
  final ConnectivityService connectivityService;

  const GameSpaceApp({
    super.key,
    required this.apiService,
    required this.dbHelper,
    required this.connectivityService,
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
            
            // Home
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}