import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_model.dart';
import '../models/homepage_feed_response.dart';
import 'homepage_feed_provider.dart';

class CitySearchState {
  final List<CityModel> allCities;
  final List<CityModel> filteredCities;
  final List<CityModel> recentCities;
  final Set<String> favoriteCityKeys;
  final String query;
  final bool isLoading;
  final bool isSelecting;
  final String? errorMessage;

  CitySearchState({
    required this.allCities,
    required this.filteredCities,
    required this.recentCities,
    required this.favoriteCityKeys,
    this.query = '',
    this.isLoading = false,
    this.isSelecting = false,
    this.errorMessage,
  });

  CitySearchState copyWith({
    List<CityModel>? allCities,
    List<CityModel>? filteredCities,
    List<CityModel>? recentCities,
    Set<String>? favoriteCityKeys,
    String? query,
    bool? isLoading,
    bool? isSelecting,
    String? errorMessage,
  }) {
    return CitySearchState(
      allCities: allCities ?? this.allCities,
      filteredCities: filteredCities ?? this.filteredCities,
      recentCities: recentCities ?? this.recentCities,
      favoriteCityKeys: favoriteCityKeys ?? this.favoriteCityKeys,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isSelecting: isSelecting ?? this.isSelecting,
      errorMessage: errorMessage,
    );
  }

  List<CityModel> get popularCities =>
      allCities.where((c) => c.isPopular).toList();

  bool isFavorite(CityModel city) =>
      favoriteCityKeys.contains('${city.cityName.toLowerCase()}_${city.state.toLowerCase()}');
}

class CitySearchNotifier extends StateNotifier<CitySearchState> {
  Timer? _debounceTimer;

  CitySearchNotifier()
      : super(CitySearchState(
          allCities: _defaultFallbackCities,
          filteredCities: _defaultFallbackCities,
          recentCities: [],
          favoriteCityKeys: {},
          isLoading: false,
        )) {
    loadCities();
  }

  /// Loads static city configuration from assets
  Future<void> loadCities() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/indian_cities.json');
      final List<dynamic> list = jsonDecode(jsonString);
      final loadedCities = list.map((e) => CityModel.fromJson(e)).toList();

