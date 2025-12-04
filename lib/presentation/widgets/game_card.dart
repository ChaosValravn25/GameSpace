import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/game.dart';
import '../screens/game_detail_screen.dart';
import 'platform_icon.dart'; // 🎯 NUEVO IMPORT

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetailScreen(gameId: game.id),
              ),
            );
          },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  game.backgroundImage != null
                      ? CachedNetworkImage(
                          imageUrl: game.backgroundImage ?? '',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[850],
                            child: const Center(
                              child: Icon(Icons.videogame_asset, size: 40, color: Colors.white38),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[850],
                            child: const Center(
                              child: Icon(Icons.videogame_asset, size: 40, color: Colors.white38),
                            ),
                          ),

                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.videogame_asset,
                            size: 40,
                            color: Colors.white54,
                          ),
                        ),

                  // Rating Badge
                  if (game.rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              game.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del juego
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // 🎮 NUEVA SECCIÓN: Plataformas y Fecha
                    Row(
                      children: [
                        // 🎯 ICONOS DE PLATAFORMAS
                        if (game.platforms != null &&
                            game.platforms!.isNotEmpty)
                          Flexible(
                            child: PlatformIconRow(
                              platformSlugs: game.platforms!
                                  .map((p) => p.platform.slug ?? '')
                                  .where((slug) => slug.isNotEmpty)
                                  .toList(),
                              iconSize: 14.0,
                              maxIcons: 3,
                              spacing: 4.0,
                              iconColor: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(0.7),
                            ),
                          ),

                        // Espaciador
                        if (game.platforms != null &&
                            game.platforms!.isNotEmpty &&
                            game.released != null)
                          const SizedBox(width: 8),

                        // Fecha de lanzamiento
                        if (game.released != null)
                          Flexible(
                            child: Text(
                              game.released!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}