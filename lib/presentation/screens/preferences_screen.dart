import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../data/local/database_helper.dart';
import '../../../config/api_constants.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
      ),
      body: ListView(
        children: [
          // Sección de Apariencia
          _buildSectionHeader('Apariencia', Icons.palette),
          _buildThemeTile(themeProvider),
          const Divider(),

          // Sección de Idioma
          _buildSectionHeader('Idioma', Icons.language),
          _buildLanguageTile(localeProvider),
          const Divider(),

          // Sección de Datos
          _buildSectionHeader('Datos', Icons.storage),
          _buildCacheInfoTile(),
          _buildClearCacheTile(),
          _buildClearSearchHistoryTile(),
          const Divider(),

          // Sección de Información
          _buildSectionHeader('Información', Icons.info),
          _buildVersionTile(),
          _buildAboutTile(),
          const Divider(),

          // Sección de Soporte
          _buildSectionHeader('Soporte', Icons.help),
          _buildFeedbackTile(),
          _buildRateAppTile(),
          
          const SizedBox(height: 32),
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

  Widget _buildThemeTile(ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
      title: const Text('Tema'),
      subtitle: Text(
        themeProvider.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
      ),
      onTap: () {
        _showThemeDialog(themeProvider);
      },
    );
  }

  Widget _buildLanguageTile(LocaleProvider localeProvider) {
    return ListTile(
      leading: const Icon(Icons.translate),
      title: const Text('Idioma'),
      subtitle: Text(
        localeProvider.locale.languageCode == 'es' ? 'Español' : 'English',
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showLanguageDialog(localeProvider);
      },
    );
  }

  Widget _buildCacheInfoTile() {
    return FutureBuilder<int>(
      future: DatabaseHelper.instance.getGamesCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return ListTile(
          leading: const Icon(Icons.data_usage),
          title: const Text('Juegos en caché'),
          subtitle: Text('$count juegos guardados localmente'),
          trailing: const Icon(Icons.info_outline),
        );
      },
    );
  }

  Widget _buildClearCacheTile() {
    return ListTile(
      leading: const Icon(Icons.delete_sweep),
      title: const Text('Limpiar caché'),
      subtitle: const Text('Eliminar datos guardados'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showClearCacheDialog();
      },
    );
  }

  Widget _buildClearSearchHistoryTile() {
    return ListTile(
      leading: const Icon(Icons.history),
      title: const Text('Limpiar historial de búsqueda'),
      subtitle: const Text('Borrar búsquedas recientes'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showClearSearchHistoryDialog();
      },
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('Versión'),
      subtitle: Text(AppConstants.appVersion),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showVersionDialog();
      },
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Acerca de'),
      subtitle: const Text('Información de la aplicación'),
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

  Widget _buildFeedbackTile() {
    return ListTile(
      leading: const Icon(Icons.feedback),
      title: const Text('Enviar comentarios'),
      subtitle: const Text('Ayúdanos a mejorar'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showFeedbackDialog();
      },
    );
  }

  Widget _buildRateAppTile() {
    return ListTile(
      leading: const Icon(Icons.star),
      title: const Text('Calificar aplicación'),
      subtitle: const Text('Danos tu opinión en la tienda'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showRateAppDialog();
      },
    );
  }

  // Diálogos

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Oscuro'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
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

  void _showLanguageDialog(LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(Locale(value!));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(Locale(value!));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Caché'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todos los datos guardados? '
          'Esto incluye juegos descargados y tu colección local.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearAllData();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Caché eliminado'),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {});
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showClearSearchHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Historial'),
        content: const Text(
          '¿Deseas eliminar todas tus búsquedas recientes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearSearchHistory();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Historial eliminado'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Versión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aplicación: ${AppConstants.appName}'),
            const SizedBox(height: 8),
            Text('Versión: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),
            const Text('Build: 1.0.0+1'),
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
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar Comentarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cuéntanos tu experiencia con GameSpace',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe tus comentarios aquí...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar envío de feedback
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gracias por tus comentarios!'),
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calificar GameSpace'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Te gusta GameSpace?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tu opinión nos ayuda a mejorar',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Row(
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
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Abrir store para calificar
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gracias por tu apoyo!'),
                ),
              );
            },
            child: const Text('Calificar'),
          ),
        ],
      ),
    );
  }
}