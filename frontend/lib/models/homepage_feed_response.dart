import 'alert_model.dart';
import 'persona_type.dart';
import 'weather_card_model.dart';

class WeatherLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String? state;
  final String country;

  WeatherLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.state,
    this.country = 'India',
  });

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      name: json['name'] ?? 'New Delhi, India',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 28.6139,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.2090,
      state: json['state'],
      country: json['country'] ?? 'India',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherLocation &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}

class CurrentConditions {
  final double temperatureC;
  final double feelsLikeC;
  final String condition;
  final String icon;
  final double tempMinC;
  final double tempMaxC;
  final int humidityPct;
  final double windKph;
  final double pressureMb;
  final double uvIndex;
  final String airQualitySummary;

  CurrentConditions({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.condition,
    required this.icon,
    required this.tempMinC,
    required this.tempMaxC,
    required this.humidityPct,
    required this.windKph,
    required this.pressureMb,
    required this.uvIndex,
    required this.airQualitySummary,
  });

  factory CurrentConditions.fromJson(Map<String, dynamic> json) {
    return CurrentConditions(
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 30.0,
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble() ?? 33.0,
      condition: json['condition'] ?? 'Clear Sky',
      icon: json['icon'] ?? 'sunny',
      tempMinC: (json['temp_min_c'] as num?)?.toDouble() ?? 24.0,
      tempMaxC: (json['temp_max_c'] as num?)?.toDouble() ?? 34.0,
      humidityPct: json['humidity_pct'] ?? 55,
      windKph: (json['wind_kph'] as num?)?.toDouble() ?? 12.0,
      pressureMb: (json['pressure_mb'] as num?)?.toDouble() ?? 1012.0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 6.0,
      airQualitySummary: json['air_quality_summary'] ?? 'Moderate AQI',
    );
  }
}

class HomepageFeedResponse {
  final String userId;
  final WeatherLocation location;
  final CurrentConditions current;
  final List<SevereAlert> alerts;
  final List<WidgetCard> cards;
  final List<PersonaType> selectedPersonas;
  final DateTime timestamp;

  HomepageFeedResponse({
    required this.userId,
    required this.location,
    required this.current,
    required this.alerts,
    required this.cards,
    required this.selectedPersonas,
    required this.timestamp,
  });

  factory HomepageFeedResponse.fromJson(Map<String, dynamic> json) {
    return HomepageFeedResponse(
      userId: json['user_id'] ?? '',
      location: WeatherLocation.fromJson(json['location'] ?? {}),
      current: CurrentConditions.fromJson(json['current'] ?? {}),
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => SevereAlert.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      cards: (json['cards'] as List<dynamic>?)
              ?.map((e) => WidgetCard.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      selectedPersonas: (json['selected_personas'] as List<dynamic>?)
              ?.map((e) => PersonaTypeExtension.fromString(e.toString()))
              .toList() ??
          [],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
