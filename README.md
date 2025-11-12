# WebSocket Demo

A minimal Flutter app demonstrating WebSocket connectivity using STOMP over SockJS.

## Overview

This project shows how to:
- Connect to a WebSocket server with JWT authentication
- Subscribe to user-specific channels
- Receive and display real-time messages
- Handle connection state changes

## Quick Start

1. Update configuration in `lib/main.dart`:
```dart
final String baseUrl = "your-server.com";
final String jwtToken = "your-jwt-token";
final String userId = "your-user-id";
```

2. Run the app:
```bash
flutter run
```

## Architecture

### Files
- `lib/main.dart` - Simple UI with connect/disconnect controls
- `lib/services/notification_websocket_service.dart` - WebSocket connection logic
- `lib/models/notification_ws.dart` - Message data model

### How It Works

1. **Connection**: Uses STOMP client with SockJS fallback
2. **Authentication**: JWT token passed in Authorization header
3. **Subscription**: Subscribes to `/users/{userId}/notifications`
4. **Messages**: Received as JSON and parsed into NotificationWS objects

## Dependencies

- `stomp_dart_client` - STOMP protocol with SockJS support
