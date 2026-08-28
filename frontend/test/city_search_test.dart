import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mausam/models/city_model.dart';
import 'package:mausam/state/city_search_provider.dart';
import 'package:mausam/state/homepage_feed_provider.dart';
import 'package:mausam/screens/search/city_search_screen.dart';

void main() {
  group('CityModel Search & Relevance Tests', () {
    test('Calculates correct match score prioritizing starts-with over contains', () {
      final mumbai = CityModel(
        cityName: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0760,
        longitude: 72.8777,
      );

      final naviMumbai = CityModel(
        cityName: 'Navi Mumbai',
        state: 'Maharashtra',
        latitude: 19.0330,
        longitude: 73.0297,
      );

      // Exact match score
      expect(mumbai.matchScore('mumbai'), 1);

      // Starts-with score
      expect(mumbai.matchScore('mum'), 2);

      // Contains score (Navi Mumbai contains 'mum')
      expect(naviMumbai.matchScore('mum'), 4);

      // Higher priority for starts-with (score 2 < score 4)
      expect(mumbai.matchScore('mum') < naviMumbai.matchScore('mum'), isTrue);

      // No match
      expect(mumbai.matchScore('xyz'), -1);
    });

    test('Converts correctly to WeatherLocation for active location provider', () {
      final city = CityModel(
        cityName: 'Bengaluru',
        state: 'Karnataka',
        latitude: 12.9716,
        longitude: 77.5946,
      );

      final location = city.toWeatherLocation();
      expect(location.name, 'Bengaluru, Karnataka');
      expect(location.latitude, 12.9716);
      expect(location.longitude, 77.5946);
      expect(location.state, 'Karnataka');
      expect(location.country, 'India');
    });
  });

  group('CitySearchNotifier State Tests', () {
    test('Direct search filtering returns matching cities sorted by relevance', () {
      final notifier = CitySearchNotifier();

      // Search for "ben"
      notifier.applyFilterDirect('ben');
      final results = notifier.state.filteredCities;

      expect(results.isNotEmpty, isTrue);
      expect(results.first.cityName, 'Bengaluru');
    });

    test('Empty search query resets to full city list', () {
      final notifier = CitySearchNotifier();

      notifier.applyFilterDirect('kol');
      expect(notifier.state.filteredCities.length < notifier.state.allCities.length, isTrue);

      notifier.applyFilterDirect('');
      expect(notifier.state.filteredCities.length, notifier.state.allCities.length);
    });

    test('Recently Searched list adds items at index 0, deduplicates, and caps at 5', () async {
      final container = ProviderContainer();
      final notifier = container.read(citySearchProvider.notifier);

      final c1 = CityModel(cityName: 'Delhi', state: 'Delhi', latitude: 28.6, longitude: 77.2);
      final c2 = CityModel(cityName: 'Mumbai', state: 'Maharashtra', latitude: 19.0, longitude: 72.8);
      final c3 = CityModel(cityName: 'Bengaluru', state: 'Karnataka', latitude: 12.9, longitude: 77.5);
      final c4 = CityModel(cityName: 'Chennai', state: 'Tamil Nadu', latitude: 13.0, longitude: 80.2);
      final c5 = CityModel(cityName: 'Kolkata', state: 'West Bengal', latitude: 22.5, longitude: 88.3);
      final c6 = CityModel(cityName: 'Pune', state: 'Maharashtra', latitude: 18.5, longitude: 73.8);

      // Select cities
      await notifier.selectCity(c1, _MockRef(container));
      await notifier.selectCity(c2, _MockRef(container));
      await notifier.selectCity(c3, _MockRef(container));
      await notifier.selectCity(c4, _MockRef(container));
      await notifier.selectCity(c5, _MockRef(container));
      await notifier.selectCity(c6, _MockRef(container));

      final recents = container.read(citySearchProvider).recentCities;
      expect(recents.length, 5); // Capped at 5
      expect(recents.first.cityName, 'Pune'); // Most recent at top

      // Re-selecting c1 should move it to the top without duplicates
      await notifier.selectCity(c1, _MockRef(container));
      final updatedRecents = container.read(citySearchProvider).recentCities;
      expect(updatedRecents.length, 5);
      expect(updatedRecents.first.cityName, 'Delhi');
      expect(updatedRecents.where((c) => c.cityName == 'Delhi').length, 1);
    });

    test('Favorite cities toggle adds and removes from favorites set', () {
      final notifier = CitySearchNotifier();
      final city = CityModel(cityName: 'Jaipur', state: 'Rajasthan', latitude: 26.9, longitude: 75.7);

      expect(notifier.state.isFavorite(city), isFalse);

      notifier.toggleFavorite(city);
      expect(notifier.state.isFavorite(city), isTrue);

      notifier.toggleFavorite(city);
      expect(notifier.state.isFavorite(city), isFalse);
    });
  });

  group('CitySearchScreen Widget Tests', () {
    testWidgets('Renders search bar with placeholder and popular cities by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CitySearchScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Search city in India...'), findsOneWidget);
      expect(find.text('POPULAR INDIAN CITIES'), findsOneWidget);
      expect(find.text('New Delhi'), findsWidgets);
      expect(find.text('Mumbai'), findsWidgets);
    });

    testWidgets('Typing in search bar filters cities and displays empty state when not found', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CitySearchScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Bengaluru');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Karnataka'), findsWidgets);

      // Enter non-matching query
      await tester.enterText(find.byType(TextField), 'xyznonexistentcity');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('No matching city found'), findsOneWidget);
    });
  });
}

class _MockRef implements WidgetRef {
  final ProviderContainer container;
  _MockRef(this.container);

  @override
  T read<T>(ProviderListenable<T> provider) => container.read(provider);

  @override
  T watch<T>(AlwaysAliveProviderListenable<T> provider) => container.read(provider);

  @override
  T refresh<T>(Refreshable<T> provider) => container.refresh(provider);

  @override
  void invalidate(ProviderOrFamily provider) => container.invalidate(provider);

  @override
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) => container.listen(provider, listener, onError: onError);

  @override
  bool exists(ProviderBase<Object?> provider) => container.exists(provider);

  @override
  BuildContext get context => throw UnimplementedError();

  @override
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) => container.listen(provider, listener, onError: onError, fireImmediately: fireImmediately);
}
