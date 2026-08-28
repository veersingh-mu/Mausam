import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/websocket_client.dart';
import '../models/alert_model.dart';

final websocketClientProvider = Provider<WebSocketClient>((ref) {
  final client = WebSocketClient();
  ref.onDispose(() {
    client.dispose();
  });
  return client;
});

final realtimeAlertStreamProvider = StreamProvider<SevereAlert>((ref) {
  final wsClient = ref.watch(websocketClientProvider);
  return wsClient.alertStream;
});

class ActiveAlertsNotifier extends StateNotifier<List<SevereAlert>> {
  ActiveAlertsNotifier() : super([]);

  void setInitialAlerts(List<SevereAlert> alerts) {
    state = alerts;
  }

  void pushNewAlert(SevereAlert newAlert) {
    // Avoid duplicate IDs
    if (!state.any((a) => a.id == newAlert.id)) {
      state = [newAlert, ...state];
    }
  }

  void dismissAlert(String alertId) {
    state = state.where((a) => a.id != alertId).toList();
  }
}

final activeAlertsProvider = StateNotifierProvider<ActiveAlertsNotifier, List<SevereAlert>>((ref) {
  final notifier = ActiveAlertsNotifier();
  ref.listen<AsyncValue<SevereAlert>>(realtimeAlertStreamProvider, (previous, next) {
    next.whenData((alert) {
      notifier.pushNewAlert(alert);
    });
  });
  return notifier;
});
