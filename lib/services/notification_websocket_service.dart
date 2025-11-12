import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/notification_ws.dart';

/// Service for managing WebSocket notifications using STOMP over SockJS
///
/// SockJS provides WebSocket emulation with automatic fallback to HTTP polling
/// if WebSocket is unavailable (corporate firewalls, proxies, etc.)
class NotificationWebSocketService {
  StompClient? _stompClient;
  final _notificationController = StreamController<NotificationWS>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  bool _isConnected = false;

  /// Stream of incoming notifications
  Stream<NotificationWS> get notifications => _notificationController.stream;

  /// Stream of connection state changes (true = connected, false = disconnected)
  Stream<bool> get connectionState => _connectionStateController.stream;

  /// Check if currently connected
  bool get isConnected => _isConnected;

  String? _userId;

  /// Connect to the WebSocket server using SockJS
  ///
  /// SockJS will:
  /// 1. Call /websocket/info to check available transports
  /// 2. Try native WebSocket first
  /// 3. Fall back to HTTP streaming/polling if WebSocket fails
  ///
  /// [baseUrl] - Base URL of the backend (e.g., 'localhost:8080' or 'api.example.com')
  /// [jwtToken] - JWT authentication token
  /// [userId] - User ID for subscribing to user-specific notifications (optional)
  /// [useSSL] - Whether to use https:// (true) or http:// (false)
  void connect({
    required String baseUrl,
    required String jwtToken,
    String? userId,
    bool useSSL = false,
  }) {
    _userId = userId;
    // SockJS uses http/https protocol, not ws/wss
    final protocol = useSSL ? 'https' : 'http';
    final sockJsUrl = '$protocol://$baseUrl/websocket';

    print('[NotificationWS] Connecting with SockJS to: $sockJsUrl');
    print('[NotificationWS] SockJS will first check: $sockJsUrl/info');
    print('[NotificationWS] Using Bearer token authentication');

    _stompClient = StompClient(
      config: StompConfig(
        url: sockJsUrl,

        // Enable SockJS - this adds fallback transports
        useSockJS: true,

        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        onWebSocketDone: _onWebSocketDone,

        // Debug logging enabled to see SockJS negotiation
        onDebugMessage: (message) => print('[STOMP Debug] $message'),

        // Pass JWT token in Authorization header
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $jwtToken',
        },

        // Connection options
        connectionTimeout: const Duration(seconds: 10),
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    print('[NotificationWS] Connected to WebSocket');
    _isConnected = true;
    _connectionStateController.add(true);

    // Subscribe to user-specific or broadcast notifications
    final destination = _userId != null
        ? '/users/$_userId/notifications'
        : '/topic/notifications';

    _stompClient!.subscribe(
      destination: destination,
      callback: _onNotificationReceived,
    );

    print('[NotificationWS] Subscribed to $destination');
  }

  void _onDisconnect(StompFrame frame) {
    print('[NotificationWS] Disconnected from WebSocket');
    _isConnected = false;
    _connectionStateController.add(false);
  }

  void _onStompError(StompFrame frame) {
    print('[NotificationWS] STOMP Error: ${frame.body}');
  }

  void _onWebSocketError(dynamic error) {
    print('[NotificationWS] WebSocket Error: $error');
    _isConnected = false;
    _connectionStateController.add(false);
  }

  void _onWebSocketDone() {
    print('[NotificationWS] WebSocket connection closed');
    _isConnected = false;
    _connectionStateController.add(false);
  }

  void _onNotificationReceived(StompFrame frame) {
    if (frame.body == null) {
      print('[NotificationWS] Received empty notification');
      return;
    }

    try {
      print('[NotificationWS] Raw message: ${frame.body}');
      final json = jsonDecode(frame.body!);
      final notification = NotificationWS.fromJson(json);
      print('[NotificationWS] Parsed notification: $notification');
      _notificationController.add(notification);
    } catch (e) {
      print('[NotificationWS] Error parsing notification: $e');
    }
  }

  /// Send a message to the server (optional, if your backend supports client messages)
  void sendMessage(String destination, String message) {
    if (_stompClient != null && _isConnected) {
      _stompClient!.send(destination: destination, body: message);
    } else {
      print('[NotificationWS] Cannot send message: not connected');
    }
  }

  /// Disconnect from the WebSocket server
  void disconnect() {
    print('[NotificationWS] Disconnecting...');
    _stompClient?.deactivate();
    _isConnected = false;
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionStateController.close();
  }
}
