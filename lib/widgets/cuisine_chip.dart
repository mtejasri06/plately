import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../theme/app_theme.dart';

/// Filter chip whose colour and size animate when selected.
class CuisineChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const CuisineChip(
      {super.key,
      required this.name,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAll = name == 'All';
    final color = isAll ? AppTheme.spinach : cuisineOf(name).color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? color : const Color(0xFFD5DDD3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(isAll ? '🍽️' : cuisineOf(name).emoji),
          const SizedBox(width: 6),
          Text(name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.ink,
              )),
        ]),
      ),
    );
  }
}
