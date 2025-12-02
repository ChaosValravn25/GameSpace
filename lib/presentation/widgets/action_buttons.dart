import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/game.dart';
import '../../config/Api_Constants.dart';

/// Widget de botones de acción para el detalle del juego
class ActionButtons extends StatelessWidget {
  final Game game;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCollection;

  const ActionButtons({
    super.key,
    required this.game,
    required this.isFavorite,
    this.onFavoriteToggle,
    this.onAddToCollection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Botones principales
          Row(
            children: [
              // Botón de favoritos
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                  ),
                  label: Text(
                    isFavorite ? 'Favorito' : 'Agregar',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isFavorite
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Botón de agregar a colección
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddToCollection,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text(
                    'Colección',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Botones secundarios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionIconButton(
                icon: Icons.share,
                label: 'Compartir',
                onPressed: () => _shareGame(game),
              ),
              if (game.website != null)
                _ActionIconButton(
                  icon: Icons.language,
                  label: 'Web',
                  onPressed: () => _openWebsite(game.website!),
                ),
              _ActionIconButton(
                icon: Icons.info_outline,
                label: 'Info',
                onPressed: () => _showGameInfo(context, game),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareGame(Game game) {
    final text = '''
🎮 ¡Mira este juego!

${game.name}
${game.rating != null ? '⭐ Rating: ${game.rating}/5' : ''}
${game.metacritic != null ? '🎯 Metacritic: ${game.metacritic}' : ''}

Descubre más en GameSpace
    ''';

    Share.share(text, subject: game.name);
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showGameInfo(BuildContext context, Game game) {
    showModalBottomSheet(
      context: context,
      builder: (context) => GameInfoSheet(game: game),
    );
  }
}

/// Botón de acción icono personalizado
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet con información del juego
class GameInfoSheet extends StatelessWidget {
  final Game game;

  const GameInfoSheet({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 28),
              const SizedBox(width: 12),
              Text(
                'Información',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoRow('ID del Juego', game.id.toString()),
          if (game.released != null)
            _InfoRow('Fecha de Lanzamiento', game.released!),
          if (game.updated != null)
            _InfoRow('Última Actualización', game.updated!),
          if (game.ratingsCount != null)
            _InfoRow('Valoraciones', game.ratingsCount.toString()),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Widget de botón flotante de acción rápida
class QuickActionButton extends StatelessWidget {
  final Game game;
  final bool isFavorite;
  final VoidCallback? onPressed;

  const QuickActionButton({
    super.key,
    required this.game,
    required this.isFavorite,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
      ),
      label: Text(
        isFavorite ? 'En Favoritos' : 'Agregar a Favoritos',
      ),
      backgroundColor: isFavorite
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.secondary,
    );
  }
}

/// Widget de barra de acciones para AppBar
class GameDetailActions extends StatelessWidget {
  final Game game;
  final VoidCallback? onShare;
  final VoidCallback? onMoreOptions;

  const GameDetailActions({
    super.key,
    required this.game,
    this.onShare,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: onShare ?? () => _defaultShare(game),
          tooltip: 'Compartir',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'open_web':
                if (game.website != null) {
                  _openWebsite(game.website!);
                }
                break;
              case 'copy_id':
                _copyToClipboard(context, game.id.toString());
                break;
            }
          },
          itemBuilder: (context) => [
            if (game.website != null)
              const PopupMenuItem(
                value: 'open_web',
                child: Row(
                  children: [
                    Icon(Icons.language),
                    SizedBox(width: 12),
                    Text('Abrir sitio web'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'copy_id',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 12),
                  Text('Copiar ID'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _defaultShare(Game game) {
    Share.share(
      '¡Mira ${game.name}! Rating: ${game.rating ?? "N/A"}/5',
      subject: game.name,
    );
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Implementar con Clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copiado')),
    );
  }
}