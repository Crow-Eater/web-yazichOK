/// Screen breakpoints for responsive design
class Breakpoints {
  Breakpoints._();

  /// Mobile devices (< 768px)
  static const double mobile = 768;

  /// Tablet devices (768px - 1024px)
  static const double tablet = 1024;

  /// Desktop devices (> 1024px)
  static const double desktop = 1024;

  /// Maximum content width for readability
  static const double maxContentWidth = 1200;

  /// Maximum reading width for articles
  static const double maxReadingWidth = 800;
}

/// Helper extension for responsive design
extension ResponsiveContext on double {
  bool get isMobile => this < Breakpoints.mobile;
  bool get isTablet => this >= Breakpoints.mobile && this < Breakpoints.desktop;
  bool get isDesktop => this >= Breakpoints.desktop;
}
