import 'package:flutter/material.dart';

/// Widget para mostrar errores
class ErrorDisplayWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final VoidCallback? onCancel;

  const ErrorDisplayWidget({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryButtonText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de error
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.red,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            
            // Mensaje
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Botones
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryButtonText ?? 'Reintentar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancelar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error de red
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'Sin Conexión',
      message: 'No se pudo conectar al servidor.\nVerifica tu conexión a internet.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// Error 404 (no encontrado)
class NotFoundErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onGoBack;

  const NotFoundErrorWidget({
    super.key,
    this.message,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '404',
      message: message ?? 'El contenido que buscas no existe',
      icon: Icons.search_off,
      onRetry: onGoBack,
      retryButtonText: 'Volver',
    );
  }
}

/// Error genérico
class GenericErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const GenericErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'Algo salió mal',
      message: message ?? 'Ha ocurrido un error inesperado',
      icon: Icons.error_outline,
      onRetry: onRetry,
    );
  }
}

/// Error inline (para listas)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
              tooltip: 'Reintentar',
            ),
        ],
      ),
    );
  }
}

/// Snackbar de error
void showErrorSnackbar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
  VoidCallback? onRetry,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red,
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    ),
  );
}

/// Dialog de error
void showErrorDialog(
  BuildContext context, {
  String? title,
  required String message,
  VoidCallback? onRetry,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.error_outline, size: 48, color: Colors.red),
      title: Text(title ?? 'Error'),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Reintentar'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

/// Error con botones personalizados
class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final List<ErrorAction> actions;

  const CustomErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.red),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        )
                      : OutlinedButton.icon(
                          onPressed: action.onPressed,
                          icon: Icon(action.icon),
                          label: Text(action.label),
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

/// Clase para definir acciones de error
class ErrorAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  ErrorAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });
}

/// Error con ilustración
class IllustratedErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? illustrationPath;
  final VoidCallback? onAction;
  final String? actionLabel;

  const IllustratedErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.illustrationPath,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustrationPath != null)
              Image.asset(
                illustrationPath!,
                height: 200,
                fit: BoxFit.contain,
              )
            else
              Icon(
                Icons.sentiment_dissatisfied,
                size: 100,
                color: Colors.grey[400],
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
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel ?? 'Continuar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}