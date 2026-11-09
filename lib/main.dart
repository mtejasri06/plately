import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/recipes_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const RecipeHubApp(),
    ),
  );
}

class RecipeHubApp extends StatelessWidget {
  const RecipeHubApp({super.key});

  /// Named routes with custom transitions (fade for tabs, slide for detail).
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/recipe':
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => const RecipeDetailScreen(),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic))
                .animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
        );
      default:
        final Widget page;
        switch (settings.name) {
          case '/recipes':
            page = const RecipesScreen();
            break;
          case '/favorites':
            page = const FavoritesScreen();
            break;
          case '/add':
            page = Consumer<AuthProvider>(
                builder: (_, a, __) => a.loggedIn
                    ? const AddRecipeScreen()
                    : const AuthScreen(gated: true));
            break;
          case '/login':
            page = const AuthScreen();
            break;
          case '/signup':
            page = const AuthScreen(signup: true);
            break;
          default:
            page = const HomeScreen();
        }
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plately',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
