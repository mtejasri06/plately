import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

/// Breakpoints: mobile < 600, tablet < 1024, desktop >= 1024.
class Responsive {
  static ScreenType of(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return ScreenType.mobile;
    if (w < 1024) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext c) => of(c) == ScreenType.mobile;
  static bool isDesktop(BuildContext c) => of(c) == ScreenType.desktop;

  static T value<T>(BuildContext c,
      {required T mobile, T? tablet, required T desktop}) {
    switch (of(c)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? desktop;
      case ScreenType.desktop:
        return desktop;
    }
  }

  /// Horizontal padding that also centres content on very wide screens.
  static double sidePadding(BuildContext c, {double maxWidth = 1200}) {
    final w = MediaQuery.of(c).size.width;
    final base = value(c, mobile: 16.0, tablet: 24.0, desktop: 32.0);
    return w > maxWidth ? (w - maxWidth) / 2 + base : base;
  }
}

/// Centres content and limits its width on large screens.
class ContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentWrapper({super.key, required this.child, this.maxWidth = 1200});

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.value(context, mobile: 16.0, tablet: 24.0, desktop: 32.0);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 20),
          child: child,
        ),
      ),
    );
  }
}
