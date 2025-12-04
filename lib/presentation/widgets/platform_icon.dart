import 'package:flutter/material.dart';

/// Widget que muestra el icono de una plataforma de videojuegos
/// Soporta las principales plataformas de RAWG API
class PlatformIcon extends StatelessWidget {
  final String platformSlug;
  final double size;
  final Color? color;

  const PlatformIcon({
    super.key,
    required this.platformSlug,
    this.size = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getPlatformIcon(platformSlug);
    final iconColor = color ?? Theme.of(context).iconTheme.color;

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }

  /// Retorna el IconData correspondiente a cada plataforma
  /// basándose en el slug de RAWG API
  IconData _getPlatformIcon(String slug) {
    final lowerSlug = slug.toLowerCase();

    // PlayStation
    if (lowerSlug.contains('playstation') || 
        lowerSlug.contains('ps4') || 
        lowerSlug.contains('ps5') ||
        lowerSlug.contains('ps3') ||
        lowerSlug.contains('ps2') ||
        lowerSlug.contains('ps1') ||
        lowerSlug.contains('psvita') ||
        lowerSlug.contains('psp')) {
      return Icons.sports_esports; // Icono de PlayStation
    }
    
    // Xbox
    if (lowerSlug.contains('xbox')) {
      return Icons.videogame_asset; // Icono de Xbox
    }
    
    // PC / Windows
    if (lowerSlug.contains('pc') || 
        lowerSlug.contains('windows') ||
        lowerSlug.contains('linux') ||
        lowerSlug.contains('macos') ||
        lowerSlug.contains('mac')) {
      return Icons.computer;
    }
    
    // Nintendo Switch
    if (lowerSlug.contains('nintendo-switch') || lowerSlug.contains('switch')) {
      return Icons.switch_access_shortcut;
    }
    
    // Nintendo (otras consolas)
    if (lowerSlug.contains('nintendo') ||
        lowerSlug.contains('wii') ||
        lowerSlug.contains('3ds') ||
        lowerSlug.contains('ds')) {
      return Icons.videogame_asset_outlined;
    }
    
    // iOS
    if (lowerSlug.contains('ios') || lowerSlug.contains('iphone') || lowerSlug.contains('ipad')) {
      return Icons.phone_iphone;
    }
    
    // Android
    if (lowerSlug.contains('android')) {
      return Icons.phone_android;
    }
    
    // Web / Browser
    if (lowerSlug.contains('web') || lowerSlug.contains('browser')) {
      return Icons.language;
    }
    
    // Sega
    if (lowerSlug.contains('sega') || 
        lowerSlug.contains('dreamcast') || 
        lowerSlug.contains('genesis')) {
      return Icons.gamepad;
    }
    
    // Atari
    if (lowerSlug.contains('atari')) {
      return Icons.games;
    }
    
    // Commodore / Amiga
    if (lowerSlug.contains('commodore') || lowerSlug.contains('amiga')) {
      return Icons.keyboard;
    }
    
    // Default - Icono genérico
    return Icons.gamepad;
  }
}

/// Widget que muestra múltiples iconos de plataformas en fila
class PlatformIconRow extends StatelessWidget {
  final List<String> platformSlugs;
  final double iconSize;
  final Color? iconColor;
  final double spacing;
  final int? maxIcons;

  const PlatformIconRow({
    super.key,
    required this.platformSlugs,
    this.iconSize = 18.0,
    this.iconColor,
    this.spacing = 8.0,
    this.maxIcons,
  });

  @override
  Widget build(BuildContext context) {
    // Limitar cantidad de iconos si se especifica maxIcons
    final displayPlatforms = maxIcons != null && platformSlugs.length > maxIcons!
        ? platformSlugs.take(maxIcons!).toList()
        : platformSlugs;

    final hasMore = maxIcons != null && platformSlugs.length > maxIcons!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayPlatforms.map((slug) => Padding(
              padding: EdgeInsets.only(right: spacing),
              child: PlatformIcon(
                platformSlug: slug,
                size: iconSize,
                color: iconColor,
              ),
            )),
        if (hasMore)
          Text(
            '+${platformSlugs.length - maxIcons!}',
            style: TextStyle(
              fontSize: iconSize * 0.8,
              color: iconColor ?? Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
      ],
    );
  }
}

/// Widget que muestra el nombre de la plataforma con su icono
class PlatformChip extends StatelessWidget {
  final String platformSlug;
  final String platformName;
  final double iconSize;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const PlatformChip({
    super.key,
    required this.platformSlug,
    required this.platformName,
    this.iconSize = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.chipTheme.backgroundColor ?? Colors.grey[800];
    final txtColor = textColor ?? theme.textTheme.bodyMedium?.color;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformIcon(
            platformSlug: platformSlug,
            size: iconSize,
            color: iconColor ?? txtColor,
          ),
          const SizedBox(width: 6.0),
          Text(
            platformName,
            style: TextStyle(
              fontSize: iconSize * 0.9,
              color: txtColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra las plataformas disponibles en forma de chips
class PlatformChipList extends StatelessWidget {
  final List<Map<String, String>> platforms; // [{slug: 'pc', name: 'PC'}, ...]
  final double spacing;
  final double runSpacing;
  final double iconSize;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const PlatformChipList({
    super.key,
    required this.platforms,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.iconSize = 16.0,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: platforms.map((platform) {
        return PlatformChip(
          platformSlug: platform['slug'] ?? '',
          platformName: platform['name'] ?? '',
          iconSize: iconSize,
          backgroundColor: backgroundColor,
          textColor: textColor,
          iconColor: iconColor,
        );
      }).toList(),
    );
  }
}