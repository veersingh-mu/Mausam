import 'persona_type.dart';

class WidgetCard {
  final String id;
  final PersonaType persona;
  final String title;
  final String? subtitle;
  final int order;
  final bool isVisible;
  final DateTime lastUpdated;
  final Map<String, dynamic> data;

  WidgetCard({
    required this.id,
    required this.persona,
    required this.title,
    this.subtitle,
    required this.order,
    this.isVisible = true,
    required this.lastUpdated,
    required this.data,
  });

  factory WidgetCard.fromJson(Map<String, dynamic> json) {
    return WidgetCard(
      id: json['id'] ?? '',
      persona: PersonaTypeExtension.fromString(json['persona'] ?? 'health'),
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      order: json['order'] ?? 0,
      isVisible: json['is_visible'] ?? true,
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}

// --- Specialized Typed Data Wrappers ---

class HealthData {
  final int aqi;
  final String aqiCategory;
  final double pm25;
  final double pm10;
  final String pollenCount;
  final List<String> pollenTypes;
  final double uvIndex;
  final String uvCategory;
  final int humidityPct;
  final String healthAdvice;
  final bool sensitiveGroupWarning;

  HealthData({
    required this.aqi,
    required this.aqiCategory,
    required this.pm25,
    required this.pm10,
    required this.pollenCount,
    required this.pollenTypes,
    required this.uvIndex,
    required this.uvCategory,
    required this.humidityPct,
    required this.healthAdvice,
    required this.sensitiveGroupWarning,
  });

  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      aqi: map['aqi'] ?? 0,
      aqiCategory: map['aqi_category'] ?? 'Moderate',
      pm25: (map['pm25'] as num?)?.toDouble() ?? 0.0,
      pm10: (map['pm10'] as num?)?.toDouble() ?? 0.0,
      pollenCount: map['pollen_count'] ?? 'Moderate',
      pollenTypes: (map['pollen_types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      uvIndex: (map['uv_index'] as num?)?.toDouble() ?? 0.0,
      uvCategory: map['uv_category'] ?? 'Moderate',
      humidityPct: map['humidity_pct'] ?? 50,
      healthAdvice: map['health_advice'] ?? '',
      sensitiveGroupWarning: map['sensitive_group_warning'] ?? false,
    );
  }
}

class FitnessData {
  final String sunrise;
  final String sunset;
  final List<String> goldenRunningHours;
  final double currentTempC;
  final double feelsLikeC;
  final double windSpeedKmh;
  final String windDirection;
  final String heatStressIndex;
  final bool heatAlertActive;
  final int outdoorWorkoutScore;
  final String recommendation;

  FitnessData({
    required this.sunrise,
    required this.sunset,
    required this.goldenRunningHours,
    required this.currentTempC,
    required this.feelsLikeC,
    required this.windSpeedKmh,
    required this.windDirection,
    required this.heatStressIndex,
    required this.heatAlertActive,
    required this.outdoorWorkoutScore,
    required this.recommendation,
  });

  factory FitnessData.fromMap(Map<String, dynamic> map) {
    return FitnessData(
      sunrise: map['sunrise'] ?? '06:00 AM',
      sunset: map['sunset'] ?? '06:30 PM',
      goldenRunningHours: (map['golden_running_hours'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      currentTempC: (map['current_temp_c'] as num?)?.toDouble() ?? 28.0,
      feelsLikeC: (map['feels_like_c'] as num?)?.toDouble() ?? 30.0,
      windSpeedKmh: (map['wind_speed_kmh'] as num?)?.toDouble() ?? 10.0,
      windDirection: map['wind_direction'] ?? 'NW',
      heatStressIndex: map['heat_stress_index'] ?? 'Low',
      heatAlertActive: map['heat_alert_active'] ?? false,
      outdoorWorkoutScore: map['outdoor_workout_score'] ?? 80,
      recommendation: map['recommendation'] ?? '',
    );
  }
}

class MarineData {
  final String nextHighTide;
  final String nextLowTide;
  final double tideHeightM;
  final List<Map<String, dynamic>> tideSchedule;
  final double waveHeightM;
  final double swellPeriodSec;
  final double seaSurfaceTempC;
  final String swimSafety;
  final String flagColor;
  final String? incoisBulletin;

  MarineData({
    required this.nextHighTide,
    required this.nextLowTide,
    required this.tideHeightM,
    required this.tideSchedule,
    required this.waveHeightM,
    required this.swellPeriodSec,
    required this.seaSurfaceTempC,
    required this.swimSafety,
    required this.flagColor,
    this.incoisBulletin,
  });

  factory MarineData.fromMap(Map<String, dynamic> map) {
    return MarineData(
      nextHighTide: map['next_high_tide'] ?? '',
      nextLowTide: map['next_low_tide'] ?? '',
      tideHeightM: (map['tide_height_m'] as num?)?.toDouble() ?? 0.0,
      tideSchedule: (map['tide_schedule'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      waveHeightM: (map['wave_height_m'] as num?)?.toDouble() ?? 1.0,
      swellPeriodSec: (map['swell_period_sec'] as num?)?.toDouble() ?? 10.0,
      seaSurfaceTempC: (map['sea_surface_temp_c'] as num?)?.toDouble() ?? 28.0,
      swimSafety: map['swim_safety'] ?? 'Safe',
      flagColor: map['flag_color'] ?? 'Green',
      incoisBulletin: map['incois_bulletin'],
    );
  }
}

class DestinationWeather {
  final String city;
  final double tempC;
  final String condition;
  final int rainProbabilityPct;
  final String? severeWarning;

  DestinationWeather({
    required this.city,
    required this.tempC,
    required this.condition,
    required this.rainProbabilityPct,
    this.severeWarning,
  });

  factory DestinationWeather.fromMap(Map<String, dynamic> map) {
    return DestinationWeather(
      city: map['city'] ?? '',
      tempC: (map['temp_c'] as num?)?.toDouble() ?? 25.0,
      condition: map['condition'] ?? 'Clear',
      rainProbabilityPct: map['rain_probability_pct'] ?? 0,
      severeWarning: map['severe_warning'],
    );
  }
}

class TravelData {
  final List<DestinationWeather> savedDestinations;
  final String flightDisruptionRisk;
  final List<String> severeTravelAlerts;
  final List<String> packingTips;

  TravelData({
    required this.savedDestinations,
    required this.flightDisruptionRisk,
    required this.severeTravelAlerts,
    required this.packingTips,
  });

  factory TravelData.fromMap(Map<String, dynamic> map) {
    return TravelData(
      savedDestinations: (map['saved_destinations'] as List<dynamic>?)
              ?.map((e) => DestinationWeather.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      flightDisruptionRisk: map['flight_disruption_risk'] ?? 'Low',
      severeTravelAlerts: (map['severe_travel_alerts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      packingTips: (map['packing_tips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class FamilyData {
  final String schoolCommuteStatus;
  final double morningTempC;
  final double afternoonTempC;
  final String? rainWindowStart;
  final String? rainWindowEnd;
  final List<String> activeFamilyAlerts;
  final String clothingAdvisory;
  final bool outdoorPlaySafe;

  FamilyData({
    required this.schoolCommuteStatus,
    required this.morningTempC,
    required this.afternoonTempC,
    this.rainWindowStart,
    this.rainWindowEnd,
    required this.activeFamilyAlerts,
    required this.clothingAdvisory,
    required this.outdoorPlaySafe,
  });

  factory FamilyData.fromMap(Map<String, dynamic> map) {
    return FamilyData(
      schoolCommuteStatus: map['school_commute_status'] ?? 'Clear',
      morningTempC: (map['morning_temp_c'] as num?)?.toDouble() ?? 20.0,
      afternoonTempC: (map['afternoon_temp_c'] as num?)?.toDouble() ?? 30.0,
      rainWindowStart: map['rain_window_start'],
      rainWindowEnd: map['rain_window_end'],
      activeFamilyAlerts: (map['active_family_alerts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      clothingAdvisory: map['clothing_advisory'] ?? '',
      outdoorPlaySafe: map['outdoor_play_safe'] ?? true,
    );
  }
}

class AgriData {
  final double soilMoistureSurfacePct;
  final double soilMoistureRootzonePct;
  final double soilTempC;
  final double rainfallPrediction72hMm;
  final int rainExpectedDays;
  final bool frostAlertActive;
  final String frostRiskLevel;
  final List<String> cropAdvisories;
  final String irrigationRecommendation;
  final bool pesticideSprayingSuitable;

  AgriData({
    required this.soilMoistureSurfacePct,
    required this.soilMoistureRootzonePct,
    required this.soilTempC,
    required this.rainfallPrediction72hMm,
    required this.rainExpectedDays,
    required this.frostAlertActive,
    required this.frostRiskLevel,
    required this.cropAdvisories,
    required this.irrigationRecommendation,
    required this.pesticideSprayingSuitable,
  });

  factory AgriData.fromMap(Map<String, dynamic> map) {
    return AgriData(
      soilMoistureSurfacePct: (map['soil_moisture_surface_pct'] as num?)?.toDouble() ?? 45.0,
      soilMoistureRootzonePct: (map['soil_moisture_rootzone_pct'] as num?)?.toDouble() ?? 50.0,
      soilTempC: (map['soil_temp_c'] as num?)?.toDouble() ?? 25.0,
      rainfallPrediction72hMm: (map['rainfall_prediction_72h_mm'] as num?)?.toDouble() ?? 0.0,
      rainExpectedDays: map['rain_expected_days'] ?? 0,
      frostAlertActive: map['frost_alert_active'] ?? false,
      frostRiskLevel: map['frost_risk_level'] ?? 'None',
      cropAdvisories: (map['crop_advisories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      irrigationRecommendation: map['irrigation_recommendation'] ?? '',
      pesticideSprayingSuitable: map['pesticide_spraying_suitable'] ?? true,
    );
  }
}

class CommuterRoute {
  final String routeName;
  final String origin;
  final String destination;
  final int travelTimeMins;
  final int delayMins;
  final int roadVisibilityM;
  final String? hazardAlert;

  CommuterRoute({
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.travelTimeMins,
    required this.delayMins,
    required this.roadVisibilityM,
    this.hazardAlert,
  });

  factory CommuterRoute.fromMap(Map<String, dynamic> map) {
    return CommuterRoute(
      routeName: map['route_name'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      travelTimeMins: map['travel_time_mins'] ?? 0,
      delayMins: map['delay_mins'] ?? 0,
      roadVisibilityM: map['road_visibility_m'] ?? 1000,
      hazardAlert: map['hazard_alert'],
    );
  }
}

class CommuteData {
  final List<CommuterRoute> routes;
  final int dominantVisibilityM;
  final String visibilityStatus;
  final List<String> activeStormFogAlerts;
  final int recommendedDepartureDeltaMins;

  CommuteData({
    required this.routes,
    required this.dominantVisibilityM,
    required this.visibilityStatus,
    required this.activeStormFogAlerts,
    required this.recommendedDepartureDeltaMins,
  });

  factory CommuteData.fromMap(Map<String, dynamic> map) {
    return CommuteData(
      routes: (map['routes'] as List<dynamic>?)
              ?.map((e) => CommuterRoute.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      dominantVisibilityM: map['dominant_visibility_m'] ?? 1000,
      visibilityStatus: map['visibility_status'] ?? 'Good Visibility',
      activeStormFogAlerts: (map['active_storm_fog_alerts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendedDepartureDeltaMins: map['recommended_departure_delta_mins'] ?? 0,
    );
  }
}

class EventsData {
  final int eventComfortIndex;
  final String comfortCategory;
  final int rainProbabilityPct;
  final String? peakRainTime;
  final List<Map<String, dynamic>> hourlyForecast;
  final String windStability;
  final List<Map<String, dynamic>> extendedForecastDays;

  EventsData({
    required this.eventComfortIndex,
    required this.comfortCategory,
    required this.rainProbabilityPct,
    this.peakRainTime,
    required this.hourlyForecast,
    required this.windStability,
    required this.extendedForecastDays,
  });

  factory EventsData.fromMap(Map<String, dynamic> map) {
    return EventsData(
      eventComfortIndex: map['event_comfort_index'] ?? 80,
      comfortCategory: map['comfort_category'] ?? 'Pleasant',
      rainProbabilityPct: map['rain_probability_pct'] ?? 10,
      peakRainTime: map['peak_rain_time'],
      hourlyForecast: (map['hourly_forecast'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      windStability: map['wind_stability'] ?? 'Calm',
      extendedForecastDays: (map['extended_forecast_days'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
    );
  }
}
