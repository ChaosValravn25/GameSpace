import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamespace/l10n/app_localizations.dart'; // 🆕 IMPORT

import '../../../providers/theme_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/game_provider.dart'; // 🆕 IMPORT
import 'package:gamespace/data/local/Database_Helper.dart';
import '../../../config/Api_Constants.dart';
import 'about_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!; // 🆕 i18n

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), // 🔧 LÍNEA 28: Traducible
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 🆕 HEADER CON LOGO
          _buildHeaderWithLogo(context),

          // Sección de Apariencia
          _buildSectionHeader(l10n.appearance, Icons.palette),
          _buildThemeTile(themeProvider, l10n),
          const Divider(),

          // Sección de Idioma
          _buildSectionHeader(l10n.language, Icons.language),
          _buildLanguageTile(localeProvider, l10n),
          const Divider(),

          // Sección de Datos
          _buildSectionHeader(l10n.data, Icons.storage),
          _buildCacheInfoTile(l10n),
          _buildClearCacheTile(l10n),
          _buildClearSearchHistoryTile(l10n),
          const Divider(),

          // Sección de Información
          _buildSectionHeader(l10n.information, Icons.info),
          _buildVersionTile(l10n),
          _buildAboutTile(l10n),
          const Divider(),

          // Sección de Soporte
          _buildSectionHeader(l10n.support, Icons.help),
          _buildFeedbackTile(l10n),
          _buildRateAppTile(l10n),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 🆕 HEADER CON LOGO
  Widget _buildHeaderWithLogo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          // 🎯 TU LOGO AQUÍ
          Hero(
            tag: 'app_logo',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/GAmeSpaceLogo.png', // 🎯 TU LOGO
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback si el logo no existe
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Icon(
                        Icons.gamepad,
                        size: 50,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'v${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  // 🔧 LÍNEA 175: Traducible
  Widget _buildThemeTile(ThemeProvider themeProvider, AppLocalizations l10n) {
    String themeText;
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        themeText = l10n.lightMode;
        break;
      case ThemeMode.dark:
        themeText = l10n.darkMode;
        break;
      case ThemeMode.system:
        themeText = l10n.systemMode;
        break;
    }

    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
      title: Text(l10n.theme),
      subtitle: Text(themeText),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
      ),
      onTap: () {
        _showThemeDialog(themeProvider, l10n);
      },
    );
  }

  // 🔧 LÍNEA 205: Traducible
  Widget _buildLanguageTile(LocaleProvider localeProvider, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.language),
      subtitle: Text(
        localeProvider.locale.languageCode == 'es' ? 'Español' : 'English',
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showLanguageDialog(localeProvider, l10n);
      },
    );
  }

  Widget _buildCacheInfoTile(AppLocalizations l10n) {
    return FutureBuilder<int>(
      future: DatabaseHelper.instance.getGamesCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return ListTile(
          leading: const Icon(Icons.data_usage),
          title: Text(l10n.cachedGames),
          subtitle: Text('$count ${l10n.gamesStoredLocally}'),
          trailing: const Icon(Icons.info_outline),
        );
      },
    );
  }

  Widget _buildClearCacheTile(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.delete_sweep, color: Colors.orange),
      title: Text(l10n.clearCache),
      subtitle: Text(l10n.deleteStoredData),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showClearCacheDialog(l10n);
      },
    );
  }

  Widget _buildClearSearchHistoryTile(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.orange),
      title: Text(l10n.clearSearchHistory),
      subtitle: Text(l10n.deleteRecentSearches),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showClearSearchHistoryDialog(l10n);
      },
    );
  }

  Widget _buildVersionTile(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: Text(l10n.version),
      subtitle: Text(AppConstants.appVersion),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showVersionDialog(l10n);
      },
    );
  }

  Widget _buildAboutTile(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.about),
      subtitle: Text(l10n.appInformation),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AboutScreen(),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackTile(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.feedback, color: Colors.blue),
      title: Text(l10n.sendFeedback),
      subtitle: Text(l10n.helpUsImprove),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showFeedbackDialog(l10n);
      },
    );
  }

  Widget _buildRateAppTile(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.star, color: Colors.amber),
      title: Text(l10n.rateApp),
      subtitle: Text(l10n.giveUsYourOpinion),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showRateAppDialog(l10n);
      },
    );
  }

  // 🔧 DIÁLOGOS TRADUCIBLES

  void _showThemeDialog(ThemeProvider themeProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightMode),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkMode),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemMode),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(LocaleProvider localeProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              subtitle: const Text('Spanish'),
              value: 'es',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(const Locale('es', ''));
                Navigator.pop(context);
                // 🆕 Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.languageChanged),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              subtitle: const Text('Inglés'),
              value: 'en',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(const Locale('en', ''));
                Navigator.pop(context);
                // 🆕 Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.languageChanged),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DatabaseHelper.instance.clearAllData();
                
                // 🆕 Limpiar provider también
                if (mounted) {
                  context.read<GameProvider>().reset();
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.cacheCleared),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  setState(() {}); // Actualizar UI
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showClearSearchHistoryDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearSearchHistory),
        content: Text(l10n.clearSearchHistoryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DatabaseHelper.instance.clearSearchHistory();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.historyCleared),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.versionInformation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🆕 Logo pequeño en el diálogo
            Center(
              child: Image.asset(
                'assets/icons/GAmeSpaceLogo.png',
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.gamepad, size: 60);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('${l10n.app}: ${AppConstants.appName}'),
            const SizedBox(height: 8),
            Text('${l10n.version}: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),
            Text('Build: 1.0.0+1'),
            const SizedBox(height: 16),
            Text(
              AppConstants.appDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(AppLocalizations l10n) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sendFeedback),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.tellUsYourExperience,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.writeYourComments,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar envío de feedback
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.thanksForFeedback),
                ),
              );
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rateGameSpace),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.doYouLikeGameSpace,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.yourOpinionHelpsUs,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 32),
                Icon(Icons.star, color: Colors.amber, size: 32),
                Icon(Icons.star, color: Colors.amber, size: 32),
                Icon(Icons.star, color: Colors.amber, size: 32),
                Icon(Icons.star, color: Colors.amber, size: 32),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.later),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Abrir store para calificar
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.thanksForSupport),
                ),
              );
            },
            child: Text(l10n.rate),
          ),
        ],
      ),
    );
  }
}