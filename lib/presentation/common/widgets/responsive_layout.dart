import 'package:flutter/material.dart';
import '../../../core/theme/breakpoints.dart';

/// Responsive layout widget that adapts to screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width.isDesktop && desktop != null) {
          return desktop!;
        } else if (width.isTablet && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Centered content container with max width
class CenteredContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Breakpoints.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
