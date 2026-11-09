import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/responsive.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';
import '../widgets/cuisine_chip.dart';
import '../widgets/recipe_card.dart';
import '../widgets/servings_selector.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search =
        TextEditingController(text: context.read<RecipeProvider>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecipeProvider>();
    final recipes = p.filtered;
    final pad = Responsive.sidePadding(context);
    final mobile = Responsive.isMobile(context);

    final searchField = SizedBox(
      width: mobile ? double.infinity : 340,
      child: TextField(
        controller: _search,
        onChanged: p.setQuery,
        decoration: InputDecoration(
          hintText: 'Search a dish or ingredient',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    p.setQuery('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );

    final sortBox = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5DDD3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: p.sort,
          icon: const Icon(Icons.sort),
          items: [
            for (final s in RecipeProvider.sortOptions)
              DropdownMenuItem(value: s, child: Text('Sort: $s')),
          ],
          onChanged: (v) => p.setSort(v ?? 'Default'),
        ),
      ),
    );

    return AppShell(
      index: 1,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All recipes',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ServingsSelector(
                          value: p.servings, onChanged: p.setServings),
                      searchField,
                      sortBox,
                      FilterChip(
                        label: const Text('Vegetarian only'),
                        avatar: const Icon(Icons.eco, size: 18),
                        selected: p.vegOnly,
                        onSelected: p.setVegOnly,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: p.cuisineNames.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final name = p.cuisineNames[i];
                        return CuisineChip(
                          name: name,
                          selected: p.selectedCuisine == name,
                          onTap: () => p.setCuisine(name),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'} '
                    'for ${p.servings} ${p.servings == 1 ? 'person' : 'people'}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (recipes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                emoji: '🔍',
                title: 'No recipes match',
                message: 'Try a different ingredient or clear the filters.',
                actionLabel: 'Clear filters',
                onAction: () {
                  _search.clear();
                  p.clearFilters();
                },
              ),
            )
          else
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
                    key: ValueKey(recipes[i].id),
                    index: i,
                    child: RecipeCard(recipe: recipes[i]),
                  ),
                  childCount: recipes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
