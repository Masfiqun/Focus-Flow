import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= desktopBreakpoint && desktop != null) {
          return desktop!;
        }

        if (width >= tabletBreakpoint && tablet != null) {
          return tablet!;
        }

        return mobile;
      },
    );
  }
}