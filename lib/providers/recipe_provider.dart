import 'package:flutter/foundation.dart';
import '../data/recipes_data.dart';
import '../models/cuisine.dart';
import '../models/recipe.dart';
import 'auth_provider.dart';

/// App-wide state: servings, filters, favourites and user-added recipes.
class RecipeProvider extends ChangeNotifier {
  static const int minServings = 1;
  static const int maxServings = 20;
  static const sortOptions = ['Default', 'Quickest', 'Lowest calories'];

  final List<Recipe> _recipes = List.of(kSampleRecipes);
  final Set<String> _favorites = {};

  int _servings = 4;
  String _cuisine = 'All';
  String _query = '';
  bool _vegOnly = false;
  String _sort = 'Default';

  // ── getters ──
  int get servings => _servings;
  String get selectedCuisine => _cuisine;
  String get query => _query;
  bool get vegOnly => _vegOnly;
  String get sort => _sort;
  List<Recipe> get allRecipes => List.unmodifiable(_recipes);
  List<String> get cuisineNames => ['All', ...kCuisines.map((c) => c.name)];

  List<Recipe> get filtered {
    final q = _query.toLowerCase();
    final list = _recipes.where((r) {
      final cuisineOk = _cuisine == 'All' || r.cuisine == _cuisine;
      final vegOk = !_vegOnly || r.vegetarian;
      final queryOk = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.ingredients.any((i) => i.name.toLowerCase().contains(q));
      return cuisineOk && vegOk && queryOk;
    }).toList();

    switch (_sort) {
      case 'Quickest':
        list.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
        break;
      case 'Lowest calories':
        list.sort((a, b) => a.caloriesPerServing.compareTo(b.caloriesPerServing));
        break;
    }
    return list;
  }

  List<Recipe> get quickPicks =>
      _recipes.where((r) => r.totalMinutes <= 30).toList();

  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => _favorites.contains(r.id)).toList();

  int get favoriteCount => _favorites.length;
  bool isFavorite(String id) => _favorites.contains(id);
  int countFor(String cuisine) =>
      _recipes.where((r) => r.cuisine == cuisine).length;

  Recipe? byId(String id) {
    for (final r in _recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  // ── actions ──
  void setServings(int v) {
    _servings = v.clamp(minServings, maxServings);
    notifyListeners();
  }

  void setCuisine(String c) {
    _cuisine = c;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q.trim();
    notifyListeners();
  }

  void setVegOnly(bool v) {
    _vegOnly = v;
    notifyListeners();
  }

  void setSort(String s) {
    _sort = s;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (!_favorites.remove(id)) _favorites.add(id);
    notifyListeners();
  }

  void clearFilters() {
    _cuisine = 'All';
    _query = '';
    _vegOnly = false;
    _sort = 'Default';
    notifyListeners();
  }

  void addRecipe(Recipe r) {
    _recipes.insert(0, r);
    notifyListeners();
  }

  final Map<String, List<Comment>> _comments = {};
  List<Comment> commentsFor(String id) => _comments[id] ?? const [];
  void addComment(String id, Comment c) {
    _comments.putIfAbsent(id, () => []).add(c);
    notifyListeners();
  }
}
