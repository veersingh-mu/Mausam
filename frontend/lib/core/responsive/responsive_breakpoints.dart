import 'package:flutter/material.dart';

/// Screen size category breakpoints for Mausam
enum ScreenBreakpoint {
  /// Phone screens: width < 600px
  compact,

  /// Tablet portrait / small desktop window: width 600px - 1024px
  medium,

  /// Tablet landscape / desktop / large screens: width > 1024px
  expanded,
}

/// Unified responsive breakpoint utility for Mausam.
/// Centralizes all width-based layout logic across mobile, tablet, and desktop web.
class ResponsiveBreakpoints {
  // Breakpoint thresholds in logical pixels
  static const double compactMaxWidth = 599.0;
  static const double mediumMinWidth = 600.0;
  static const double mediumMaxWidth = 1024.0;
  static const double expandedMinWidth = 1025.0;

  /// Max container width for desktop readability (prevents infinite stretch on 4K/wide displays)
  static const double maxContentWidth = 1360.0;
  static const double maxFormWidth = 860.0;
  static const double maxDialogWidth = 520.0;

  /// Resolve current breakpoint from BuildContext MediaQuery width
  static ScreenBreakpoint of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return fromWidth(width);
  }

  /// Resolve breakpoint directly from width
  static ScreenBreakpoint fromWidth(double width) {
    if (width < mediumMinWidth) {
      return ScreenBreakpoint.compact;
    } else if (width <= mediumMaxWidth) {
      return ScreenBreakpoint.medium;
    } else {
      return ScreenBreakpoint.expanded;
    }
  }

  /// Convenience helpers
  static bool isCompact(BuildContext context) =>
      of(context) == ScreenBreakpoint.compact;

  static bool isMedium(BuildContext context) =>
      of(context) == ScreenBreakpoint.medium;

  static bool isExpanded(BuildContext context) =>
      of(context) == ScreenBreakpoint.expanded;

  static bool isTabletOrDesktop(BuildContext context) =>
      of(context) != ScreenBreakpoint.compact;

  /// Select responsive value based on active breakpoint
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
  }) {
    final bp = of(context);
    switch (bp) {
      case ScreenBreakpoint.compact:
        return compact;
      case ScreenBreakpoint.medium:
        return medium ?? compact;
      case ScreenBreakpoint.expanded:
        return expanded ?? medium ?? compact;
    }
  }

  /// Grid column count helper for home and module cards
  static int gridColumns(
    BuildContext context, {
    int compact = 1,
    int medium = 2,
    int expanded = 3,
  }) {
    return value(
      context,
      compact: compact,
      medium: medium,
      expanded: expanded,
    );
  }

  /// Adaptive horizontal and vertical page padding
  static EdgeInsets pagePadding(BuildContext context) {
    return value(
      context,
      compact: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      medium: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      expanded: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
    );
  }

  /// Adaptive typography scale factor
  static double fontScale(BuildContext context) {
    return value(
      context,
      compact: 1.0,
      medium: 1.04,
      expanded: 1.10,
    );
  }
}
