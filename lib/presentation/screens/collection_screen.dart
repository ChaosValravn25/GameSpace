import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../data/models/game.dart';
import '/../config/api_constants.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';

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
    await provider.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            Tab(icon: Icon(Icons.play_circle), text: 'Jugando'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completados'),
            Tab(icon: Icon(Icons.bookmark), text: 'Wishlist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCollectionTab(AppConstants.collectionFavorites),
          _buildCollectionTab(AppConstants.collectionPlaying),
          _buildCollectionTab(AppConstants.collectionCompleted),
          _buildCollectionTab(AppConstants.collectionWishlist),
        ],
      ),
    );
  }

  Widget _buildCollectionTab(String collectionType) {
    return FutureBuilder<List<Game>>(
      future: context.read<GameProvider>().loadCollection(collectionType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final games = snapshot.data ?? [];

        if (games.isEmpty) {
          return _buildEmptyState(collectionType);
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: _isGridView
              ? _buildGridView(games)
              : _buildListView(games),
        );
      },
    );
  }

  Widget _buildEmptyState(String collectionType) {
    String title;
    String message;
    IconData icon;

    switch (collectionType) {
      case AppConstants.collectionFavorites:
        title = 'Sin Favoritos';
        message = 'Agrega juegos a tus favoritos desde la búsqueda';
        icon = Icons.favorite_border;
        break;
      case AppConstants.collectionPlaying:
        title = 'No estás jugando nada';
        message = 'Marca los juegos que estás jugando actualmente';
        icon = Icons.play_circle_outline;
        break;
      case AppConstants.collectionCompleted:
        title = 'Sin juegos completados';
        message = 'Marca los juegos que ya completaste';
        icon = Icons.check_circle_outline;
        break;
      case AppConstants.collectionWishlist:
        title = 'Wishlist vacía';
        message = 'Agrega juegos que quieres jugar en el futuro';
        icon = Icons.bookmark_border;
        break;
      default:
        title = 'Colección vacía';
        message = 'Agrega juegos desde la búsqueda';
        icon = Icons.collections_bookmark_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Cambiar a tab de explorar
                DefaultTabController.of(context).animateTo(1);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Explorar Juegos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<Game> games) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameCard(
          game: games[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GameDetailScreen(gameId: games[index].id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(List<Game> games) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: game.backgroundImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      game.backgroundImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[800],
                          child: const Icon(Icons.videogame_asset),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.videogame_asset),
                  ),
            title: Text(
              game.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              game.released ?? 'Fecha desconocida',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (game.rating != null) ...[
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(game.rating!.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                ],
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    _handleMenuAction(value, game);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('Ver Detalle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailScreen(gameId: game.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action, Game game) {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailScreen(gameId: game.id),
          ),
        );
        break;
      case 'remove':
        _confirmRemoveGame(game);
        break;
    }
  }

  void _confirmRemoveGame(Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar juego'),
        content: Text('¿Eliminar "${game.name}" de tu colección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().removeFromCollection(game.id);
              Navigator.pop(context);
              setState(() {});
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${game.name} eliminado'),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () {
                      // TODO: Implementar deshacer
                    },
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}