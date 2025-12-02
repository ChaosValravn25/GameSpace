import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/game.dart';

/// Widget de galería de screenshots
class ScreenshotsGallery extends StatelessWidget {
  final List<Screenshot>? screenshots;
  final double height;

  const ScreenshotsGallery({
    super.key,
    this.screenshots,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (screenshots == null || screenshots!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.photo_library, size: 24),
              const SizedBox(width: 8),
              Text(
                'Capturas de Pantalla',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: screenshots!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < screenshots!.length - 1 ? 12 : 0,
                ),
                child: _ScreenshotItem(
                  screenshot: screenshots![index],
                  onTap: () {
                    _showFullScreenGallery(context, index);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFullScreenGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          screenshots: screenshots!,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

/// Widget de item individual de screenshot
class _ScreenshotItem extends StatelessWidget {
  final Screenshot screenshot;
  final VoidCallback? onTap;

  const _ScreenshotItem({
    required this.screenshot,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: screenshot.image,
              width: 300,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 300,
                height: 200,
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 300,
                height: 200,
                color: Colors.grey[800],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.white54,
                ),
              ),
            ),
            // Overlay para indicar que es clickeable
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            // Icono de expandir
            const Positioned(
              bottom: 8,
              right: 8,
              child: Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Galería de pantalla completa
class FullScreenGallery extends StatefulWidget {
  final List<Screenshot> screenshots;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.screenshots,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1} / ${widget.screenshots.length}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.screenshots.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.screenshots[index].image,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Indicadores de navegación
          if (widget.screenshots.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.screenshots.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget compacto de screenshots (para espacios reducidos)
class CompactScreenshots extends StatelessWidget {
  final List<Screenshot>? screenshots;
  final int maxItems;

  const CompactScreenshots({
    super.key,
    this.screenshots,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (screenshots == null || screenshots!.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayScreenshots = screenshots!.take(maxItems).toList();
    final hasMore = screenshots!.length > maxItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Capturas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayScreenshots.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (hasMore && index == displayScreenshots.length) {
                return _buildMoreIndicator(context);
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: displayScreenshots[index].image,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoreIndicator(BuildContext context) {
    final remaining = screenshots!.length - maxItems;
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '+$remaining',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}