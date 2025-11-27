import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'GameSpace'**
  String get appName;

  /// Etiqueta del tab de inicio
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// Etiqueta del tab de explorar
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get explore;

  /// Etiqueta del tab de colección
  ///
  /// In es, this message translates to:
  /// **'Mi Colección'**
  String get collection;

  /// Etiqueta de preferencias
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// Etiqueta de acerca de
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// Hint del campo de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar juegos...'**
  String get search;

  /// No description provided for @popularGames.
  ///
  /// In es, this message translates to:
  /// **'Juegos Populares'**
  String get popularGames;

  /// No description provided for @recentGames.
  ///
  /// In es, this message translates to:
  /// **'Lanzamientos Recientes'**
  String get recentGames;

  /// No description provided for @topRated.
  ///
  /// In es, this message translates to:
  /// **'Mejor Valorados'**
  String get topRated;

  /// No description provided for @favorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @playing.
  ///
  /// In es, this message translates to:
  /// **'Jugando'**
  String get playing;

  /// No description provided for @completed.
  ///
  /// In es, this message translates to:
  /// **'Completados'**
  String get completed;

  /// No description provided for @wishlist.
  ///
  /// In es, this message translates to:
  /// **'Lista de Deseos'**
  String get wishlist;

  /// No description provided for @rating.
  ///
  /// In es, this message translates to:
  /// **'Valoración'**
  String get rating;

  /// No description provided for @metacritic.
  ///
  /// In es, this message translates to:
  /// **'Metacritic'**
  String get metacritic;

  /// No description provided for @releaseDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Lanzamiento'**
  String get releaseDate;

  /// No description provided for @genres.
  ///
  /// In es, this message translates to:
  /// **'Géneros'**
  String get genres;

  /// No description provided for @platforms.
  ///
  /// In es, this message translates to:
  /// **'Plataformas'**
  String get platforms;

  /// No description provided for @playtime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de Juego'**
  String get playtime;

  /// No description provided for @hours.
  ///
  /// In es, this message translates to:
  /// **'horas'**
  String get hours;

  /// No description provided for @addToFavorites.
  ///
  /// In es, this message translates to:
  /// **'Agregar a Favoritos'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In es, this message translates to:
  /// **'Quitar de Favoritos'**
  String get removeFromFavorites;

  /// No description provided for @addToCollection.
  ///
  /// In es, this message translates to:
  /// **'Agregar a Colección'**
  String get addToCollection;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @openWebsite.
  ///
  /// In es, this message translates to:
  /// **'Abrir Sitio Web'**
  String get openWebsite;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @screenshots.
  ///
  /// In es, this message translates to:
  /// **'Capturas de Pantalla'**
  String get screenshots;

  /// No description provided for @noDescription.
  ///
  /// In es, this message translates to:
  /// **'No hay descripción disponible'**
  String get noDescription;

  /// No description provided for @noGames.
  ///
  /// In es, this message translates to:
  /// **'No hay juegos disponibles'**
  String get noGames;

  /// No description provided for @noResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados'**
  String get noResults;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @loadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get loadMore;

  /// No description provided for @refresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get refresh;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @online.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get offline;

  /// No description provided for @offlineMode.
  ///
  /// In es, this message translates to:
  /// **'Modo sin conexión'**
  String get offlineMode;

  /// No description provided for @offlineMessage.
  ///
  /// In es, this message translates to:
  /// **'Estás viendo contenido guardado. Conéctate a internet para actualizar.'**
  String get offlineMessage;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get systemTheme;

  /// No description provided for @clearCache.
  ///
  /// In es, this message translates to:
  /// **'Limpiar Caché'**
  String get clearCache;

  /// No description provided for @clearSearchHistory.
  ///
  /// In es, this message translates to:
  /// **'Limpiar Historial de Búsqueda'**
  String get clearSearchHistory;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @aboutTitle.
  ///
  /// In es, this message translates to:
  /// **'Acerca de GameSpace'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In es, this message translates to:
  /// **'GameSpace es una aplicación para descubrir y gestionar tu colección personal de videojuegos.'**
  String get aboutDescription;

  /// No description provided for @developedBy.
  ///
  /// In es, this message translates to:
  /// **'Desarrollado por'**
  String get developedBy;

  /// No description provided for @poweredBy.
  ///
  /// In es, this message translates to:
  /// **'Powered by RAWG API'**
  String get poweredBy;

  /// No description provided for @filterByGenre.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por Género'**
  String get filterByGenre;

  /// No description provided for @filterByPlatform.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por Plataforma'**
  String get filterByPlatform;

  /// No description provided for @sortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get sortBy;

  /// No description provided for @apply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @emptyCollection.
  ///
  /// In es, this message translates to:
  /// **'Tu colección está vacía'**
  String get emptyCollection;

  /// No description provided for @emptyCollectionMessage.
  ///
  /// In es, this message translates to:
  /// **'Comienza a agregar juegos a tu colección desde la sección Explorar'**
  String get emptyCollectionMessage;

  /// No description provided for @confirmDelete.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar juego?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar este juego de tu colección?'**
  String get confirmDeleteMessage;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre de un juego'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In es, this message translates to:
  /// **'Búsquedas Recientes'**
  String get recentSearches;

  /// No description provided for @errorLoadingGames.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los juegos'**
  String get errorLoadingGames;

  /// No description provided for @errorLoadingDetails.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los detalles del juego'**
  String get errorLoadingDetails;

  /// No description provided for @errorNoConnection.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión a internet'**
  String get errorNoConnection;

  /// No description provided for @viewMore.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get viewMore;

  /// No description provided for @viewLess.
  ///
  /// In es, this message translates to:
  /// **'Ver menos'**
  String get viewLess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
