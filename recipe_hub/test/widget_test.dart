import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recipe_hub/main.dart';
import 'package:recipe_hub/providers/recipe_provider.dart';

void main() {
  testWidgets('home screen shows the servings form', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => RecipeProvider(), child: const RecipeHubApp()));
    await tester.pumpAndSettle();
    expect(find.text('How many people is it for?'), findsOneWidget);
  });

  test('provider filters by cuisine and servings are clamped', () {
    final p = RecipeProvider();
    p.setCuisine('Italian');
    expect(p.filtered.every((r) => r.cuisine == 'Italian'), isTrue);
    p.setServings(99);
    expect(p.servings, RecipeProvider.maxServings);
  });
}
