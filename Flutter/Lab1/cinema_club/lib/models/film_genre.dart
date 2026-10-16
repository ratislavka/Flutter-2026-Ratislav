import 'package:flutter/material.dart';

enum FilmGenre {
  sciFi(label: 'Sci-Fi', icon: Icons.rocket_launch_outlined),
  crime(label: 'Crime', icon: Icons.local_police_outlined),
  action(label: 'Action', icon: Icons.bolt_outlined),
  musical(label: 'Musical', icon: Icons.music_note_outlined),
  thriller(label: 'Thriller', icon: Icons.visibility_outlined);

  const FilmGenre({required this.label, required this.icon});

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
        FilmGenre.sciFi => scheme.primary,
        FilmGenre.crime => scheme.secondary,
        FilmGenre.action => scheme.tertiary,
        FilmGenre.musical => scheme.error,
        FilmGenre.thriller => scheme.inversePrimary,
      };
}