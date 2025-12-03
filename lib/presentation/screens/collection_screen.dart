import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../data/models/game.dart';
import '/../config/Api_Constants.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';
import '../widgets/collection_tab.dart'; 
import 'explore_screen.dart';
import '../widgets/connectivity_banner.dart';
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCollections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    final provider = context.read<GameProvider>();
    await provider.loadFavorites(); // Solo precarga favoritos (está bien)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'Vista de lista' : 'Vista de cuadrícula',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            Tab(icon: Icon(Icons.play_circle), text: 'Jugando'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completados'),
            Tab(icon: Icon(Icons.bookmark), text: 'Wishlist'),
          ],
        ),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(), // ← Ahora sí lo reconoce
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCollectionTab(AppConstants.collectionFavorites),
                _buildCollectionTab(AppConstants.collectionPlaying),
                _buildCollectionTab(AppConstants.collectionCompleted),
                _buildCollectionTab(AppConstants.collectionWishlist),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionTab(String collectionType) {
    return FutureBuilder<List<Game>>(                       // ← GENÉRICO AÑADIDO
      future: context.read<GameProvider>().loadCollection(collectionType),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final List<Game> games = snapshot.data ?? <Game>[];  // ← Tipo explícito

        return CollectionTab(
          collectionType: collectionType,
          games: games,
          isLoading: isLoading,
          errorMessage: hasError ? snapshot.error.toString() : null,
          isGridView: _isGridView,
          onRefresh: () {
            setState(() {}); // Fuerza rebuild → nuevo Future → recarga
          },
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExploreScreen(),
              ),
            );
          },
        );
      },
    );
  }
}