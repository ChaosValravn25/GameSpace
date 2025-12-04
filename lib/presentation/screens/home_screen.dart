import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamespace/l10n/app_localizations.dart';

import '../../../providers/game_provider.dart';
import '../widgets/connectivity_banner.dart';
import 'explore_screen.dart';
import '../widgets/hero_section.dart';
import '../widgets/game_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<GameProvider>();
    await Future.wait([
      provider.fetchPopularGames(),
      provider.fetchRecentGames(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExploreScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<GameProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading &&
                provider.popularGames.isEmpty &&
                provider.recentGames.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                const ConnectivityBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🎮 Hero Section - Juego destacado
                        if (provider.popularGames.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: HeroSection(
                              game: provider.popularGames.first,
                              height: 250,
                            ),
                          ),

                        const SizedBox(height: 24),

                        // 🔥 Popular Games Carousel
                        if (provider.popularGames.isNotEmpty)
                          GameCarousel(
                            games: provider.popularGames.take(10).toList(),
                            title: l10n.popularGames,
                            icon: Icons.trending_up,
                            height: 240,
                            cardWidth: 160,
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExploreScreen(),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 24),

                        // 🆕 Recent Games Carousel
                        if (provider.recentGames.isNotEmpty)
                          GameCarousel(
                            games: provider.recentGames.take(10).toList(),
                            title: l10n.recentGames,
                            icon: Icons.new_releases,
                            height: 240,
                            cardWidth: 160,
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExploreScreen(),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 24),

                        // Mensaje cuando no hay juegos
                        if (provider.popularGames.isEmpty &&
                            provider.recentGames.isEmpty &&
                            !provider.isLoading)
                          _buildEmptyState(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset_off,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay juegos disponibles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta recargar la página',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Recargar'),
            ),
          ],
        ),
      ),
    );
  }
}