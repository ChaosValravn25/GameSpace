import 'package:flutter/material.dart';

import '../../data/models/genre.dart';
import '../../data/models/plataform.dart';
import '../widgets/platform_icon.dart';
/// Bottom Sheet para filtros de búsqueda
class FilterSheet extends StatefulWidget {
  final List<Genre>? genres;
  final List<PlatformInfo>? platforms;
  final List<int>? selectedGenres;
  final List<int>? selectedPlatforms;
  final String? selectedOrdering;
  final Function(List<int> genres, List<int> platforms, String? ordering)?
      onApply;

  const FilterSheet({
    super.key,
    this.genres,
    this.platforms,
    this.selectedGenres,
    this.selectedPlatforms,
    this.selectedOrdering,
    this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late List<int> _selectedGenres;
  late List<int> _selectedPlatforms;
  late String? _selectedOrdering;

  @override
  void initState() {
    super.initState();
    _selectedGenres = List.from(widget.selectedGenres ?? []);
    _selectedPlatforms = List.from(widget.selectedPlatforms ?? []);
    _selectedOrdering = widget.selectedOrdering ?? '-rating';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildOrderingSection(),
                    const SizedBox(height: 24),
                    if (widget.genres != null && widget.genres!.isNotEmpty)
                      _buildGenresSection(),
                    const SizedBox(height: 24),
                    if (widget.platforms != null &&
                        widget.platforms!.isNotEmpty)
                      _buildPlatformsSection(),
                  ],
                ),
              ),
              _buildActions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 24),
          const SizedBox(width: 12),
          Text(
            'Filtros',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar por',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildOrderingOption('-rating', 'Mejor Valorados', Icons.star),
        _buildOrderingOption('-released', 'Más Recientes', Icons.new_releases),
        _buildOrderingOption(
            '-metacritic', 'Metacritic Score', Icons.grade),
        _buildOrderingOption('name', 'Nombre (A-Z)', Icons.sort_by_alpha),
      ],
    );
  }

  Widget _buildOrderingOption(String value, String label, IconData icon) {
    final isSelected = _selectedOrdering == value;
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedOrdering,
      onChanged: (newValue) {
        setState(() {
          _selectedOrdering = newValue;
        });
      },
      title: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
      dense: true,
    );
  }

  Widget _buildGenresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category, size: 20),
            const SizedBox(width: 8),
            Text(
              'Géneros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            if (_selectedGenres.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedGenres.length}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.genres!.map((genre) {
            final isSelected = _selectedGenres.contains(genre.id);
            return FilterChip(
              label: Text(genre.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGenres.add(genre.id);
                  } else {
                    _selectedGenres.remove(genre.id);
                  }
                });
              },
              avatar: isSelected ? const Icon(Icons.check, size: 18) : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlatformsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.devices, size: 20),
            const SizedBox(width: 8),
            Text(
              'Plataformas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            if (_selectedPlatforms.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedPlatforms.length}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.platforms!.map((platform) {
            final isSelected = _selectedPlatforms.contains(platform.id);
            return FilterChip(
              label: Text(platform.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPlatforms.add(platform.id);
                  } else {
                    _selectedPlatforms.remove(platform.id);
                  }
                });
              },
              // 🎯 USANDO PlatformIcon EN VEZ DE _getPlatformIcon
              avatar: isSelected
                  ? const Icon(Icons.check, size: 18)
                  : PlatformIcon(
                      platformSlug: platform.slug,
                      size: 18,
                      color: Theme.of(context).iconTheme.color,
                    ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final activeFiltersCount =
        _selectedGenres.length + _selectedPlatforms.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (activeFiltersCount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$activeFiltersCount activos',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (widget.onApply != null) {
                    widget.onApply!(
                      _selectedGenres,
                      _selectedPlatforms,
                      _selectedOrdering,
                    );
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedGenres.clear();
      _selectedPlatforms.clear();
      _selectedOrdering = '-rating';
    });
  }

  // 🎯 MÉTODO ELIMINADO - Ya no es necesario
  // El PlatformIcon widget maneja los iconos automáticamente
}

/// Función helper para mostrar el FilterSheet
void showFilterSheet(
  BuildContext context, {
  List<Genre>? genres,
  List<PlatformInfo>? platforms,
  List<int>? selectedGenres,
  List<int>? selectedPlatforms,
  String? selectedOrdering,
  Function(List<int>, List<int>, String?)? onApply,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FilterSheet(
      genres: genres,
      platforms: platforms,
      selectedGenres: selectedGenres,
      selectedPlatforms: selectedPlatforms,
      selectedOrdering: selectedOrdering,
      onApply: onApply,
    ),
  );
}