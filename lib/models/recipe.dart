class Ingredient {
  final String name;
  final double qty; // quantity for the recipe's baseServings
  final String unit;
  const Ingredient(this.name, this.qty, this.unit);
}

class Recipe {
  final String id;
  final String name;
  final String cuisine;
  final String emoji;
  final String description;
  final int baseServings;
  final int prepMinutes;
  final int cookMinutes;
  final int caloriesPerServing;
  final String difficulty;
  final bool vegetarian;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final bool isUserAdded;
  final String author;

  const Recipe({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.emoji,
    required this.description,
    required this.baseServings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.caloriesPerServing,
    required this.difficulty,
    required this.vegetarian,
    required this.ingredients,
    required this.steps,
    this.isUserAdded = false,
    this.author = 'RecipeHub Kitchen',
  });

  int get totalMinutes => prepMinutes + cookMinutes;
}
