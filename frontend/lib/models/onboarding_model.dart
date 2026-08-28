import 'persona_type.dart';

class SavedLocationItem {
  final String name;
  final double latitude;
  final double longitude;
  final bool isPrimary;
  final String label;

  SavedLocationItem({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isPrimary = false,
    this.label = 'Home',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'is_primary': isPrimary,
    'label': label,
  };

  factory SavedLocationItem.fromJson(Map<String, dynamic> json) => SavedLocationItem(
    name: json['name'] ?? 'New Delhi, India',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 28.6139,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 77.2090,
    isPrimary: json['is_primary'] ?? false,
    label: json['label'] ?? 'Home',
  );
}

class OnboardingPayload {
  final String userId;
  final List<PersonaType> selectedPersonas;
  final SavedLocationItem primaryLocation;
  final List<SavedLocationItem> savedLocations;

  OnboardingPayload({
    required this.userId,
    required this.selectedPersonas,
    required this.primaryLocation,
    required this.savedLocations,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'selected_personas': selectedPersonas.map((p) => p.value).toList(),
    'primary_location': primaryLocation.toJson(),
    'saved_locations': savedLocations.map((l) => l.toJson()).toList(),
  };
}
