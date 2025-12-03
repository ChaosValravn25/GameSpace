import 'package:flutter/material.dart';

/// Widget de badge de rating
class RatingBadge extends StatelessWidget {
  final double rating;
  final double size;
  final bool showLabel;
  final int maxRating;

  const RatingBadge({
    super.key,
    required this.rating,
    this.size = 16,
    this.showLabel = true,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: _getRatingColor(rating),
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: size,
            color: Colors.white,
          ),
          if (showLabel) ...[
            SizedBox(width: size * 0.25),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.875,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return const Color(0xFF10B981); // Verde brillante
    if (rating >= 4.0) return const Color(0xFF22C55E); // Verde
    if (rating >= 3.5) return const Color(0xFF84CC16); // Lima
    if (rating >= 3.0) return const Color(0xFFF59E0B); // Naranja
    if (rating >= 2.0) return const Color(0xFFEF4444); // Rojo
    return const Color(0xFF991B1B); // Rojo oscuro
  }
}

/// Badge de Metacritic Score
class MetacriticBadge extends StatelessWidget {
  final int score;
  final double size;

  const MetacriticBadge({
    super.key,
    required this.score,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: _getMetacriticColor(score),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MC',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.625,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: size * 0.25),
          Text(
            score.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.875,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMetacriticColor(int score) {
    if (score >= 75) return const Color(0xFF22C55E); // Verde
    if (score >= 50) return const Color(0xFFF59E0B); // Naranja
    return const Color(0xFFEF4444); // Rojo
  }
}

/// Estrellas de rating (visualización)
class StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalfStars;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 20,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.allowHalfStars = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star;
        } else if (allowHalfStars && rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Icon(
          icon,
          size: size,
          color: rating >= starValue - 0.5 ? activeColor : inactiveColor,
        );
      }),
    );
  }
}

/// Estrellas de rating interactivas (para valorar)
class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;
  final int maxStars;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const InteractiveStarRating({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.maxStars = 5,
    this.size = 32,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxStars, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starValue.toDouble();
            });
            widget.onRatingChanged?.call(_currentRating);
          },
          child: Icon(
            _currentRating >= starValue ? Icons.star : Icons.star_border,
            size: widget.size,
            color: _currentRating >= starValue
                ? widget.activeColor
                : widget.inactiveColor,
          ),
        );
      }),
    );
  }
}

/// Badge de rating circular
class CircularRatingBadge extends StatelessWidget {
  final double rating;
  final double size;
  final int maxRating;

  const CircularRatingBadge({
    super.key,
    required this.rating,
    this.size = 60,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = rating / maxRating;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: size * 0.1,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getRatingColor(rating),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.star,
                size: size * 0.2,
                color: _getRatingColor(rating),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }
}

/// Badge de rating con conteo
class RatingWithCount extends StatelessWidget {
  final double rating;
  final int count;
  final double size;

  const RatingWithCount({
    super.key,
    required this.rating,
    required this.count,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: size,
          color: Colors.amber,
        ),
        SizedBox(width: size * 0.25),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: size * 0.25),
        Text(
          '($count)',
          style: TextStyle(
            fontSize: size * 0.857,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Badge de rating compacto
class CompactRatingBadge extends StatelessWidget {
  final double rating;

  const CompactRatingBadge({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 12,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de rating grande (para detalles)
class LargeRatingBadge extends StatelessWidget {
  final double rating;
  final int? ratingsCount;
  final int? metacritic;

  const LargeRatingBadge({
    super.key,
    required this.rating,
    this.ratingsCount,
    this.metacritic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularRatingBadge(rating: rating),
            if (metacritic != null) ...[
              const SizedBox(width: 16),
              Column(
                children: [
                  const Text(
                    'Metacritic',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MetacriticBadge(score: metacritic!, size: 20),
                ],
              ),
            ],
          ],
        ),
        if (ratingsCount != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_formatCount(ratingsCount!)} valoraciones',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}