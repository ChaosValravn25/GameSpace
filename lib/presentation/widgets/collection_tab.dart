import 'package:flutter/material.dart';

import '../../data/models/game.dart';
import 'game_grid.dart';

/// Widget para un tab de colección con estado vacío personalizado
class CollectionTab extends StatelessWidget {
  final String collectionType;
  final List<Game> games;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final VoidCallback? onExplore;
  final bool isGridView;

  const CollectionTab({
    super.key,
    required this.collectionType,
    required this.games,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onExplore,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && games.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && games.isEmpty) {
      return _buildErrorState(context);
    }

    if (games.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        }
      },
      child: GameGrid(
        games: games,
        isGridView: isGridView,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final emptyStateData = _getEmptyStateData();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyStateData['icon'] as IconData,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyStateData['title'] as String,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              emptyStateData['message'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.explore),
              label: const Text('Explorar Juegos'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Ha ocurrido un error inesperado',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getEmptyStateData() {
    switch (collectionType) {
      case 'favorites':
        return {
          'icon': Icons.favorite_border,
          'title': 'Sin Favoritos',
          'message':
              'Agrega juegos a tus favoritos para verlos aquí\nMarca tus juegos preferidos desde la búsqueda',
        };
      case 'playing':
        return {
          'icon': Icons.play_circle_outline,
          'title': 'No estás jugando nada',
          'message':
              'Marca los juegos que estás jugando actualmente\nPodras hacer seguimiento de tu progreso',
        };
      case 'completed':
        return {
          'icon': Icons.check_circle_outline,
          'title': 'Sin juegos completados',
          'message':
              'Marca los juegos que ya completaste\nCrea tu historial de juegos terminados',
        };
      case 'wishlist':
        return {
          'icon': Icons.bookmark_border,
          'title': 'Wishlist vacía',
          'message':
              'Agrega juegos que quieres jugar en el futuro\nNunca olvides un juego que te interesa',
        };
      default:
        return {
          'icon': Icons.collections_bookmark_outlined,
          'title': 'Colección vacía',
          'message': 'Agrega juegos desde la búsqueda',
        };
    }
  }
}

/// Widget de estadísticas de colección
class CollectionStats extends StatelessWidget {
  final int totalGames;
  final int favoritesCount;
  final int playingCount;
  final int completedCount;
  final int wishlistCount;

  const CollectionStats({
    super.key,
    required this.totalGames,
    required this.favoritesCount,
    required this.playingCount,
    required this.completedCount,
    required this.wishlistCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                Icons.videogame_asset,
                totalGames,
                'Total',
              ),
              _buildStatItem(
                context,
                Icons.favorite,
                favoritesCount,
                'Favoritos',
              ),
              _buildStatItem(
                context,
                Icons.play_circle,
                playingCount,
                'Jugando',
              ),
              _buildStatItem(
                context,
                Icons.check_circle,
                completedCount,
                'Completados',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    int count,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}