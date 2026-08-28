import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/persona_type.dart';
import '../models/onboarding_model.dart';
import '../core/network/api_client.dart';
import 'homepage_feed_provider.dart';

class UserPersonaState {
  final String userId;
  final List<PersonaType> selectedPersonas;
  final SavedLocationItem primaryLocation;
  final List<SavedLocationItem> savedLocations;
  final bool isLoading;
  final String? errorMessage;
  final bool onboardingCompleted;

  UserPersonaState({
    required this.userId,
    required this.selectedPersonas,
    required this.primaryLocation,
    required this.savedLocations,
    this.isLoading = false,
    this.errorMessage,
    this.onboardingCompleted = true,
  });

  UserPersonaState copyWith({
    String? userId,
    List<PersonaType>? selectedPersonas,
    SavedLocationItem? primaryLocation,
    List<SavedLocationItem>? savedLocations,
    bool? isLoading,
    String? errorMessage,
    bool? onboardingCompleted,
  }) {
    return UserPersonaState(
      userId: userId ?? this.userId,
      selectedPersonas: selectedPersonas ?? this.selectedPersonas,
      primaryLocation: primaryLocation ?? this.primaryLocation,
      savedLocations: savedLocations ?? this.savedLocations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

class UserPersonaNotifier extends StateNotifier<UserPersonaState> {
  final ApiClient _apiClient;
  final Ref _ref;

  UserPersonaNotifier(this._apiClient, this._ref)
      : super(UserPersonaState(
          userId: 'citizen_delhi_01',
          selectedPersonas: [
            PersonaType.health,
            PersonaType.fitness,
            PersonaType.commute,
            PersonaType.family
          ],
          primaryLocation: SavedLocationItem(
            name: 'New Delhi, India',
            latitude: 28.6139,
            longitude: 77.2090,
            isPrimary: true,
            label: 'Home',
          ),
          savedLocations: [
            SavedLocationItem(name: 'Goa Coast', latitude: 15.2993, longitude: 74.1240, label: 'Beach Trip'),
            SavedLocationItem(name: 'Shimla Hills', latitude: 31.1048, longitude: 77.1734, label: 'Vacation'),
          ],
        ));

  bool isSelected(PersonaType persona) {
    return state.selectedPersonas.contains(persona);
  }

  /// Toggles persona ON/OFF with empty-state guard (minimum 1 required)
  Future<bool> togglePersona(PersonaType persona) async {
    final current = List<PersonaType>.from(state.selectedPersonas);

    if (current.contains(persona)) {
      // Guard: At least 1 persona must remain active
      if (current.length <= 1) {
        state = state.copyWith(
          errorMessage: 'At least 1 persona must be selected to personalize your weather feed.',
        );
        return false;
      }
      current.remove(persona);
    } else {
      current.add(persona);
    }

    // Optimistic local state update
    state = state.copyWith(
      selectedPersonas: current,
      errorMessage: null,
    );

    // Invalidate homepage feed provider to trigger immediate UI re-render
    _ref.invalidate(homepageFeedProvider);

    // Asynchronous backend synchronization
    try {
      await _apiClient.put(
        '/api/v1/users/${state.userId}/personas',
        {
          'selected_personas': current.map((p) => p.value).toList(),
        },
      );
      return true;
    } catch (e) {
      // Background sync logged
      return true;
    }
  }

  /// Bulk updates personas
  Future<bool> updatePersonas(List<PersonaType> newPersonas) async {
    if (newPersonas.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Select at least 1 persona.',
      );
      return false;
    }

    state = state.copyWith(
      selectedPersonas: newPersonas,
      errorMessage: null,
    );

    _ref.invalidate(homepageFeedProvider);

    try {
      await _apiClient.put(
        '/api/v1/users/${state.userId}/personas',
        {
          'selected_personas': newPersonas.map((p) => p.value).toList(),
        },
      );
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Completes the 4-step onboarding wizard
  Future<bool> submitOnboarding(OnboardingPayload payload) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiClient.post('/api/v1/onboarding/complete', payload.toJson());
      state = state.copyWith(
        userId: payload.userId,
        selectedPersonas: payload.selectedPersonas,
        primaryLocation: payload.primaryLocation,
        savedLocations: payload.savedLocations,
        onboardingCompleted: true,
        isLoading: false,
      );
      _ref.invalidate(homepageFeedProvider);
      return true;
    } catch (e) {
      // Local fallback on network error
      state = state.copyWith(
        selectedPersonas: payload.selectedPersonas,
        primaryLocation: payload.primaryLocation,
        savedLocations: payload.savedLocations,
        onboardingCompleted: true,
        isLoading: false,
      );
      _ref.invalidate(homepageFeedProvider);
      return true;
    }
  }

  void addSavedLocation(SavedLocationItem location) {
    final updated = List<SavedLocationItem>.from(state.savedLocations)..add(location);
    state = state.copyWith(savedLocations: updated);
  }

  void removeSavedLocation(int index) {
    if (index >= 0 && index < state.savedLocations.length) {
      final updated = List<SavedLocationItem>.from(state.savedLocations)..removeAt(index);
      state = state.copyWith(savedLocations: updated);
    }
  }
}

final userPersonaProvider = StateNotifierProvider<UserPersonaNotifier, UserPersonaState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserPersonaNotifier(apiClient, ref);
});
