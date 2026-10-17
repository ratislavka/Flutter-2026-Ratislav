import 'package:flutter/foundation.dart';
import 'film_genre.dart';

@immutable
class Screening {
  const Screening({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    required List<String> audience,
    required this.isStream,
    this.note,
    this.favourite = false,
  }) : _audience = audience;

  Screening.empty()
      : id = DateTime.now().microsecondsSinceEpoch.toString(),
        title = '',
        category = FilmGenre.sciFi,
        when = DateTime.now().add(const Duration(days: 1)),
        place = '',
        limit = 30,
        _audience = const <String>[],
        isStream = false,
        note = null,
        favourite = false;

  final String id;
  final String title;
  final FilmGenre category;
  final DateTime when;
  final String place;
  final int limit;
  final List<String> _audience;
  final bool isStream;
  final String? note;
  final bool favourite;

  List<String> get audience => List<String>.unmodifiable(_audience);

  int get count => _audience.length;

  int get freePlaces => (limit - count).clamp(0, limit);

  bool get isFull => count >= limit;

  bool get isPast => when.isBefore(DateTime.now());

  bool contains(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    return _audience.any((String member) => member == trimmed);
  }

  (int taken, int free) get places => (count, freePlaces);

  Screening copyWith({
    String? id,
    String? title,
    FilmGenre? category,
    DateTime? when,
    String? place,
    int? limit,
    List<String>? audience,
    bool? isStream,
    String? note,
    bool clearNote = false,
    bool? favourite,
  }) {
    return Screening(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      place: place ?? this.place,
      limit: limit ?? this.limit,
      audience: audience != null
          ? List<String>.unmodifiable(audience)
          : _audience,
      isStream: isStream ?? this.isStream,
      note: clearNote ? null : (note ?? this.note),
      favourite: favourite ?? this.favourite,
    );
  }
}