      state = state.copyWith(
        allCities: loadedCities,
        filteredCities: loadedCities,
      );
    } catch (_) {
      // Keep using default fallback cities
    }
  }

  /// Handles search query input with 200-300ms debounce
  void onQueryChanged(String newQuery) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _applyFilter(newQuery);
    });
  }

  /// Direct synchronous filter for instant updates and unit tests
  void applyFilterDirect(String newQuery) {
    _debounceTimer?.cancel();
    _applyFilter(newQuery);
  }

  void _applyFilter(String newQuery) {
    final trimmed = newQuery.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        query: '',
        filteredCities: state.allCities,
        errorMessage: null,
      );
      return;
    }

    // Filter matching cities
    final scoredList = <MapEntry<CityModel, int>>[];
    for (final city in state.allCities) {
      final score = city.matchScore(trimmed);
      if (score != -1) {
        scoredList.add(MapEntry(city, score));
      }
    }

    // Sort by relevance score (starts-with > contains) then alphabetically
    scoredList.sort((a, b) {
      final scoreCompare = a.value.compareTo(b.value);
      if (scoreCompare != 0) return scoreCompare;
      return a.key.cityName.compareTo(b.key.cityName);
    });

    final results = scoredList.map((e) => e.key).toList();

    state = state.copyWith(
      query: trimmed,
      filteredCities: results,
      errorMessage: null,
    );
  }

  /// Selects a city, updates recents (max 5), and updates active location
  Future<bool> selectCity(CityModel city, WidgetRef ref) async {
    state = state.copyWith(isSelecting: true, errorMessage: null);

    try {
      // 1. Update Recently Searched list (deduplicate, most recent first, max 5)
      final updatedRecents = List<CityModel>.from(state.recentCities);
      updatedRecents.removeWhere((c) =>
          c.cityName.toLowerCase() == city.cityName.toLowerCase() &&
          c.state.toLowerCase() == city.state.toLowerCase());
      updatedRecents.insert(0, city);
      if (updatedRecents.length > 5) {
        updatedRecents.removeRange(5, updatedRecents.length);
      }

      state = state.copyWith(
        recentCities: updatedRecents,
        isSelecting: false,
      );

      // 2. Update Riverpod active location
      final newLocation = city.toWeatherLocation();
      ref.read(currentLocationProvider.notifier).state = newLocation;

      // 3. Invalidate homepage feed to trigger reload with newly selected city
      ref.invalidate(homepageFeedProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isSelecting: false,
        errorMessage: "Couldn't fetch weather for ${city.cityName}, please try again",
      );
      return false;
    }
  }

  /// Toggles favorite status for a city
  void toggleFavorite(CityModel city) {
    final key = '${city.cityName.toLowerCase()}_${city.state.toLowerCase()}';
    final updatedFavorites = Set<String>.from(state.favoriteCityKeys);

    if (updatedFavorites.contains(key)) {
      updatedFavorites.remove(key);
    } else {
      updatedFavorites.add(key);
    }

    state = state.copyWith(favoriteCityKeys: updatedFavorites);
  }

  /// Removes a single city from recent searches
  void removeRecentCity(CityModel city) {
    final updated = List<CityModel>.from(state.recentCities)
      ..removeWhere((c) =>
          c.cityName.toLowerCase() == city.cityName.toLowerCase() &&
          c.state.toLowerCase() == city.state.toLowerCase());
    state = state.copyWith(recentCities: updated);
  }

  /// Clears all recent searches
  void clearRecentSearches() {
    state = state.copyWith(recentCities: []);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  static final List<CityModel> _defaultFallbackCities = [
    CityModel(cityName: 'New Delhi', state: 'Delhi', latitude: 28.6139, longitude: 77.2090, isPopular: true, region: 'North'),
    CityModel(cityName: 'Mumbai', state: 'Maharashtra', latitude: 19.0760, longitude: 72.8777, isPopular: true, region: 'West'),
    CityModel(cityName: 'Bengaluru', state: 'Karnataka', latitude: 12.9716, longitude: 77.5946, isPopular: true, region: 'South'),
    CityModel(cityName: 'Chennai', state: 'Tamil Nadu', latitude: 13.0827, longitude: 80.2707, isPopular: true, region: 'South'),
    CityModel(cityName: 'Kolkata', state: 'West Bengal', latitude: 22.5726, longitude: 88.3639, isPopular: true, region: 'East'),
    CityModel(cityName: 'Hyderabad', state: 'Telangana', latitude: 17.3850, longitude: 78.4867, isPopular: true, region: 'South'),
    CityModel(cityName: 'Pune', state: 'Maharashtra', latitude: 18.5204, longitude: 73.8567, isPopular: true, region: 'West'),
    CityModel(cityName: 'Ahmedabad', state: 'Gujarat', latitude: 23.0225, longitude: 72.5714, isPopular: true, region: 'West'),
    CityModel(cityName: 'Jaipur', state: 'Rajasthan', latitude: 26.9124, longitude: 75.7873, isPopular: true, region: 'North'),
    CityModel(cityName: 'Lucknow', state: 'Uttar Pradesh', latitude: 26.8467, longitude: 80.9462, isPopular: true, region: 'North'),
    CityModel(cityName: 'Chandigarh', state: 'Chandigarh', latitude: 30.7333, longitude: 76.7794, isPopular: true, region: 'North'),
    CityModel(cityName: 'Kochi', state: 'Kerala', latitude: 9.9312, longitude: 76.2673, isPopular: true, region: 'South'),
    CityModel(cityName: 'Bhopal', state: 'Madhya Pradesh', latitude: 23.2599, longitude: 77.4126, isPopular: true, region: 'Central'),
    CityModel(cityName: 'Surat', state: 'Gujarat', latitude: 21.1702, longitude: 72.8311, isPopular: true, region: 'West'),
    CityModel(cityName: 'Nagpur', state: 'Maharashtra', latitude: 21.1458, longitude: 79.0882, isPopular: true, region: 'Central'),
    CityModel(cityName: 'Indore', state: 'Madhya Pradesh', latitude: 22.7196, longitude: 75.8577, isPopular: true, region: 'Central'),
    CityModel(cityName: 'Patna', state: 'Bihar', latitude: 25.5941, longitude: 85.1376, isPopular: true, region: 'East'),
    CityModel(cityName: 'Guwahati', state: 'Assam', latitude: 26.1445, longitude: 91.7362, isPopular: true, region: 'Northeast'),
    CityModel(cityName: 'Thiruvananthapuram', state: 'Kerala', latitude: 8.5241, longitude: 76.9366, isPopular: true, region: 'South'),
    CityModel(cityName: 'Shimla', state: 'Himachal Pradesh', latitude: 31.1048, longitude: 77.1734, isPopular: true, region: 'North'),
    CityModel(cityName: 'Srinagar', state: 'Jammu & Kashmir', latitude: 34.0837, longitude: 74.7973, isPopular: true, region: 'North'),
    CityModel(cityName: 'Goa (Panaji)', state: 'Goa', latitude: 15.4909, longitude: 73.8278, isPopular: true, region: 'West'),
    CityModel(cityName: 'Varanasi', state: 'Uttar Pradesh', latitude: 25.3176, longitude: 82.9739, isPopular: true, region: 'North'),
    CityModel(cityName: 'Bhubaneswar', state: 'Odisha', latitude: 20.2961, longitude: 85.8245, isPopular: true, region: 'East'),
    CityModel(cityName: 'Dehradun', state: 'Uttarakhand', latitude: 30.3165, longitude: 78.0322, isPopular: true, region: 'North'),
    CityModel(cityName: 'Amritsar', state: 'Punjab', latitude: 31.6340, longitude: 74.8723, isPopular: true, region: 'North'),
    CityModel(cityName: 'Visakhapatnam', state: 'Andhra Pradesh', latitude: 17.6868, longitude: 83.2185, isPopular: true, region: 'South'),
    CityModel(cityName: 'Agra', state: 'Uttar Pradesh', latitude: 27.1767, longitude: 78.0081, isPopular: true, region: 'North'),
  ];
}

final citySearchProvider = StateNotifierProvider<CitySearchNotifier, CitySearchState>((ref) {
  return CitySearchNotifier();
});
