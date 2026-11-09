import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class _NavItem {
  final String label;
  final String route;
  final IconData icon;
  const _NavItem(this.label, this.route, this.icon);
}

const _items = [
  _NavItem('Home', '/', Icons.home_rounded),
  _NavItem('Recipes', '/recipes', Icons.menu_book_rounded),
  _NavItem('Favourites', '/favorites', Icons.favorite_rounded),
  _NavItem('Add recipe', '/add', Icons.add_circle_rounded),
];

/// Shared page frame: top navigation on tablet/desktop, bottom bar on mobile.
class AppShell extends StatelessWidget {
  final int index;
  final Widget body;
  const AppShell({super.key, required this.index, required this.body});

  void _go(BuildContext context, int i) {
    if (i == index) return;
    Navigator.pushReplacementNamed(context, _items[i].route);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    final favCount =
        context.select<RecipeProvider, int>((p) => p.favoriteCount);

    Widget iconWithBadge(_NavItem item, {bool selected = false}) {
      final icon = Icon(item.icon);
      if (item.route == '/favorites' && favCount > 0) {
        return Badge(label: Text('$favCount'), child: icon);
      }
      return icon;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Responsive.sidePadding(context),
        title: Row(children: [
          const Icon(Icons.ramen_dining, color: AppTheme.spinach, size: 28),
          const SizedBox(width: 8),
          const Text('Plately',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ]),
        actions: mobile
            ? const [_AuthButton()]
            : [
                for (var i = 0; i < _items.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextButton.icon(
                      onPressed: () => _go(context, i),
                      icon: iconWithBadge(_items[i]),
                      label: Text(_items[i].label),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            i == index ? AppTheme.spinach : Colors.black54,
                        backgroundColor: i == index
                            ? AppTheme.spinach.withOpacity(0.10)
                            : null,
                      ),
                    ),
                  ),
                const _AuthButton(),
                SizedBox(width: Responsive.sidePadding(context) - 8),
              ],
      ),
      body: body,
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => _go(context, i),
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                      icon: iconWithBadge(item), label: item.label),
              ],
            )
          : null,
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loggedIn) {
      return PopupMenuButton<String>(
        tooltip: 'Account',
        onSelected: (_) => auth.logOut(),
        itemBuilder: (_) => [PopupMenuItem(value: 'out', child: Text('Log out (${auth.name})'))],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.spinach,
              child: Text(auth.name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
        ),
      );
    }
    final mobile = Responsive.isMobile(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Log in')),
      if (!mobile)
        FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            child: const Text('Sign up')),
    ]);
  }
}
