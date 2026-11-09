import 'package:flutter/material.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';

/// Reusable "how many people" stepper with an animated number.
class ServingsSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const ServingsSelector(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD5DDD3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          tooltip: 'Fewer people',
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > RecipeProvider.minServings
              ? () => onChanged(value - 1)
              : null,
        ),
        const Icon(Icons.groups_rounded, color: AppTheme.spinach, size: 20),
        const SizedBox(width: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim, child: FadeTransition(opacity: anim, child: child)),
          child: Text('$value',
              key: ValueKey(value),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 4),
        Text(value == 1 ? 'person' : 'people',
            style: const TextStyle(color: Colors.black54)),
        IconButton(
          tooltip: 'More people',
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < RecipeProvider.maxServings
              ? () => onChanged(value + 1)
              : null,
        ),
      ]),
    );
  }
}
