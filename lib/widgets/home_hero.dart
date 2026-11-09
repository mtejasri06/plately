import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'dish_photo.dart';

/// Animated landing hero: floating illustrated plates, steam, wavy border.
class HomeHero extends StatefulWidget {
  const HomeHero({super.key});
  @override
  State<HomeHero> createState() => _HomeHeroState();
}

const _dishes = [
  ['Chicken biryani', 'Indian'], ['Pizza margherita', 'Italian'], ['Sushi', 'Japanese'],
  ['Taco', 'Mexican'], ['Pad thai', 'Thai'],
];

class _HomeHeroState extends State<HomeHero> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 860;
    final text = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) =>
              Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 30 * (1 - v)), child: child)),
          child: Text('A taste of home\nin every dish',
              textAlign: wide ? TextAlign.left : TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Georgia', fontFamilyFallback: ['serif'], fontSize: 44,
                  height: 1.1, color: AppTheme.spinach)),
        ),
        const SizedBox(height: 14),
        const Text('10 cuisines · 300 recipes · shared by home cooks',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 16, color: AppTheme.ink)),
        const SizedBox(height: 20),
        Wrap(spacing: 12, runSpacing: 8, children: [
          FilledButton(onPressed: () => Navigator.pushNamed(context, '/recipes'), child: const Text('Explore recipes')),
          OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: const BorderSide(color: AppTheme.spinach)),
              child: const Text('Join & post a recipe')),
        ]),
      ],
    );

    final plates = SizedBox(
      height: 340,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => LayoutBuilder(builder: (_, box) {
          final w = box.maxWidth;
          // x, y (fractions), size (fraction of width)
          const spots = [
            [.50, .46, .50], [.14, .30, .30], [.86, .28, .28], [.26, .80, .26], [.78, .80, .30],
          ];
          return Stack(children: [
            for (var i = 0; i < spots.length; i++)
              Positioned(
                left: w * spots[i][0] - w * spots[i][2] / 2,
                top: 340 * spots[i][1] - w * spots[i][2] / 2 + sin(2 * pi * _c.value + i * 1.3) * 10,
                width: w * spots[i][2],
                height: w * spots[i][2],
                child: Transform.rotate(
                  angle: sin(2 * pi * _c.value + i) * .05,
                  child: ClipOval(
                    child: DishPhoto(name: _dishes[i][0], cuisine: _dishes[i][1], color: AppTheme.spinach),
                  ),
                ),
              ),
          ]);
        }),
      ),
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFFFDF6EE),
      padding: EdgeInsets.fromLTRB(Responsive.sidePadding(context), 36, Responsive.sidePadding(context), 0),
      child: Column(children: [
        wide
            ? Row(children: [Expanded(child: text), const SizedBox(width: 24), Expanded(child: plates)])
            : Column(children: [text, const SizedBox(height: 16), plates]),
        const SizedBox(height: 8),
        SizedBox(height: 18, width: double.infinity, child: CustomPaint(painter: _WavePainter(_c))),
      ]),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Animation<double> a;
  _WavePainter(this.a) : super(repaint: a);
  @override
  void paint(Canvas c, Size s) {
    for (var row = 0; row < 2; row++) {
      final p = Path()..moveTo(0, s.height / 2 + row * 5 - 2);
      for (double x = 0; x <= s.width; x += 6) {
        p.lineTo(x, s.height / 2 + row * 5 - 2 + sin(x / 14 + a.value * 2 * pi * (row == 0 ? 1 : -1)) * 3);
      }
      c.drawPath(p, Paint()
        ..color = AppTheme.spinach.withOpacity(row == 0 ? .9 : .4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6);
    }
  }

  @override
  bool shouldRepaint(_WavePainter o) => false;
}
