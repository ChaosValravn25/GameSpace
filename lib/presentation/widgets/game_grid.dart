import 'package:flutter/material.dart';

import '../../data/models/game.dart';
import 'game_card.dart';
import '../screens/game_detail_screen.dart';

/// Widget que muestra juegos en Grid o Lista
class GameGrid extends StatelessWidget {
  final List<Game> games;
  final bool isGridView;
  final int crossAxisCount;
  final double childAspectRatio;
  final ScrollController? scrollController;
  final EdgeInsets padding;

  const GameGrid({
    super.key,
    required this.games,
    this.isGridView = true,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.scrollController,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    return isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: scrollController,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameCard(game: games[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: scrollController,
      padding: padding,
      itemCount: games.length,
      itemBuilder: (context, index) {
        return _GameListItem(game: games[index]);
      },
    );
  }
}

/// Widget de item de lista (vista lista)
class _GameListItem extends StatelessWidget {
  final Game game;

  const _GameListItem({required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailScreen(gameId: game.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: game.backgroundImage != null
                    ? Image.network(
                        game.backgroundImage!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
              
              const SizedBox(width: 12),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (game.released != null)
                      Text(
                        game.released!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (game.rating != null) ...[
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            game.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        if (game.metacritic != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getMetacriticColor(game.metacritic!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MC ${game.metacritic}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Icono de acción
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.videogame_asset,
        color: Colors.white54,
      ),
    );
  }

  Color _getMetacriticColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

/// Grid adaptativo que cambia el número de columnas según el ancho
class AdaptiveGameGrid extends StatelessWidget {
  final List<Game> games;
  final bool isGridView;
  final ScrollController? scrollController;

  const AdaptiveGameGrid({
    super.key,
    required this.games,
    this.isGridView = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        }

        return GameGrid(
          games: games,
          isGridView: isGridView,
          crossAxisCount: crossAxisCount,
          scrollController: scrollController,
        );
      },
    );
  }
}