import 'package:flutter/material.dart';
import '../models/screening.dart';
import '../widgets/empty_state.dart';
import '../widgets/screening_card.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.screenings,
    required this.onOpenDetail,
    required this.onToggleFavourite,
  });

  final List<Screening> screenings;
  final ValueChanged<Screening> onOpenDetail;
  final ValueChanged<Screening> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final List<Screening> favs = screenings
        .where((Screening item) => item.favourite)
        .toList();

    if (favs.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourite screenings yet.',
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 124,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: favs.length,
            itemBuilder: (BuildContext context, int index) {
              final Screening item = favs[index];
              return ScreeningCard(
                screening: item,
                onTap: () => onOpenDetail(item),
                onToggleFavourite: () => onToggleFavourite(item),
              );
            },
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final Screening item = favs[index];
            return ScreeningCard(
              screening: item,
              onTap: () => onOpenDetail(item),
              onToggleFavourite: () => onToggleFavourite(item),
            );
          },
        );
      },
    );
  }
}