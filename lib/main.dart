import 'package:flutter/material.dart';
import 'services/notification_websocket_service.dart';
import 'models/notification_ws.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Notifications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationHomePage(),
    );
  }
}

class NotificationHomePage extends StatefulWidget {
  const NotificationHomePage({super.key});

  @override
  State<NotificationHomePage> createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  final NotificationWebSocketService _wsService = NotificationWebSocketService();
  final List<NotificationWS> _notifications = [];
  bool _isConnected = false;

  // Configuration - Update these for your backend
  final String _baseUrl = 'localhost:8080';
  final String _jwtToken =
      "eyJraWQiOiI1SythZWhOMHgxcEVJUlwvXC9oUFd3aGJQZHdPYTVoRERDN3hzS0NlUHdraUE9IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJmMzY0MDgzMi1kMDcxLTcwZDctZmUxMC1kYjk5ZDgyOGRkNGUiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbiJdLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAuZXUtY2VudHJhbC0xLmFtYXpvbmF3cy5jb21cL2V1LWNlbnRyYWwtMV9kQ3BIbllOM2wiLCJjbGllbnRfaWQiOiI2NTF2amdxMzE5b3NuOTd0MWhuZW5rbDhyNCIsIm9yaWdpbl9qdGkiOiI1OWVmMjk0Ni1kZjY2LTRjNDAtOTM3OC1lNWJiODM2NTM5MmMiLCJldmVudF9pZCI6IjM3ZWEyYTVhLTllMmYtNDQzNS04OGJmLTU5MTczZDgwMjY2ZSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE3NjE1OTI3ODUsImV4cCI6MTc2MjkzNjU0MywiaWF0IjoxNzYyOTMyOTQzLCJqdGkiOiJmOWM1OGY0NC00ZmFkLTQ3ZGMtODdlMC1lNTUzMjRhYWIyZDgiLCJ1c2VybmFtZSI6ImYzNjQwODMyLWQwNzEtNzBkNy1mZTEwLWRiOTlkODI4ZGQ0ZSJ9.UmsC88B2Cvs8blv_knCXeuDHF7tSzCHz_kknaF4Nztxn_Mvl7eCzzwPpUAjAetGEthoN_iwA0hwFVeZ7jLl87HHfdHkPIMuW96MKJ8dYZy-kixsfk_1xRp59w6c8vgVbw4t_7kxvFBqpW8OZavtF-B_H7yFsmKGs-kwOh43LvotbkhJwlE-auCiuGO6AXrJG6aaUGvTVYMN6_OTqFdu4St29Q-Q_UuGbS0fgVDJj6Koqebh8b_p-99D-X8eCnLrKI-Tl2Wd43P4CDsxr1TYugRi871-61QiiY57a52sR8djlEFVcaBS61LCo0g9PVRrnme2a1HDPkTo20bfDBP4V0A";
  final String _userId = "f3640832-d071-70d7-fe10-db99d828dd4e"; // Current user ID
  final bool _useSSL = false; // Set to true for production (wss://)

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    // Listen to connection state changes
    _wsService.connectionState.listen((connected) {
      setState(() {
        _isConnected = connected;
      });
    });

    // Listen to incoming notifications
    _wsService.notifications.listen((notification) {
      setState(() {
        _notifications.insert(0, notification); // Add to top of list
      });
    });

    // Connect to WebSocket
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    _wsService.connect(
      baseUrl: _baseUrl,
      jwtToken: _jwtToken,
      userId: _userId, // Subscribe to user-specific channel
      useSSL: _useSSL,
    );
  }

  void _disconnectFromWebSocket() {
    _wsService.disconnect();
  }

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('WebSocket Notifications'),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isConnected ? null : _connectToWebSocket,
                  icon: const Icon(Icons.power),
                  label: const Text('Connect'),
                ),
                ElevatedButton.icon(
                  onPressed: _isConnected ? _disconnectFromWebSocket : null,
                  icon: const Icon(Icons.power_off),
                  label: const Text('Disconnect'),
                ),
                ElevatedButton.icon(
                  onPressed: _notifications.isEmpty ? null : _clearNotifications,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Notification count
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Notifications: ${_notifications.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Notifications list
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isConnected
                              ? 'Waiting for notifications...'
                              : 'Connect to receive notifications',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getNotificationColor(notification.type),
                            child: Icon(
                              _getNotificationIcon(notification.type),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            notification.content ?? 'No content',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (notification.type != null)
                                Text('Type: ${notification.type}'),
                              if (notification.itemId != null)
                                Text('Item ID: ${notification.itemId}'),
                              if (notification.id != null)
                                Text('ID: ${notification.id}'),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'BOOKING':
        return Colors.blue;
      case 'MESSAGE':
        return Colors.green;
      case 'EMAIL':
        return Colors.orange;
      case 'SMS':
        return Colors.purple;
      case 'INSTANT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'BOOKING':
        return Icons.book;
      case 'MESSAGE':
        return Icons.message;
      case 'EMAIL':
        return Icons.email;
      case 'SMS':
        return Icons.sms;
      case 'INSTANT':
        return Icons.notification_important;
      default:
        return Icons.notifications;
    }
  }
}
