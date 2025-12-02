import 'package:flutter/material.dart';

import '../../data/models/game.dart';
import 'game_card.dart';

/// Widget de carrusel horizontal para mostrar lista de juegos
class GameCarousel extends StatelessWidget {
  final List<Game> games;
  final String title;
  final IconData? icon;
  final VoidCallback? onSeeAll;
  final double height;
  final double cardWidth;

  const GameCarousel({
    super.key,
    required this.games,
    required this.title,
    this.icon,
    this.onSeeAll,
    this.height = 220,
    this.cardWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        _buildCarousel(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver todo',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < games.length - 1 ? 12 : 0,
            ),
            child: SizedBox(
              width: cardWidth,
              child: GameCard(game: games[index]),
            ),
          );
        },
      ),
    );
  }
}

/// Widget de carrusel con indicador de páginas
class GameCarouselWithIndicator extends StatefulWidget {
  final List<Game> games;
  final double height;
  final Duration autoPlayDuration;

  const GameCarouselWithIndicator({
    super.key,
    required this.games,
    this.height = 200,
    this.autoPlayDuration = const Duration(seconds: 5),
  });

  @override
  State<GameCarouselWithIndicator> createState() =>
      _GameCarouselWithIndicatorState();
}

class _GameCarouselWithIndicatorState
    extends State<GameCarouselWithIndicator> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.games.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GameCard(game: widget.games[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.games.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}