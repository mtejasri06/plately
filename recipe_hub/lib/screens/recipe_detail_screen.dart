import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cuisine.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../widgets/comments_section.dart';
import '../widgets/dish_photo.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/responsive.dart';
import '../widgets/common_widgets.dart';
import '../widgets/servings_selector.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final Set<int> _haveIngredients = {};
  final Set<int> _doneSteps = {};

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    final p = context.watch<RecipeProvider>();
    final recipe = id == null ? null : p.byId(id);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
            emoji: '🤷', title: 'Recipe not found', message: 'It may have been removed.'),
      );
    }

    final servings = p.servings;
    final scale = servings / recipe.baseServings;
    final cuisine = cuisineOf(recipe.cuisine);
    final isFav = p.isFavorite(recipe.id);
    final twoColumns = MediaQuery.of(context).size.width >= 860;

    final ingredientsCard = _ingredients(recipe, scale, servings);
    final stepsCard = _steps(recipe);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            tooltip: isFav ? 'Remove from favourites' : 'Save to favourites',
            onPressed: () => p.toggleFavorite(recipe.id),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFav),
                  color: isFav ? AppTheme.chili : AppTheme.ink),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: ContentWrapper(
          maxWidth: 1100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [cuisine.color, cuisine.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(width: 180, height: 130, child: ClipRRect(borderRadius: BorderRadius.circular(16), child: DishPhoto(name: recipe.name, cuisine: recipe.cuisine, color: cuisine.color))),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${cuisine.name} · ${recipe.difficulty}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(recipe.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05)),
                          const SizedBox(height: 8),
                          Text(recipe.description,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.92),
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Servings + stats
              Wrap(
                spacing: 14,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ServingsSelector(value: servings, onChanged: p.setServings),
                  _Stat(Icons.schedule, 'Total time', formatMinutes(recipe.totalMinutes)),
                  _Stat(Icons.content_cut, 'Prep', formatMinutes(recipe.prepMinutes)),
                  _Stat(Icons.local_fire_department_outlined, 'Cook',
                      recipe.cookMinutes == 0 ? 'No cooking' : formatMinutes(recipe.cookMinutes)),
                  _Stat(Icons.local_fire_department, 'Per serving',
                      '${recipe.caloriesPerServing} kcal',
                      color: AppTheme.chili),
                  _AnimatedCalories(
                      total: recipe.caloriesPerServing * servings,
                      servings: servings),
                ],
              ),
              const SizedBox(height: 22),

              if (twoColumns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: ingredientsCard),
                    const SizedBox(width: 20),
                    Expanded(flex: 6, child: stepsCard),
                  ],
                )
              else ...[
                ingredientsCard,
                const SizedBox(height: 16),
                stepsCard,
              ],
              const SizedBox(height: 20),
              CommentsSection(recipeId: recipe.id),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ingredients(Recipe recipe, double scale, int servings) {
    return _Panel(
      title: 'Ingredients',
      trailing: 'for $servings ${servings == 1 ? 'person' : 'people'}',
      child: Column(children: [
        for (var i = 0; i < recipe.ingredients.length; i++)
          _ingredientTile(i, recipe.ingredients[i], scale),
      ]),
    );
  }

  Widget _ingredientTile(int i, Ingredient ing, double scale) {
    final checked = _haveIngredients.contains(i);
    final qty = formatQty(ing.qty * scale);
    final style = TextStyle(
      decoration: checked ? TextDecoration.lineThrough : null,
      color: checked ? Colors.black38 : AppTheme.ink,
    );
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppTheme.spinach,
      value: checked,
      onChanged: (v) => setState(() {
        v == true ? _haveIngredients.add(i) : _haveIngredients.remove(i);
      }),
      title: Text.rich(TextSpan(style: style, children: [
        TextSpan(
            text: '$qty ${ing.unit}  ',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        TextSpan(text: ing.name),
      ])),
    );
  }

  Widget _steps(Recipe recipe) {
    final total = recipe.steps.length;
    return _Panel(
      title: 'Method',
      trailing: '${_doneSteps.length}/$total done',
      child: Column(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _doneSteps.length / total),
          duration: const Duration(milliseconds: 400),
          builder: (context, v, _) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
                value: v, minHeight: 8, color: AppTheme.turmeric,
                backgroundColor: const Color(0xFFE8EEE6)),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < total; i++) _stepTile(i, recipe.steps[i]),
      ]),
    );
  }

  Widget _stepTile(int i, String text) {
    final done = _doneSteps.contains(i);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() {
        done ? _doneSteps.remove(i) : _doneSteps.add(i);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: done ? AppTheme.spinach.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppTheme.spinach : AppTheme.turmeric,
            ),
            child: done
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text('${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: done ? 0.5 : 1,
              child: Text(text, style: const TextStyle(fontSize: 15, height: 1.45)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String trailing;
  final Widget child;
  const _Panel({required this.title, required this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const Spacer(),
            Text(trailing, style: const TextStyle(color: Colors.black54)),
          ]),
          const SizedBox(height: 10),
          child,
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Stat(this.icon, this.label, this.value, {this.color = AppTheme.spinach});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8E0)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}

/// Total calories for the whole pot, counting up/down when servings change.
class _AnimatedCalories extends StatelessWidget {
  final int total;
  final int servings;
  const _AnimatedCalories({required this.total, required this.servings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.chili.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.restaurant, color: AppTheme.chili, size: 22),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total for $servings',
              style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
          TweenAnimationBuilder<double>(
            tween: Tween(end: total.toDouble()),
            duration: const Duration(milliseconds: 450),
            builder: (context, v, _) => Text('${v.round()} kcal',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppTheme.chili)),
          ),
        ]),
      ]),
    );
  }
}
