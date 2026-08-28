import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/models/weather_card_model.dart';
import 'package:mausam/models/persona_type.dart';
import 'package:mausam/widgets/cards/base_widget_card.dart';

void main() {
  testWidgets('WidgetCardFactory creates HealthWidgetCard with AQI', (WidgetTester tester) async {
    final healthCard = WidgetCard(
      id: 'card_health',
      persona: PersonaType.health,
      title: 'Health & Air Quality',
      subtitle: 'CPCB Air Quality Index',
      order: 0,
      isVisible: true,
      lastUpdated: DateTime.now(),
      data: {
        'aqi': 142,
        'aqi_category': 'Moderate',
        'pm25': 48.5,
        'pm10': 95.0,
        'pollen_count': 'Moderate',
        'uv_index': 6.5,
        'uv_category': 'Moderate',
        'humidity_pct': 60,
        'health_advice': 'Air quality is acceptable for outdoor activity.',
        'sensitive_group_warning': false,
      },
    );

    final cardWidget = WidgetCardFactory.createCard(healthCard);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: cardWidget,
        ),
      ),
    );

    expect(find.text('Health & Air Quality'), findsOneWidget);
    expect(find.text('142'), findsOneWidget);
    expect(find.text('MODERATE'), findsOneWidget);
  });
}
