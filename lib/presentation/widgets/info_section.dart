import 'package:flutter/material.dart';

import '../../data/models/game.dart';

/// Widget de sección de información del juego
class InfoSection extends StatelessWidget {
  final Game game;

  const InfoSection({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          if (game.released != null)
            _InfoItem(
              icon: Icons.calendar_today,
              label: 'Fecha de Lanzamiento',
              value: _formatDate(game.released!),
            ),
          
          if (game.playtime != null && game.playtime! > 0)
            _InfoItem(
              icon: Icons.access_time,
              label: 'Tiempo de Juego Promedio',
              value: '${game.playtime} horas',
            ),
          
          if (game.rating != null)
            _InfoItem(
              icon: Icons.star,
              label: 'Valoración',
              value: '${game.rating!.toStringAsFixed(1)} / 5.0',
              valueColor: _getRatingColor(game.rating!),
            ),
          
          if (game.ratingsCount != null)
            _InfoItem(
              icon: Icons.people,
              label: 'Número de Valoraciones',
              value: _formatNumber(game.ratingsCount!),
            ),
          
          if (game.metacritic != null)
            _InfoItem(
              icon: Icons.grade,
              label: 'Metacritic Score',
              value: game.metacritic.toString(),
              valueColor: _getMetacriticColor(game.metacritic!),
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  Color _getMetacriticColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

/// Widget de item de información individual
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de géneros del juego
class GenresSection extends StatelessWidget {
  final List<Genre>? genres;

  const GenresSection({super.key, this.genres});

  @override
  Widget build(BuildContext context) {
    if (genres == null || genres!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Géneros',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: genres!.map((genre) {
              return Chip(
                label: Text(genre.name),
                backgroundColor: Theme.of(context).colorScheme.surface,
                avatar: Icon(
                  _getGenreIcon(genre.slug),
                  size: 18,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getGenreIcon(String slug) {
    if (slug.contains('action')) return Icons.flash_on;
    if (slug.contains('adventure')) return Icons.explore;
    if (slug.contains('rpg')) return Icons.auto_stories;
    if (slug.contains('strategy')) return Icons.psychology;
    if (slug.contains('shooter')) return Icons.gps_fixed;
    if (slug.contains('puzzle')) return Icons.extension;
    if (slug.contains('racing')) return Icons.directions_car;
    if (slug.contains('sports')) return Icons.sports_soccer;
    if (slug.contains('simulation')) return Icons.flight;
    if (slug.contains('indie')) return Icons.lightbulb_outline;
    return Icons.videogame_asset;
  }
}

/// Widget de plataformas del juego
class PlatformsSection extends StatelessWidget {
  final List<ParentPlatform>? platforms;

  const PlatformsSection({super.key, this.platforms});

  @override
  Widget build(BuildContext context) {
    if (platforms == null || platforms!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plataformas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: platforms!.map((platform) {
              return Chip(
                label: Text(platform.platform.name),
                avatar: Icon(
                  _getPlatformIcon(platform.platform.slug),
                  size: 18,
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String slug) {
    if (slug.contains('pc')) return Icons.computer;
    if (slug.contains('playstation')) return Icons.sports_esports;
    if (slug.contains('xbox')) return Icons.videogame_asset;
    if (slug.contains('nintendo')) return Icons.games;
    if (slug.contains('ios') || slug.contains('android')) {
      return Icons.phone_android;
    }
    if (slug.contains('mac')) return Icons.laptop_mac;
    if (slug.contains('linux')) return Icons.computer;
    return Icons.devices;
  }
}