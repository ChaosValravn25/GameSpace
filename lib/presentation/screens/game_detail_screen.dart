import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/game_provider.dart';
import '../../../data/models/game.dart';
import '../../../config/api_constants.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().fetchGameDetail(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error al cargar detalles'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchGameDetail(widget.gameId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final game = provider.selectedGame;
          if (game == null) {
            return const Center(child: Text('Juego no encontrado'));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(game),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(game),
                    _buildActionButtons(game, provider),
                    _buildMetadata(game),
                    _buildDescription(game),
                    _buildGenres(game),
                    _buildPlatforms(game),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Game game) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (game.backgroundImage != null)
              Image.network(
                game.backgroundImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.videogame_asset,
                      size: 80,
                      color: Colors.white54,
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.videogame_asset,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Game game) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (game.rating != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(game.rating!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        game.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (game.metacritic != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getMetacriticColor(game.metacritic!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'MC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        game.metacritic.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Game game, GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                provider.toggleFavorite(game);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      game.isFavorite
                          ? 'Eliminado de favoritos'
                          : 'Agregado a favoritos',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                game.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              label: Text(game.isFavorite ? 'Favorito' : 'Agregar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showCollectionDialog(game, provider);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Colección'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              _shareGame(game);
            },
            icon: const Icon(Icons.share),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(Game game) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (game.released != null)
            _buildMetadataRow(
              Icons.calendar_today,
              'Fecha de Lanzamiento',
              game.released!,
            ),
          if (game.playtime != null)
            _buildMetadataRow(
              Icons.access_time,
              'Tiempo de Juego',
              '${game.playtime} horas',
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const Spacer(),
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

  Widget _buildDescription(Game game) {
    final description = game.descriptionRaw ?? game.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: _isExpanded ? null : 5,
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (description.length > 200)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'Ver menos' : 'Ver más'),
            ),
        ],
      ),
    );
  }

  Widget _buildGenres(Game game) {
    if (game.genres == null || game.genres!.isEmpty) {
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
            children: game.genres!.map((genre) {
              return Chip(
                label: Text(genre.name),
                backgroundColor: Theme.of(context).colorScheme.surface,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatforms(Game game) {
    if (game.parentPlatforms == null || game.parentPlatforms!.isEmpty) {
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
            children: game.parentPlatforms!.map((platform) {
              return Chip(
                label: Text(platform.platform.name),
                avatar: Icon(_getPlatformIcon(platform.platform.slug), size: 16),
                backgroundColor: Theme.of(context).colorScheme.surface,
              );
            }).toList(),
          ),
        ],
      ),
    );
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

  IconData _getPlatformIcon(String slug) {
    if (slug.contains('pc')) return Icons.computer;
    if (slug.contains('playstation')) return Icons.sports_esports;
    if (slug.contains('xbox')) return Icons.videogame_asset;
    if (slug.contains('nintendo')) return Icons.games;
    if (slug.contains('ios') || slug.contains('android')) return Icons.phone_android;
    return Icons.devices;
  }

  void _shareGame(Game game) {
    Share.share(
      '¡Mira este juego! ${game.name}\nRating: ${game.rating ?? "N/A"}/5\n\nDescubre más en GameSpace',
      subject: game.name,
    );
  }

  void _showCollectionDialog(Game game, GameProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar a Colección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Jugando'),
              onTap: () {
                provider.addToCollection(
                  game,
                  AppConstants.collectionPlaying,
                );
                Navigator.pop(context);
                _showSuccessSnackbar('Agregado a Jugando');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Completados'),
              onTap: () {
                provider.addToCollection(
                  game,
                  AppConstants.collectionCompleted,
                );
                Navigator.pop(context);
                _showSuccessSnackbar('Agregado a Completados');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Wishlist'),
              onTap: () {
                provider.addToCollection(
                  game,
                  AppConstants.collectionWishlist,
                );
                Navigator.pop(context);
                _showSuccessSnackbar('Agregado a Wishlist');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}