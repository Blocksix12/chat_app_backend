import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'core/middleware/cors_middleware.dart';
import 'core/middleware/logger_middleware.dart';
import 'routes/auth_routes.dart';
import 'routes/message_routes.dart';
import 'routes/room_routes.dart';
import 'services/websocket_service.dart';

Handler createAppHandler() {
  final router = Router();

  // Root Health Check Route
  router.get('/', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'online',
        'message': 'Dart Chat App Backend Server is running!',
        'endpoints': {
          'auth_token': 'POST /api/auth/token',
          'auth_login': 'POST /api/auth/login',
          'create_direct_room': 'POST /api/rooms/direct',
          'get_user_rooms': 'GET /api/rooms',
          'get_room_detail': 'GET /api/rooms/<id>',
          'send_message': 'POST /api/messages',
          'get_messages': 'GET /api/messages/room/<roomId>',
          'websocket': 'WS /ws?token=<token>',
        }
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  // API Routes
  router.mount('/api/auth/', AuthRoutes().handler);
  router.mount('/api/auth', AuthRoutes().handler);

  router.mount('/api/rooms/', RoomRoutes().handler);
  router.mount('/api/rooms', RoomRoutes().handler);

  router.mount('/api/messages/', MessageRoutes().handler);
  router.mount('/api/messages', MessageRoutes().handler);

  // WebSocket Route: ws://<host>:<port>/ws?token=<jwt_token>
  router.get('/ws', (Request request) {
    final token = request.url.queryParameters['token'];
    if (token == null || token.isEmpty) {
      return Response.forbidden('WebSocket connection requires a valid token query parameter');
    }

    return webSocketHandler((webSocket) {
      WebSocketService().handleConnection(webSocket, token);
    })(request);
  });

  // Global Middleware Pipeline
  final pipeline = const Pipeline()
      .addMiddleware(loggerMiddleware())
      .addMiddleware(corsMiddleware());

  return pipeline.addHandler(router.call);
}
