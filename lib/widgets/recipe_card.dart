import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cuisine.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'dish_photo.dart';
import 'common_widgets.dart';

/// Reusable recipe summary card (fixed height so it works in any grid/list).
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const RecipeCard({super.key, required this.recipe});

  static const double height = 300;

  @override
  Widget build(BuildContext context) {
    final cuisine = cuisineOf(recipe.cuisine);
    final isFav =
        context.select<RecipeProvider, bool>((p) => p.isFavorite(recipe.id));

    return HoverScale(
      scale: 1.025,
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              Navigator.pushNamed(context, '/recipe', arguments: recipe.id),
          child: Column(children: [
            // Visual header built with a Stack
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Stack(children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cuisine.color, cuisine.color.withOpacity(0.65)],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: DishPhoto(name: recipe.name, cuisine: recipe.cuisine, color: cuisine.color)),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(recipe.cuisine,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cuisine.color)),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton(
                    tooltip: isFav ? 'Remove from favourites' : 'Save to favourites',
                    onPressed: () =>
                        context.read<RecipeProvider>().toggleFavorite(recipe.id),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFav),
                        color: isFav ? AppTheme.chili : Colors.white,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(recipe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13.5)),
                    const Spacer(),
                    Wrap(spacing: 8, runSpacing: 4, children: [
                      InfoPill(
                          icon: Icons.schedule,
                          label: formatMinutes(recipe.totalMinutes)),
                      InfoPill(
                          icon: Icons.local_fire_department,
                          label: '${recipe.caloriesPerServing} kcal',
                          color: AppTheme.chili),
                      if (recipe.vegetarian)
                        const InfoPill(icon: Icons.eco, label: 'Veg'),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
