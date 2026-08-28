import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/homepage_feed_response.dart';
import '../models/persona_type.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final currentUserIdProvider = StateProvider<String>((ref) {
  return 'citizen_delhi_01';
});

final currentLocationProvider = StateProvider<WeatherLocation>((ref) {
  return WeatherLocation(
    name: 'New Delhi, India',
    latitude: 28.6139,
    longitude: 77.2090,
  );
});

final homepageFeedProvider = FutureProvider.autoDispose<HomepageFeedResponse>((ref) async {
  final client = ref.watch(apiClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  final location = ref.watch(currentLocationProvider);

  return client.fetchHomepageFeed(
    userId: userId,
    lat: location.latitude,
    lon: location.longitude,
    locationName: location.name,
  );
});

class PersonaNotifier extends StateNotifier<List<PersonaType>> {
  final ApiClient _client;
  final String _userId;

  PersonaNotifier(this._client, this._userId)
      : super([
          PersonaType.health,
          PersonaType.commute,
          PersonaType.fitness,
          PersonaType.family,
        ]) {
    loadUserPersonas();
  }

  Future<void> loadUserPersonas() async {
    try {
      final personas = await _client.fetchUserPersonas(_userId);
      state = personas;
    } catch (_) {}
  }

  Future<void> setPersonas(List<PersonaType> personas) async {
    state = personas;
    try {
      await _client.updateUserPersonas(
        userId: _userId,
        personas: personas,
      );
    } catch (_) {}
  }
}

final userPersonasProvider = StateNotifierProvider<PersonaNotifier, List<PersonaType>>((ref) {
  final client = ref.watch(apiClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  return PersonaNotifier(client, userId);
});
