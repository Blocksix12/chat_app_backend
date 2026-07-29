import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/security/jwt_helper.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Maps userId -> List of active WebSocket channels (supports multi-device)
  final Map<String, List<WebSocketChannel>> _userSockets = {};

  void handleConnection(WebSocketChannel channel, String token) {
    final payload = JwtHelper.verifyToken(token);
    if (payload == null) {
      channel.sink.add(jsonEncode({
        'event': 'error',
        'message': 'Invalid or expired token',
      }));
      channel.sink.close();
      return;
    }

    final userId = (payload['id'] ?? payload['userId'] ?? payload['sub']) as String?;
    if (userId == null) {
      channel.sink.close();
      return;
    }

    _userSockets.putIfAbsent(userId, () => []).add(channel);
    print('WebSocket connected for user: $userId (Active sockets: ${_userSockets[userId]?.length})');

    // Send connection established confirmation
    channel.sink.add(jsonEncode({
      'event': 'connected',
      'data': {'userId': userId},
    }));

    channel.stream.listen(
      (message) {
        // Handle incoming client socket messages if needed
        print('Received socket message from $userId: $message');
      },
      onDone: () {
        _removeConnection(userId, channel);
      },
      onError: (error) {
        _removeConnection(userId, channel);
      },
    );
  }

  void _removeConnection(String userId, WebSocketChannel channel) {
    _userSockets[userId]?.remove(channel);
    if (_userSockets[userId]?.isEmpty ?? false) {
      _userSockets.remove(userId);
    }
    print('WebSocket disconnected for user: $userId');
  }

  /// Broadcasts a real-time event when a new room is created (e.g. friend added)
  /// so both users instantly get added to the room without querying the database!
  void notifyRoomCreated(List<String> targetUserIds, Map<String, dynamic> roomData) {
    final payload = jsonEncode({
      'event': 'room_created',
      'data': roomData,
    });

    for (final userId in targetUserIds) {
      final sockets = _userSockets[userId];
      if (sockets != null && sockets.isNotEmpty) {
        for (final socket in sockets) {
          socket.sink.add(payload);
        }
        print('Pushed room_created event to online user: $userId');
      }
    }
  }

  /// Broadcasts a real-time message event to room members
  void notifyNewMessage(List<String> memberUserIds, Map<String, dynamic> messageData) {
    final payload = jsonEncode({
      'event': 'new_message',
      'data': messageData,
    });

    for (final userId in memberUserIds) {
      final sockets = _userSockets[userId];
      if (sockets != null && sockets.isNotEmpty) {
        for (final socket in sockets) {
          socket.sink.add(payload);
        }
        print('Pushed new_message event to online user: $userId');
      }
    }
  }

  bool isUserOnline(String userId) {
    return _userSockets.containsKey(userId) && (_userSockets[userId]?.isNotEmpty ?? false);
  }
}
