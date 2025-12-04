import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/api_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo/Icono de la App
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videogame_asset,
                size: 64,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nombre de la App
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Versión
            Text(
              'Versión ${AppConstants.appVersion}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Descripción
            Text(
              AppConstants.appDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 32),
            
            // Características
            _buildFeatureCard(
              context,
              icon: Icons.search,
              title: 'Búsqueda Avanzada',
              description: 'Explora miles de juegos con filtros potentes',
            ),
            
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              context,
              icon: Icons.collections_bookmark,
              title: 'Tu Colección',
              description: 'Organiza y gestiona tu biblioteca de juegos',
            ),
            
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              context,
              icon: Icons.wifi_off,
              title: 'Modo Offline',
              description: 'Accede a tu contenido sin conexión',
            ),
            
            const SizedBox(height: 32),
            
            // Powered by RAWG
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Powered by',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'RAWG API',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The largest video game database',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      _launchURL('https://rawg.io');
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Visitar RAWG.io'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Desarrolladores
            Text(
              'Desarrollado por',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildDeveloperCard(
              context,
              name: 'Ivonne Santander Soto',
              role: 'Full Stack Developer',
              email: 'isantander19@alumnos.utalca.cl',
            ),
            
            const SizedBox(height: 12),
            
            _buildDeveloperCard(
              context,
              name: 'Vicente Castillo',
              role: 'UI/UX Designer & Developer',
              email: 'vicastillo21@alumnos.utalca.cl',
            ),
            
            const SizedBox(height: 32),
            
            // Información Adicional
            _buildInfoSection(context),
            
            const SizedBox(height: 32),
            
            // Licencias
            OutlinedButton.icon(
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationLegalese: '© 2025 GameSpace Team',
                );
              },
              icon: const Icon(Icons.description),
              label: const Text('Ver Licencias'),
            ),
            
            const SizedBox(height: 16),
            
            // Copyright
            Text(
              '© 2025 GameSpace Team',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Proyecto de Programación de Dispositivos Móviles',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String name,
    required String role,
    required String email,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.email, size: 20),
            onPressed: () {
              _launchURL('mailto:$email');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tecnologías',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: const [
            _TechChip(label: 'Flutter'),
            _TechChip(label: 'Dart'),
            _TechChip(label: 'Provider'),
            _TechChip(label: 'SQLite'),
            _TechChip(label: 'REST API'),
          ],
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _TechChip extends StatelessWidget {
  final String label;

  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}