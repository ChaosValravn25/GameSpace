import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../providers/game_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/connectivity_banner.dart';
import '../screens/game_detail_screen.dart';

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
    final theme = Theme.of(context);

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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Section
                        if (provider.popularGames.isNotEmpty)
                          _buildHeroSection(
                            context,
                            provider.popularGames.first,
                          ),
                        
                        const SizedBox(height: 24),
                        
                        // Popular Games
                        _buildSectionTitle(
                          context,
                          l10n.popularGames,
                          Icons.trending_up,
                        ),
                        const SizedBox(height: 12),
                        _buildHorizontalList(
                          context,
                          provider.popularGames.take(10).toList(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recent Games
                        _buildSectionTitle(
                          context,
                          l10n.recentGames,
                          Icons.new_releases,
                        ),
                        const SizedBox(height: 12),
                        _buildHorizontalList(
                          context,
                          provider.recentGames.take(10).toList(),
                        ),
                        
                        const SizedBox(height: 24),
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

  Widget _buildHeroSection(BuildContext context, Game game) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailScreen(gameId: game.id),
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: game.backgroundImage != null
              ? DecorationImage(
                  image: NetworkImage(game.backgroundImage!),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: game.backgroundImage == null
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    game.rating?.toStringAsFixed(1) ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (game.metacritic != null) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getMetacriticColor(game.metacritic!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        game.metacritic.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<Game> games) {
    if (games.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No games available')),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < games.length - 1 ? 12 : 0,
            ),
            child: SizedBox(
              width: 150,
              child: GameCard(game: games[index]),
            ),
          );
        },
      ),
    );
  }

  Color _getMetacriticColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}