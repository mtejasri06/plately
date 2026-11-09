import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cuisine.dart';
import '../models/recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/responsive.dart';
import '../widgets/app_shell.dart';

/// Form that lets people add their own recipe (demonstrates validation).
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _servings = TextEditingController(text: '4');
  final _prep = TextEditingController();
  final _cook = TextEditingController();
  final _calories = TextEditingController();
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();

  String? _cuisine;
  String _difficulty = 'Easy';
  bool _vegetarian = false;

  @override
  void dispose() {
    for (final c in [
      _name, _description, _servings, _prep, _cook, _calories, _ingredients, _steps
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── validators ──
  String? _required(String? v, {int min = 1, String label = 'This field'}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$label is required';
    if (t.length < min) return '$label needs at least $min characters';
    return null;
  }

  String? Function(String?) _intInRange(String label, int min, int max) {
    return (v) {
      final n = int.tryParse(v?.trim() ?? '');
      if (n == null) return 'Enter a whole number';
      if (n < min || n > max) return '$label must be $min-$max';
      return null;
    };
  }

  /// Each line must look like "200 g Paneer".
  List<Ingredient>? _parseIngredients(String text) {
    final result = <Ingredient>[];
    for (final line in text.split('\n')) {
      final l = line.trim();
      if (l.isEmpty) continue;
      final parts = l.split(RegExp(r'\s+'));
      final qty = parts.isNotEmpty ? double.tryParse(parts[0]) : null;
      if (parts.length < 3 || qty == null || qty <= 0) return null;
      result.add(Ingredient(parts.sublist(2).join(' '), qty, parts[1]));
    }
    return result;
  }

  String? _validateIngredients(String? v) {
    final parsed = _parseIngredients(v ?? '');
    if (parsed == null) {
      return 'Use one per line: quantity, unit, name (e.g. 200 g Paneer)';
    }
    if (parsed.length < 2) return 'Add at least 2 ingredients';
    return null;
  }

  String? _validateSteps(String? v) {
    final lines = (v ?? '').split('\n').where((l) => l.trim().isNotEmpty);
    if (lines.length < 2) return 'Add at least 2 steps (one per line)';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields')));
      return;
    }
    final prep = int.parse(_prep.text.trim());
    final cook = int.parse(_cook.text.trim());
    if (prep + cook == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Prep and cook time cannot both be 0 minutes')));
      return;
    }

    final recipe = Recipe(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      cuisine: _cuisine!,
      emoji: cuisineOf(_cuisine!).emoji,
      description: _description.text.trim(),
      baseServings: int.parse(_servings.text.trim()),
      prepMinutes: prep,
      cookMinutes: cook,
      caloriesPerServing: int.parse(_calories.text.trim()),
      difficulty: _difficulty,
      vegetarian: _vegetarian,
      ingredients: _parseIngredients(_ingredients.text)!,
      steps: _steps.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      isUserAdded: true,
      author: context.read<AuthProvider>().name,
    );

    context.read<RecipeProvider>().addRecipe(recipe);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('"${recipe.name}" added')));

    _formKey.currentState!.reset();
    for (final c in [_name, _description, _prep, _cook, _calories, _ingredients, _steps]) {
      c.clear();
    }
    _servings.text = '4';
    setState(() {
      _cuisine = null;
      _difficulty = 'Easy';
      _vegetarian = false;
    });
    Navigator.pushNamed(context, '/recipe', arguments: recipe.id);
  }

  Widget _pair(bool wide, Widget a, Widget b) {
    if (!wide) {
      return Column(children: [a, const SizedBox(height: 14), b]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: a),
      const SizedBox(width: 14),
      Expanded(child: b),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final wide = !Responsive.isMobile(context);

    final cuisineField = DropdownButtonFormField<String>(
      value: _cuisine,
      decoration: const InputDecoration(labelText: 'Cuisine'),
      items: [
        for (final c in kCuisines)
          DropdownMenuItem(value: c.name, child: Text('${c.emoji}  ${c.name}')),
      ],
      validator: (v) => v == null ? 'Pick a cuisine' : null,
      onChanged: (v) => setState(() => _cuisine = v),
    );

    final difficultyField = DropdownButtonFormField<String>(
      value: _difficulty,
      decoration: const InputDecoration(labelText: 'Difficulty'),
      items: const [
        DropdownMenuItem(value: 'Easy', child: Text('Easy')),
        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
        DropdownMenuItem(value: 'Hard', child: Text('Hard')),
      ],
      onChanged: (v) => setState(() => _difficulty = v ?? 'Easy'),
    );

    return AppShell(
      index: 3,
      body: SingleChildScrollView(
        child: ContentWrapper(
          maxWidth: 820,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add your recipe',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text(
                    'It joins the library and scales for any number of people.',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Recipe name'),
                  validator: (v) => _required(v, min: 3, label: 'Name'),
                ),
                const SizedBox(height: 14),
                _pair(wide, cuisineField, difficultyField),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLength: 120,
                  decoration:
                      const InputDecoration(labelText: 'Short description'),
                  validator: (v) => _required(v, min: 10, label: 'Description'),
                ),
                const SizedBox(height: 4),
                _pair(
                  wide,
                  TextFormField(
                    controller: _servings,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Makes (people)',
                        helperText: 'Quantities below are for this many people'),
                    validator: _intInRange('Servings', 1, 20),
                  ),
                  TextFormField(
                    controller: _calories,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Calories per serving (kcal)'),
                    validator: _intInRange('Calories', 10, 3000),
                  ),
                ),
                const SizedBox(height: 14),
                _pair(
                  wide,
                  TextFormField(
                    controller: _prep,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Prep time (minutes)'),
                    validator: _intInRange('Prep time', 0, 600),
                  ),
                  TextFormField(
                    controller: _cook,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Cook time (minutes)'),
                    validator: _intInRange('Cook time', 0, 600),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vegetarian'),
                  value: _vegetarian,
                  onChanged: (v) => setState(() => _vegetarian = v),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _ingredients,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients',
                    alignLabelWithHint: true,
                    helperText: 'One per line: quantity unit name\n200 g Paneer\n2 tbsp Butter',
                    helperMaxLines: 3,
                  ),
                  validator: _validateIngredients,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _steps,
                  minLines: 5,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    alignLabelWithHint: true,
                    helperText: 'One step per line',
                  ),
                  validator: _validateSteps,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: wide ? 260 : double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Save recipe'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
