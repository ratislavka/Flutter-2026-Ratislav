import 'package:flutter/material.dart';
import '../models/film_genre.dart';
import '../models/screening.dart';
import '../widgets/empty_state.dart';
import '../widgets/screening_card.dart';

class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.screenings,
    required this.onOpenDetail,
    required this.onToggleFavourite,
  });

  final List<Screening> screenings;
  final ValueChanged<Screening> onOpenDetail;
  final ValueChanged<Screening> onToggleFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final TextEditingController _searchController = TextEditingController();
  FilmGenre? _selectedGenre;
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedGenre = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String query = _searchController.text.trim().toLowerCase();

    final List<Screening> filtered = widget.screenings.where((Screening item) {
      if (!_showPast && item.isPast) return false;
      if (_selectedGenre != null && item.category != _selectedGenre) {
        return false;
      }
      if (query.isNotEmpty && !item.title.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((Screening a, Screening b) {
        if (a.isPast != b.isPast) {
          return a.isPast ? 1 : -1;
        }
        return a.when.compareTo(b.when);
      });

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search screenings...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: <Widget>[
              ChoiceChip(
                label: const Text('All'),
                selected: _selectedGenre == null,
                onSelected: (_) {
                  setState(() {
                    _selectedGenre = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              for (final FilmGenre genre in FilmGenre.values) ...<Widget>[
                ChoiceChip(
                  avatar: Icon(genre.icon, size: 18),
                  label: Text(genre.label),
                  selected: _selectedGenre == genre,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedGenre = selected ? genre : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (bool value) {
                  setState(() {
                    _showPast = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.movie_filter_outlined,
                  message: 'No screenings match your filters.',
                  actionLabel: 'Reset filters',
                  onAction: _resetFilters,
                )
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth >= 600) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360,
                          mainAxisExtent: 124,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Screening item = filtered[index];
                          return ScreeningCard(
                            screening: item,
                            onTap: () => widget.onOpenDetail(item),
                            onToggleFavourite: () =>
                                widget.onToggleFavourite(item),
                          );
                        },
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Screening item = filtered[index];
                        return ScreeningCard(
                          screening: item,
                          onTap: () => widget.onOpenDetail(item),
                          onToggleFavourite: () =>
                              widget.onToggleFavourite(item),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}