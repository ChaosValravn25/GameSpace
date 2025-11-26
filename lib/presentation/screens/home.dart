import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamespace/core/network/rawg_service.dart';

/// Pantalla Home con un carrusel de juegos populares desde la API RAWG.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Replace this with a secure config or environment variable.
  static const String _rawgApiKey = 'ca6598e717504ae1a8cc647dc7d443ff';

  final RawgService _rawg = RawgService(apiKey: _rawgApiKey);
  late Future<List<dynamic>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _rawg.fetchGames(apiKey: _rawgApiKey, pageSize: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Games'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _gamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final games = snapshot.data ?? <dynamic>[];
          if (games.isEmpty) {
            return const Center(child: Text('No games found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                CarouselSlider.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index, realIdx) {
                    final game = games[index] as Map<String, dynamic>;
                    final image = game['background_image'] as String?;
                    final name = game['name'] as String? ?? 'Unknown';
                    final released = game['released'] as String? ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (image != null && image.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                                placeholder: (c, s) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (c, s, e) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.broken_image)),
                                ),
                              )
                            else
                              Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.videogame_asset)),
                              ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (released.isNotEmpty)
                                      Text(
                                        released,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 400,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Most popular games from RAWG', style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
