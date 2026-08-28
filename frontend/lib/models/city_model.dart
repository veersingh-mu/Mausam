import 'homepage_feed_response.dart';

class CityModel {
  final String cityName;
  final String state;
  final double latitude;
  final double longitude;
  final bool isPopular;
  final bool isFavorite;
  final String region;

  CityModel({
    required this.cityName,
    required this.state,
    required this.latitude,
    required this.longitude,
    this.isPopular = false,
    this.isFavorite = false,
    this.region = 'India',
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityName: json['city_name'] ?? json['name'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isPopular: json['is_popular'] == true,
      isFavorite: json['is_favorite'] == true,
      region: json['region'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_name': cityName,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'is_popular': isPopular,
      'is_favorite': isFavorite,
      'region': region,
    };
  }

  CityModel copyWith({
    String? cityName,
    String? state,
    double? latitude,
    double? longitude,
    bool? isPopular,
    bool? isFavorite,
    String? region,
  }) {
    return CityModel(
      cityName: cityName ?? this.cityName,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPopular: isPopular ?? this.isPopular,
      isFavorite: isFavorite ?? this.isFavorite,
      region: region ?? this.region,
    );
  }

  WeatherLocation toWeatherLocation() {
    return WeatherLocation(
      name: '$cityName, $state',
      latitude: latitude,
      longitude: longitude,
      state: state,
      country: 'India',
    );
  }

  /// Calculates search relevance score (lower is higher priority, -1 = no match)
  int matchScore(String query) {
    if (query.isEmpty) return 0;
    final q = query.trim().toLowerCase();
    final c = cityName.toLowerCase();
    final s = state.toLowerCase();

    if (c == q) return 1; // Exact match
    if (c.startsWith(q)) return 2; // City starts with query
    if (s.startsWith(q)) return 3; // State starts with query
    if (c.contains(q)) return 4; // City contains query
    if (s.contains(q)) return 5; // State contains query
    return -1; // No match
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel &&
          runtimeType == other.runtimeType &&
          cityName.toLowerCase() == other.cityName.toLowerCase() &&
          state.toLowerCase() == other.state.toLowerCase();

  @override
  int get hashCode => cityName.toLowerCase().hashCode ^ state.toLowerCase().hashCode;
}
