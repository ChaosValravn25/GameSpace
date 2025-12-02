import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../providers/game_provider.dart';
import '../../data/models/game.dart';
import '../widgets/game_card.dart';
import '../widgets/connectivity_banner.dart';
import 'game_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  
  bool _showFilters = false;
  String? _selectedGenre;
  String? _selectedPlatform;
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
    _debounce?.cancel();
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
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        context.read<GameProvider>().searchGames(query);
      } else {
        context.read<GameProvider>().fetchGames(refresh: true);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<GameProvider>().fetchGames(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar juegos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          
          // Filtros
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtros',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  
                  // Ordenar por
                  DropdownButtonFormField<String>(
                    initialValue: _selectedOrdering,
                    decoration: const InputDecoration(
                      labelText: 'Ordenar por',
                      prefixIcon: Icon(Icons.sort),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '-rating',
                        child: Text('Mejor Valorados'),
                      ),
                      DropdownMenuItem(
                        value: '-released',
                        child: Text('Más Recientes'),
                      ),
                      DropdownMenuItem(
                        value: '-metacritic',
                        child: Text('Metacritic Score'),
                      ),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Nombre (A-Z)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedOrdering = value!;
                      });
                      // Aplicar filtro
                      _applyFilters();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botón limpiar filtros
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedGenre = null;
                        _selectedPlatform = null;
                        _selectedOrdering = '-rating';
                        _showFilters = false;
                      });
                      context.read<GameProvider>().fetchGames(refresh: true);
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar Filtros'),
                  ),
                ],
              ),
            ),
          
          // Resultados
          Expanded(
            child: Consumer<GameProvider>(
              builder: (context, provider, child) {
                final games = _searchController.text.isEmpty
                    ? provider.games
                    : provider.searchResults;

                if (provider.isLoading && games.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && games.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar juegos',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            provider.fetchGames(refresh: true);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (games.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otro término de búsqueda',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

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

  void _applyFilters() {
    // TODO: Implementar aplicación de filtros con la API
    context.read<GameProvider>().fetchGames(refresh: true);
  }
}