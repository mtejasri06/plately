# Plately – Flutter Web Recipe Application

Pick a cuisine, say how many people you are cooking for, and get scaled
ingredient quantities, step-by-step instructions, cooking time and calories.

## Run it
```bash
flutter create recipe_hub --platforms=web      # creates web/ and tooling files
cd recipe_hub
# copy this project's lib/, test/ and pubspec.yaml over the generated ones
flutter pub get
flutter run -d chrome                          # or: flutter build web
```

## Concept checklist
| Concept | Where |
|---|---|
| Widgets (Container, Row, Column, Stack, ListView, GridView, Card, buttons) | `screens/*`, `widgets/recipe_card.dart` (Stack header), Home (horizontal ListView + GridView) |
| Responsive UI | `utils/responsive.dart` (MediaQuery breakpoints, `ContentWrapper`), top nav vs bottom nav in `widgets/app_shell.dart`, `SliverGridDelegateWithMaxCrossAxisExtent`, two-column detail page |
| Navigation | Named routes + `onGenerateRoute` in `main.dart`, route arguments for recipe id |
| Animations | `Hero`, `AnimatedSwitcher`, `AnimatedContainer`, `AnimatedScale` (hover), `TweenAnimationBuilder` (staggered entrance, kcal counter, progress bar), custom page transitions |
| State management | `Provider` + `ChangeNotifier` (`providers/recipe_provider.dart`); `StatefulWidget` for form controllers and ingredient/step checklists |
| Theme & custom widgets | `theme/app_theme.dart`; `RecipeCard`, `ServingsSelector`, `CuisineChip`, `InfoPill`, `EmptyState`, `AppShell` |
| Forms & validation | Home servings form (1–20), Add Recipe form (required, ranges, ingredient-line parser) |

## Testing on different screen sizes
Run in Chrome, press F12, open the device toolbar and try 375 px (mobile),
768 px (tablet) and 1440 px (desktop). Take your screenshots of: Home, Recipes
(with a filter applied), Recipe detail (change servings), Favourites, and Add
Recipe (showing validation errors) at each size.

## v2 additions
- 10 cuisines x 30 recipes (300) with real dish photos (Wikipedia image lookup, needs internet)
- Animated home hero with floating dish photos (`widgets/home_hero.dart`)
- Login / Sign up (`screens/auth_screen.dart`, `providers/auth_provider.dart`) - posting a recipe requires login
- Comments on every recipe (`widgets/comments_section.dart`) - login required to post
- Auth, comments and user recipes are in-memory (lost on refresh). Add Firebase/Supabase for persistence.

## Photos (do this once)
`dart run tools/download_images.dart` (or `python3 tools/download_images.py`) downloads a real photo for every recipe into `assets/images/` (needs internet, takes a few minutes).
Then `flutter pub get && flutter run -d chrome`. Photos are bundled in the app, so they always show.
