import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../providers/game_provider.dart';
import '../../../data/models/game.dart';
import '../../../config/Api_Constants.dart';

import '../widgets/info_section.dart';              
import '../widgets/screenshots.dart';        
import '../widgets/action_buttons.dart';             

class GameDetailScreen extends StatefulWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _isDescriptionExpanded = false;

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
                  const Text('Error al cargar detalles'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchGameDetail(widget.gameId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final game = provider.selectedGame;
          if (game == null) return const Center(child: Text('Juego no encontrado'));

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildSliverAppBar(game),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildTitleAndRating(game),
                        const SizedBox(height: 24),

                        // 🔧 CORREGIDO: ActionButtons sin SnackBar (el provider ya lo maneja)
                        ActionButtons(
                          game: game,
                          isFavorite: game.isFavorite,
                          onFavoriteToggle: () {
                            provider.toggleFavorite(game, context: context);
                          },
                          onAddToCollection: () => _showCollectionDialog(game, provider),
                        ),

                        const SizedBox(height: 24),

                        _buildDescription(game),

                        InfoSection(game: game),
                        GenresSection(genres: game.genres),
                        PlatformsSection(platforms: game.parentPlatforms),

                        ScreenshotsGallery(
                          screenshots: game.screenshots?.isNotEmpty == true 
                              ? game.screenshots 
                              : game.shortScreenshots,
                          height: 220,
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),

              // 🔧 CORREGIDO: QuickActionButton sin onPressed duplicado
              Positioned(
                bottom: 24,
                right: 24,
                child: QuickActionButton(
                  game: game,
                  isFavorite: game.isFavorite,
                  onPressed: () => provider.toggleFavorite(game, context: context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Game game) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (game.backgroundImage != null)
              CachedNetworkImage(
                imageUrl: game.backgroundImage ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[850]),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[850],
                  child: const Icon(Icons.videogame_asset, size: 80, color: Colors.white54),
                ),
              )
            else
              Container(
                color: Colors.grey[850],
                child: const Icon(Icons.videogame_asset, size: 80, color: Colors.white54),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        GameDetailActions(game: game),
      ],
    );
  }

  Widget _buildTitleAndRating(Game game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              if (game.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getRatingColor(game.rating!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        game.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              if (game.metacritic != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getMetacriticColor(game.metacritic!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MC ${game.metacritic}',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Game game) {
    final description = game.descriptionRaw ?? game.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: _isDescriptionExpanded ? null : 6,
            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          if (description.length > 300)
            TextButton(
              onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
              child: Text(_isDescriptionExpanded ? 'Ver menos' : 'Ver más'),
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

  // 🔧 CORREGIDO: _showCollectionDialog sin SnackBars duplicados
  void _showCollectionDialog(Game game, GameProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar a Colección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Jugando'),
              onTap: () {
                Navigator.pop(context);
                provider.addToCollection(
                  game, 
                  AppConstants.collectionPlaying,
                  context: context
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Completados'),
              onTap: () {
                Navigator.pop(context);
                provider.addToCollection(
                  game, 
                  AppConstants.collectionCompleted,
                  context: context
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Wishlist'),
              onTap: () {
                Navigator.pop(context);
                provider.addToCollection(
                  game, 
                  AppConstants.collectionWishlist,
                  context: context
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar')
          ),
        ],
      ),
    );
  }
}