import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/notification_ws.dart';

/// Simple WebSocket service using STOMP over SockJS
class NotificationWebSocketService {
  StompClient? _stompClient;
  final _notificationController = StreamController<NotificationWS>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();
  String? _userId;

  Stream<NotificationWS> get notifications => _notificationController.stream;
  Stream<bool> get connectionState => _connectionStateController.stream;

  /// Connect to WebSocket server
  void connect({
    required String baseUrl,
    required String jwtToken,
    String? userId,
    bool useSSL = false,
  }) {
    _userId = userId;
    final protocol = useSSL ? 'https' : 'http';
    final sockJsUrl = '$protocol://$baseUrl/websocket';

    _stompClient = StompClient(
      config: StompConfig(
        url: sockJsUrl,
        useSockJS: true,
        onConnect: _onConnect,
        onDisconnect: (frame) => _connectionStateController.add(false),
        webSocketConnectHeaders: {'Authorization': 'Bearer $jwtToken'},
        connectionTimeout: const Duration(seconds: 10),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _connectionStateController.add(true);

    final destination = _userId != null
        ? '/users/$_userId/notifications'
        : '/topic/notifications';

    _stompClient!.subscribe(
      destination: destination,
      callback: _onMessage,
    );
  }

  void _onMessage(StompFrame frame) {
    if (frame.body != null) {
      try {
        final json = jsonDecode(frame.body!);
        final notification = NotificationWS.fromJson(json);
        _notificationController.add(notification);
      } catch (e) {
        // Silently ignore parsing errors
      }
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionStateController.close();
  }
}
