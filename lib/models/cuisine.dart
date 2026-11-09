import 'package:flutter/material.dart';

class Cuisine {
  final String name;
  final String emoji;
  final String tagline;
  final Color color;
  const Cuisine(this.name, this.emoji, this.tagline, this.color);
}

const List<Cuisine> kCuisines = [
  Cuisine('Indian', '🍛', 'Slow spice, rich gravies', Color(0xFFE08A1E)),
  Cuisine('Italian', '🍝', 'Simple, honest, pasta-first', Color(0xFFB3382C)),
  Cuisine('Mexican', '🌮', 'Lime, chilli and corn', Color(0xFF3F8F4F)),
  Cuisine('Chinese', '🥡', 'Wok heat in minutes', Color(0xFFC4452D)),
  Cuisine('Japanese', '🍣', 'Clean, balanced flavours', Color(0xFF3B6E9C)),
  Cuisine('Mediterranean', '🥗', 'Olive oil and fresh herbs', Color(0xFF2F8C86)),
  Cuisine('Thai', '🍜', 'Sweet, sour, salty, hot', Color(0xFFD98B1F)),
  Cuisine('Korean', '🥘', 'Fermented, fiery, comforting', Color(0xFFB83A5B)),
  Cuisine('French', '🥖', 'Butter, wine and patience', Color(0xFF5B4FA0)),
  Cuisine('Spanish', '🥘', 'Sun, saffron and sharing plates', Color(0xFFD1A21B)),
];

Cuisine cuisineOf(String name) =>
    kCuisines.firstWhere((c) => c.name == name, orElse: () => kCuisines.first);
