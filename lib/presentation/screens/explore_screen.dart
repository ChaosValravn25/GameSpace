import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_sheet.dart';
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filtros
  List<int> _selectedGenres = [];
  List<int> _selectedPlatforms = [];
  String _selectedOrdering = '-rating';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<GameProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchGames();
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      context.read<GameProvider>().searchGames(query);
    } else {
      context.read<GameProvider>().fetchGames(refresh: true);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<GameProvider>().fetchGames(refresh: true);
  }

  void _showFilters() {
    showFilterSheet(
      context,
      // genres: genres,  // TODO: Obtener de provider o API
      // platforms: platforms,  // TODO: Obtener de provider o API
      selectedGenres: _selectedGenres,
      selectedPlatforms: _selectedPlatforms,
      selectedOrdering: _selectedOrdering,
      onApply: (genres, platforms, ordering) {
        setState(() {
          _selectedGenres = genres;
          _selectedPlatforms = platforms;
          _selectedOrdering = ordering ?? '-rating';
        });
        _applyFilters();
      },
    );
  }

  int get _activeFiltersCount =>
      _selectedGenres.length + _selectedPlatforms.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        // 🎯 AppBar sin bottom - Usamos GameSearchBar separado
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),

          // 🎯 NUEVO: Barra de búsqueda mejorada
          GameSearchBar(
            controller: _searchController,
            hintText: 'Buscar juegos...',
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
            onFilterTap: _showFilters,
            showFilterButton: true,
            filterCount: _activeFiltersCount,
          ),

          // 🎯 CHIP DE FILTROS ACTIVOS (opcional)
          if (_activeFiltersCount > 0) _buildActiveFiltersChip(),

          // Resultados
          Expanded(
            child: Consumer<GameProvider>(
              builder: (context, provider, child) {
                final games = _searchController.text.isEmpty
                    ? provider.games
                    : provider.searchResults;

                // Estado de carga inicial
                if (provider.isLoading && games.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Estado de error
                if (provider.errorMessage != null && games.isEmpty) {
                  return _buildErrorState(provider);
                }

                // Sin resultados
                if (games.isEmpty) {
                  return _buildEmptyState();
                }

                // Grid de juegos
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: games.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= games.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return GameCard(game: games[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          Chip(
            avatar: const Icon(Icons.filter_list, size: 18),
            label: Text('$_activeFiltersCount filtros activos'),
            onDeleted: () {
              setState(() {
                _selectedGenres.clear();
                _selectedPlatforms.clear();
                _selectedOrdering = '-rating';
              });
              context.read<GameProvider>().fetchGames(refresh: true);
            },
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
          TextButton.icon(
            onPressed: _showFilters,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Editar'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(GameProvider provider) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar juegos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.fetchGames(refresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Intenta con otro término de búsqueda'
                  : 'No hay juegos disponibles',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar búsqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }

 void _applyFilters() {
  context.read<GameProvider>().fetchGames(
    refresh: true,
    ordering: _selectedOrdering,
    genres: _selectedGenres,
    platforms: _selectedPlatforms,
  );
}
}