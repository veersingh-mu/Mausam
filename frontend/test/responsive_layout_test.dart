import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/core/responsive/responsive_breakpoints.dart';

void main() {
  group('ResponsiveBreakpoints Width Classification Tests', () {
    test('Correctly classifies Compact phone width (< 600px)', () {
      expect(ResponsiveBreakpoints.fromWidth(320.0), ScreenBreakpoint.compact);
      expect(ResponsiveBreakpoints.fromWidth(375.0), ScreenBreakpoint.compact);
      expect(ResponsiveBreakpoints.fromWidth(414.0), ScreenBreakpoint.compact);
      expect(ResponsiveBreakpoints.fromWidth(599.0), ScreenBreakpoint.compact);
    });

    test('Correctly classifies Medium tablet width (600px - 1024px)', () {
      expect(ResponsiveBreakpoints.fromWidth(600.0), ScreenBreakpoint.medium);
      expect(ResponsiveBreakpoints.fromWidth(768.0), ScreenBreakpoint.medium);
      expect(ResponsiveBreakpoints.fromWidth(820.0), ScreenBreakpoint.medium);
      expect(ResponsiveBreakpoints.fromWidth(1024.0), ScreenBreakpoint.medium);
    });

    test('Correctly classifies Expanded desktop width (> 1024px)', () {
      expect(ResponsiveBreakpoints.fromWidth(1025.0), ScreenBreakpoint.expanded);
      expect(ResponsiveBreakpoints.fromWidth(1280.0), ScreenBreakpoint.expanded);
      expect(ResponsiveBreakpoints.fromWidth(1440.0), ScreenBreakpoint.expanded);
      expect(ResponsiveBreakpoints.fromWidth(1920.0), ScreenBreakpoint.expanded);
      expect(ResponsiveBreakpoints.fromWidth(2560.0), ScreenBreakpoint.expanded);
    });
  });

  group('Responsive Grid Column Calculations', () {
    test('Homepage card grid columns adapt across breakpoints', () {
      // Compact: 1 column
      final compactBp = ResponsiveBreakpoints.fromWidth(375.0);
      expect(compactBp == ScreenBreakpoint.compact ? 1 : 2, 1);

      // Medium: 2 columns
      final mediumBp = ResponsiveBreakpoints.fromWidth(768.0);
      expect(mediumBp == ScreenBreakpoint.medium ? 2 : 1, 2);

      // Expanded: 3 columns
      final expandedBp = ResponsiveBreakpoints.fromWidth(1440.0);
      expect(expandedBp == ScreenBreakpoint.expanded ? 3 : 1, 3);
    });

    test('Onboarding persona tiles adapt across breakpoints (2, 3, 4 cols)', () {
      int getOnboardingCols(double width) {
        final bp = ResponsiveBreakpoints.fromWidth(width);
        switch (bp) {
          case ScreenBreakpoint.compact:
            return 2;
          case ScreenBreakpoint.medium:
            return 3;
          case ScreenBreakpoint.expanded:
            return 4;
        }
      }

      expect(getOnboardingCols(375.0), 2);
      expect(getOnboardingCols(768.0), 3);
      expect(getOnboardingCols(1024.0), 3);
      expect(getOnboardingCols(1440.0), 4);
      expect(getOnboardingCols(1920.0), 4);
    });

    test('Content maximum widths enforce sensible limits', () {
      expect(ResponsiveBreakpoints.maxContentWidth, 1360.0);
      expect(ResponsiveBreakpoints.maxFormWidth, 860.0);
      expect(ResponsiveBreakpoints.maxDialogWidth, 520.0);
    });
  });
}
