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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'GameSpace'**
  String get appName;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Explore tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Collection tab label
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get collection;

  /// Preferences label
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// About label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search games...'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System Mode'**
  String get systemMode;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @cachedGames.
  ///
  /// In en, this message translates to:
  /// **'Cached games'**
  String get cachedGames;

  /// No description provided for @gamesStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'games stored locally'**
  String get gamesStoredLocally;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @deleteStoredData.
  ///
  /// In en, this message translates to:
  /// **'Delete stored data'**
  String get deleteStoredData;

  /// No description provided for @clearCacheConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all stored data? This includes downloaded games and your local collection.'**
  String get clearCacheConfirmation;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @clearSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Search History'**
  String get clearSearchHistory;

  /// No description provided for @deleteRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Delete recent searches'**
  String get deleteRecentSearches;

  /// No description provided for @clearSearchHistoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete all your recent searches?'**
  String get clearSearchHistoryConfirmation;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared successfully'**
  String get historyCleared;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @versionInformation.
  ///
  /// In en, this message translates to:
  /// **'Version Information'**
  String get versionInformation;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get app;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'Application information'**
  String get appInformation;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve'**
  String get helpUsImprove;

  /// No description provided for @tellUsYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Tell us your experience with GameSpace'**
  String get tellUsYourExperience;

  /// No description provided for @writeYourComments.
  ///
  /// In en, this message translates to:
  /// **'Write your comments here...'**
  String get writeYourComments;

  /// No description provided for @thanksForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksForFeedback;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate app'**
  String get rateApp;

  /// No description provided for @giveUsYourOpinion.
  ///
  /// In en, this message translates to:
  /// **'Give us your opinion in the store'**
  String get giveUsYourOpinion;

  /// No description provided for @rateGameSpace.
  ///
  /// In en, this message translates to:
  /// **'Rate GameSpace'**
  String get rateGameSpace;

  /// No description provided for @doYouLikeGameSpace.
  ///
  /// In en, this message translates to:
  /// **'Do you like GameSpace?'**
  String get doYouLikeGameSpace;

  /// No description provided for @yourOpinionHelpsUs.
  ///
  /// In en, this message translates to:
  /// **'Your opinion helps us improve'**
  String get yourOpinionHelpsUs;

  /// No description provided for @thanksForSupport.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your support!'**
  String get thanksForSupport;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get noInternetMessage;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @noGames.
  ///
  /// In en, this message translates to:
  /// **'No games available'**
  String get noGames;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescription;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @noRecentGames.
  ///
  /// In en, this message translates to:
  /// **'No recent games'**
  String get noRecentGames;

  /// No description provided for @noWishlist.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get noWishlist;

  /// No description provided for @noCollection.
  ///
  /// In en, this message translates to:
  /// **'Your collection is empty'**
  String get noCollection;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get noSearchResults;

  /// No description provided for @noGamesFound.
  ///
  /// In en, this message translates to:
  /// **'No games found'**
  String get noGamesFound;

  /// No description provided for @noGenres.
  ///
  /// In en, this message translates to:
  /// **'No genres available'**
  String get noGenres;

  /// No description provided for @noPlatforms.
  ///
  /// In en, this message translates to:
  /// **'No platforms available'**
  String get noPlatforms;

  /// No description provided for @noScreenshots.
  ///
  /// In en, this message translates to:
  /// **'No screenshots available'**
  String get noScreenshots;

  /// No description provided for @noRatings.
  ///
  /// In en, this message translates to:
  /// **'No ratings available'**
  String get noRatings;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews available'**
  String get noReviews;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No content available'**
  String get noContent;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnection;

  /// No description provided for @noConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re viewing saved content. Connect to the internet to update.'**
  String get noConnectionMessage;

  /// No description provided for @noFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Start adding games to your favorites from the Explore section'**
  String get noFavoritesMessage;

  /// No description provided for @noRecentGamesMessage.
  ///
  /// In en, this message translates to:
  /// **'Play some games to see them here'**
  String get noRecentGamesMessage;

  /// No description provided for @noWishlistMessage.
  ///
  /// In en, this message translates to:
  /// **'Add games to your wishlist from the Explore section'**
  String get noWishlistMessage;

  /// No description provided for @noCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Start adding games to your collection from the Explore section'**
  String get noCollectionMessage;

  /// No description provided for @noSearchResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different game'**
  String get noSearchResultsMessage;

  /// No description provided for @noGamesFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No games match your search criteria'**
  String get noGamesFoundMessage;

  /// No description provided for @noGenresMessage.
  ///
  /// In en, this message translates to:
  /// **'No genres available to filter'**
  String get noGenresMessage;

  /// No description provided for @noPlatformsMessage.
  ///
  /// In en, this message translates to:
  /// **'No platforms available to filter'**
  String get noPlatformsMessage;

  /// No description provided for @noScreenshotsMessage.
  ///
  /// In en, this message translates to:
  /// **'No screenshots available for this game'**
  String get noScreenshotsMessage;

  /// No description provided for @noRatingsMessage.
  ///
  /// In en, this message translates to:
  /// **'No ratings available for this game'**
  String get noRatingsMessage;

  /// No description provided for @noReviewsMessage.
  ///
  /// In en, this message translates to:
  /// **'No reviews available for this game'**
  String get noReviewsMessage;

  /// No description provided for @noCommentsMessage.
  ///
  /// In en, this message translates to:
  /// **'No comments yet, be the first to comment'**
  String get noCommentsMessage;

  /// No description provided for @noDataMessage.
  ///
  /// In en, this message translates to:
  /// **'No data available at the moment'**
  String get noDataMessage;

  /// No description provided for @noContentMessage.
  ///
  /// In en, this message translates to:
  /// **'No content available, check back later'**
  String get noContentMessage;

  /// No description provided for @popularGames.
  ///
  /// In en, this message translates to:
  /// **'Popular Games'**
  String get popularGames;

  /// No description provided for @recentGames.
  ///
  /// In en, this message translates to:
  /// **'Recent Releases'**
  String get recentGames;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @metacritic.
  ///
  /// In en, this message translates to:
  /// **'Metacritic'**
  String get metacritic;

  /// No description provided for @releaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @platforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get platforms;

  /// No description provided for @playtime.
  ///
  /// In en, this message translates to:
  /// **'Playtime'**
  String get playtime;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to Collection'**
  String get addToCollection;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @openWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open Website'**
  String get openWebsite;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @screenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get screenshots;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re viewing saved content. Connect to internet to update.'**
  String get offlineMessage;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About GameSpace'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'GameSpace is an app to discover and manage your personal video game collection.'**
  String get aboutDescription;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by RAWG API'**
  String get poweredBy;

  /// No description provided for @filterByGenre.
  ///
  /// In en, this message translates to:
  /// **'Filter by Genre'**
  String get filterByGenre;

  /// No description provided for @filterByPlatform.
  ///
  /// In en, this message translates to:
  /// **'Filter by Platform'**
  String get filterByPlatform;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @emptyCollection.
  ///
  /// In en, this message translates to:
  /// **'Your collection is empty'**
  String get emptyCollection;

  /// No description provided for @emptyCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Start adding games to your collection from the Explore section'**
  String get emptyCollectionMessage;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete game?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this game from your collection?'**
  String get confirmDeleteMessage;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Type a game name'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @errorLoadingGames.
  ///
  /// In en, this message translates to:
  /// **'Error loading games'**
  String get errorLoadingGames;

  /// No description provided for @errorLoadingDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading game details'**
  String get errorLoadingDetails;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoConnection;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @viewLess.
  ///
  /// In en, this message translates to:
  /// **'View less'**
  String get viewLess;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
