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
      title: 'WebSocket Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebSocketDemo(),
    );
  }
}

class WebSocketDemo extends StatefulWidget {
  const WebSocketDemo({super.key});

  @override
  State<WebSocketDemo> createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  final _wsService = NotificationWebSocketService();
  final List<NotificationWS> _messages = [];
  bool _isConnected = false;

  // Configuration - Update for your backend
  final String baseUrl = "travomate.online";
  final String jwtToken =
      "eyJraWQiOiI1SythZWhOMHgxcEVJUlwvXC9oUFd3aGJQZHdPYTVoRERDN3hzS0NlUHdraUE9IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJmMzY0MDgzMi1kMDcxLTcwZDctZmUxMC1kYjk5ZDgyOGRkNGUiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbiJdLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAuZXUtY2VudHJhbC0xLmFtYXpvbmF3cy5jb21cL2V1LWNlbnRyYWwtMV9kQ3BIbllOM2wiLCJjbGllbnRfaWQiOiI2NTF2amdxMzE5b3NuOTd0MWhuZW5rbDhyNCIsIm9yaWdpbl9qdGkiOiI1OWVmMjk0Ni1kZjY2LTRjNDAtOTM3OC1lNWJiODM2NTM5MmMiLCJldmVudF9pZCI6IjM3ZWEyYTVhLTllMmYtNDQzNS04OGJmLTU5MTczZDgwMjY2ZSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE3NjE1OTI3ODUsImV4cCI6MTc2Mjk4MjE3OSwiaWF0IjoxNzYyOTc4NTc5LCJqdGkiOiJjZjg3ZTFlOC02YTc4LTQwMzQtYTM1ZC1jMjNmNDA2YTg3NWYiLCJ1c2VybmFtZSI6ImYzNjQwODMyLWQwNzEtNzBkNy1mZTEwLWRiOTlkODI4ZGQ0ZSJ9.YOzkDMWsRtgi3L0IX6YdvFgc4qpzstVuAM4cY5sZlIXpjhl94KpOqxSsAaII2Vl57P3rxA2aGS0sU-EWRappnSpxBwdn5huUthx4x_swlqckvhMF-GHVQdg6XzhNEMX8_Frymb2wPnvB_VAVFAjjd2cmB5c0CL2-qV2upyiRAAaB92wF2rOcvObL8J2-52iDq7psXINnz7l3y_iXRoYTdS2tdTj5RruY1e3hCfvBqYu_XR39vMOEDHnAOKXCUFVEYKv0J-tDcgoojG1u1ND6Ydni4o9K8opeaH-cpjYkzPNr08__BT_cbSbpgALh4vspSQVB2UTK1WChFpGH07V42Q";
  final String userId = "f3640832-d071-70d7-fe10-db99d828dd4e";

  @override
  void initState() {
    super.initState();

    // Listen to connection state
    _wsService.connectionState.listen((connected) {
      setState(() => _isConnected = connected);
    });

    // Listen to messages
    _wsService.notifications.listen((notification) {
      setState(() => _messages.insert(0, notification));
    });

    // Auto-connect
    _connect();
  }

  void _connect() {
    _wsService.connect(
      baseUrl: baseUrl,
      jwtToken: jwtToken,
      userId: userId,
      useSSL: true,
    );
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
        title: const Text('WebSocket Demo'),
        actions: [
          Icon(
            _isConnected ? Icons.circle : Icons.circle_outlined,
            color: _isConnected ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Connection controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isConnected ? null : _connect,
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnected
                      ? () => _wsService.disconnect()
                      : null,
                  child: const Text('Disconnect'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _messages.isEmpty
                      ? null
                      : () => setState(() => _messages.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return ListTile(
                        title: Text(msg.content ?? 'No content'),
                        subtitle: Text('Type: ${msg.type ?? "Unknown"}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
