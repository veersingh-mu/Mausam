import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  ScreenBreakpoint breakpoint,
);

/// A declarative builder widget that selects UI layout depending on available width.
/// Uses [LayoutBuilder] so it works consistently for both root screens and nested components.
class ResponsiveLayout extends StatelessWidget {
  final ResponsiveWidgetBuilder compact;
  final ResponsiveWidgetBuilder? medium;
  final ResponsiveWidgetBuilder? expanded;

  const ResponsiveLayout({
    Key? key,
    required this.compact,
    this.medium,
    this.expanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveBreakpoints.fromWidth(constraints.maxWidth);
        switch (breakpoint) {
          case ScreenBreakpoint.compact:
            return compact(context, constraints, breakpoint);
          case ScreenBreakpoint.medium:
            if (medium != null) {
              return medium!(context, constraints, breakpoint);
            }
            return compact(context, constraints, breakpoint);
          case ScreenBreakpoint.expanded:
            if (expanded != null) {
              return expanded!(context, constraints, breakpoint);
            }
            if (medium != null) {
              return medium!(context, constraints, breakpoint);
            }
            return compact(context, constraints, breakpoint);
        }
      },
    );
  }
}

/// A container that centers its child and constrains its maximum width
/// to prevent awkward edge-to-edge stretching on large desktop monitors.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
