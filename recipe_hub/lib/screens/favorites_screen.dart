import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/responsive.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<RecipeProvider>().favoriteRecipes;
    final pad = Responsive.sidePadding(context);

    return AppShell(
      index: 2,
      body: favs.isEmpty
          ? EmptyState(
              emoji: '💚',
              title: 'No favourites yet',
              message: 'Tap the heart on any recipe to keep it here.',
              actionLabel: 'Browse recipes',
              onAction: () => Navigator.pushReplacementNamed(context, '/recipes'),
            )
          : CustomScrollView(slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 20, pad, 16),
                sliver: SliverToBoxAdapter(
                  child: Text('Your favourites',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: RecipeCard.height,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FadeSlideIn(
                      key: ValueKey(favs[i].id),
                      index: i,
                      child: RecipeCard(recipe: favs[i]),
                    ),
                    childCount: favs.length,
                  ),
                ),
              ),
            ]),
    );
  }
}
