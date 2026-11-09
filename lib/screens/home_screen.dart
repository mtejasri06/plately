import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cuisine.dart';
import '../providers/recipe_provider.dart';
import '../widgets/home_hero.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: context.read<RecipeProvider>().servings.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter how many people you are cooking for';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Use a whole number, e.g. 4';
    if (n < RecipeProvider.minServings || n > RecipeProvider.maxServings) {
      return 'Choose between ${RecipeProvider.minServings} and ${RecipeProvider.maxServings} people';
    }
    return null;
  }

  void _bump(int delta) {
    final provider = context.read<RecipeProvider>();
    final current = int.tryParse(_controller.text.trim()) ?? provider.servings;
    final next = (current + delta)
        .clamp(RecipeProvider.minServings, RecipeProvider.maxServings);
    _controller.text = next.toString();
    provider.setServings(next);
    _formKey.currentState?.validate();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<RecipeProvider>();
      provider.setServings(int.parse(_controller.text.trim()));
      provider.setCuisine('All');
      Navigator.pushReplacementNamed(context, '/recipes');
    }
  }

  void _openCuisine(String name) {
    if (_formKey.currentState?.validate() ?? true) {
      final provider = context.read<RecipeProvider>();
      final n = int.tryParse(_controller.text.trim());
      if (n != null) provider.setServings(n);
      provider.setCuisine(name);
      Navigator.pushReplacementNamed(context, '/recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final wide = !Responsive.isMobile(context) &&
        MediaQuery.of(context).size.width >= 860;

    final headline = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What are we\ncooking tonight?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: -1)),
        const SizedBox(height: 12),
        Text(
          'Pick a cuisine, tell us how many are eating, and get exact '
          'ingredient quantities, step-by-step method, cooking time and calories.',
          style: TextStyle(
              color: Colors.white.withOpacity(0.88), fontSize: 16, height: 1.45),
        ),
      ],
    );

    final form = _ServingsCard(
      formKey: _formKey,
      controller: _controller,
      validator: _validate,
      onBump: _bump,
      onSubmit: _submit,
    );

    return AppShell(
      index: 0,
      body: SingleChildScrollView(
        child: Column(children: [
          const HomeHero(),
          // ── Hero ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.spinach, Color(0xFF3A44C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(children: [
              const Positioned(
                  right: -20,
                  top: -10,
                  child: Opacity(
                      opacity: 0.12,
                      child: Text('🍲', style: TextStyle(fontSize: 220)))),
              const Positioned(
                  left: -30,
                  bottom: -40,
                  child: Opacity(
                      opacity: 0.10,
                      child: Text('🌿', style: TextStyle(fontSize: 180)))),
              ContentWrapper(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Responsive.value(context,
                          mobile: 12.0, tablet: 24.0, desktop: 40.0)),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 6, child: headline),
                            const SizedBox(width: 48),
                            Expanded(flex: 5, child: form),
                          ],
                        )
                      : Column(children: [
                          headline,
                          const SizedBox(height: 24),
                          form,
                        ]),
                ),
              ),
            ]),
          ),

          ContentWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cuisine grid ──
                const SectionTitle('Browse by cuisine',
                    subtitle: 'Six kitchens, two tried-and-tested recipes each.'),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kCuisines.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, i) {
                    final c = kCuisines[i];
                    return FadeSlideIn(
                      index: i,
                      child: HoverScale(
                        child: Material(
                          color: c.color,
                          borderRadius: BorderRadius.circular(18),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _openCuisine(c.name),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.emoji,
                                      style: const TextStyle(fontSize: 34)),
                                  const Spacer(),
                                  Text(c.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(
                                      '${provider.countFor(c.name)} recipes · ${c.tagline}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // ── Quick picks (horizontal ListView) ──
                const SectionTitle('Ready in 30 minutes or less',
                    subtitle: 'Fast weeknight dinners. Scroll sideways for more.'),
                SizedBox(
                  height: RecipeCard.height + 12,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: provider.quickPicks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => SizedBox(
                      width: 300,
                      child: RecipeCard(recipe: provider.quickPicks[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ServingsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final void Function(int) onBump;
  final VoidCallback onSubmit;

  const _ServingsCard({
    required this.formKey,
    required this.controller,
    required this.validator,
    required this.onBump,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many people is it for?',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('We scale every ingredient and calorie total for you.',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                validator: validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (_) => onSubmit(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: 'Number of people',
                  prefixIcon: IconButton(
                    tooltip: 'Fewer people',
                    icon: const Icon(Icons.remove),
                    onPressed: () => onBump(-1),
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'More people',
                    icon: const Icon(Icons.add),
                    onPressed: () => onBump(1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Show me recipes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
