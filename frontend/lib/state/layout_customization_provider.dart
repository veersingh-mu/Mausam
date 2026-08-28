import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import 'homepage_feed_provider.dart';

class LayoutState {
  final List<String> cardOrder;
  final List<String> hiddenCards;
  final bool isLoading;

  LayoutState({
    required this.cardOrder,
    required this.hiddenCards,
    this.isLoading = false,
  });

  LayoutState copyWith({
    List<String>? cardOrder,
    List<String>? hiddenCards,
    bool? isLoading,
  }) {
    return LayoutState(
      cardOrder: cardOrder ?? this.cardOrder,
      hiddenCards: hiddenCards ?? this.hiddenCards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LayoutCustomizationNotifier extends StateNotifier<LayoutState> {
  final ApiClient _client;
  final String _userId;

  LayoutCustomizationNotifier(this._client, this._userId)
      : super(LayoutState(cardOrder: [], hiddenCards: [])) {
    loadLayout();
  }

  Future<void> loadLayout() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _client.fetchUserLayout(_userId);
      state = LayoutState(
        cardOrder: (res['card_order'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        hiddenCards: (res['hidden_cards'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void reorderCards(int oldIndex, int newIndex) {
    final list = List<String>.from(state.cardOrder);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(cardOrder: list);
  }

  void toggleCardVisibility(String cardId) {
    final hidden = List<String>.from(state.hiddenCards);
    if (hidden.contains(cardId)) {
      hidden.remove(cardId);
    } else {
      hidden.add(cardId);
    }
    state = state.copyWith(hiddenCards: hidden);
  }

  Future<bool> saveLayout() async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _client.updateUserLayout(
        userId: _userId,
        cardOrder: state.cardOrder,
        hiddenCards: state.hiddenCards,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

final layoutCustomizationProvider = StateNotifierProvider<LayoutCustomizationNotifier, LayoutState>((ref) {
  final client = ref.watch(apiClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  return LayoutCustomizationNotifier(client, userId);
});
