import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/alert_model.dart';

class WebSocketClient {
  static const String defaultWsUrl = 'ws://localhost:8000/api/v1/alerts/ws';
  final String wsUrl;
  WebSocketChannel? _channel;
  StreamController<SevereAlert>? _alertController;
  Timer? _heartbeatTimer;
  bool _isConnected = false;

  WebSocketClient({this.wsUrl = defaultWsUrl});

  Stream<SevereAlert> get alertStream {
    _alertController ??= StreamController<SevereAlert>.broadcast();
    if (!_isConnected) {
      connect();
    }
    return _alertController!.stream;
  }

  void connect() {
    try {
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
        (event) {
          try {
            final Map<String, dynamic> jsonMap = jsonDecode(event);
            if (jsonMap['type'] == 'SEVERE_WEATHER_ALERT' && jsonMap['data'] != null) {
              final alert = SevereAlert.fromJson(jsonMap['data']);
              _alertController?.add(alert);
            }
          } catch (e) {
            debugPrint('Error parsing WebSocket alert message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _reconnect();
        },
      );

      // Periodic heartbeat ping every 30s
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_isConnected && _channel != null) {
          _channel!.sink.add('PING');
        }
      });
    } catch (e) {
      debugPrint('Failed to connect to WebSocket: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _alertController?.close();
  }
}
