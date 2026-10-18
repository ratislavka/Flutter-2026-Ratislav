import 'package:flutter/material.dart';
import '../models/screening.dart';
import '../utils/format.dart';

class ScreeningCard extends StatelessWidget {
  const ScreeningCard({
    super.key,
    required this.screening,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Screening screening;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color genreColor = screening.category.color(scheme);
    final (int _, int free) = screening.places;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: genreColor.withValues(alpha: 0.18),
                      foregroundColor: genreColor,
                      child: Icon(screening.category.icon),
                    ),
                    if (screening.isFull || free <= 5)
                      Positioned(
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: screening.isFull
                                ? scheme.error
                                : scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            screening.isFull ? 'FULL' : '$free left',
                            style: textTheme.labelSmall?.copyWith(
                              color: screening.isFull
                                  ? scheme.onError
                                  : scheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      screening.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(screening.when),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      screening.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                icon: Icon(
                  screening.favourite ? Icons.favorite : Icons.favorite_border,
                  color: screening.favourite ? scheme.error : scheme.outline,
                ),
                tooltip: 'Favourite',
              ),
            ],
          ),
        ),
      ),
    );
  }
}