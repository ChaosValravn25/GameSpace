import 'package:flutter/material.dart';

/// Widget para mostrar estados vacíos
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Título
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Mensaje
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Acción
            if (customAction != null)
              customAction!
            else if (onAction != null && actionLabel != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío para búsquedas sin resultados
class EmptySearchWidget extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;

  const EmptySearchWidget({
    super.key,
    required this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Sin resultados',
      message: 'No se encontraron resultados para "$query".\nIntenta con otros términos de búsqueda.',
      actionLabel: 'Limpiar búsqueda',
      onAction: onClearSearch,
    );
  }
}

/// Estado vacío para colecciones
class EmptyCollectionWidget extends StatelessWidget {
  final String collectionName;
  final VoidCallback? onExplore;

  const EmptyCollectionWidget({
    super.key,
    required this.collectionName,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: _getCollectionIcon(collectionName),
      title: 'Colección vacía',
      message: 'Tu colección de $collectionName está vacía.\nComienza a agregar juegos desde la búsqueda.',
      actionLabel: 'Explorar Juegos',
      onAction: onExplore,
    );
  }

  IconData _getCollectionIcon(String name) {
    switch (name.toLowerCase()) {
      case 'favoritos':
        return Icons.favorite_border;
      case 'jugando':
        return Icons.play_circle_outline;
      case 'completados':
        return Icons.check_circle_outline;
      case 'wishlist':
        return Icons.bookmark_border;
      default:
        return Icons.collections_bookmark_outlined;
    }
  }
}

/// Estado vacío para historial
class EmptyHistoryWidget extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyHistoryWidget({
    super.key,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.history,
      title: 'Sin historial',
      message: 'Aún no has buscado ningún juego.\nExplora nuestra biblioteca de juegos.',
      actionLabel: 'Comenzar a explorar',
      onAction: onExplore,
    );
  }
}

/// Estado vacío para favoritos
class EmptyFavoritesWidget extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyFavoritesWidget({
    super.key,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'Sin favoritos',
      message: 'No tienes juegos favoritos aún.\nMarca los juegos que más te gusten.',
      actionLabel: 'Descubrir juegos',
      onAction: onExplore,
    );
  }
}

/// Estado vacío con ilustración
class IllustratedEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? imagePath;
  final String? actionLabel;
  final VoidCallback? onAction;

  const IllustratedEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.imagePath,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                height: 200,
                fit: BoxFit.contain,
              )
            else
              Icon(
                Icons.inbox,
                size: 120,
                color: Colors.grey[300],
              ),
            
            const SizedBox(height: 32),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
            
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vacío compacto (para secciones)
class CompactEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const CompactEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío con múltiples acciones
class MultiActionEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final List<EmptyStateAction> actions;

  const MultiActionEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
            ...actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: action.isPrimary
                      ? ElevatedButton.icon(
                          onPressed: action.onPressed,
                          icon: Icon(action.icon),
                          label: Text(action.label),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: action.onPressed,
                          icon: Icon(action.icon),
                          label: Text(action.label),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Clase para definir acciones de estado vacío
class EmptyStateAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  EmptyStateAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });
}

/// Estado vacío inline (para listas)
class InlineEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const InlineEmptyState({
    super.key,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}