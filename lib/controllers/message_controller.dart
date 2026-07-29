import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../core/exceptions/app_exception.dart';
import '../core/middleware/auth_middleware.dart';
import '../core/utils/response_utils.dart';
import '../services/message_service.dart';

class MessageController {
  final MessageService _messageService;

  MessageController({MessageService? messageService})
      : _messageService = messageService ?? MessageService();

  /// POST /api/messages
  /// Request body: { "room_id": "uuid", "content": "hello" }
  Future<Response> sendMessage(Request request) async {
    try {
      final userId = getUserIdFromRequest(request);
      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final roomId = body['room_id'] as String?;
      final content = body['content'] as String?;

      if (roomId == null || roomId.isEmpty) {
        return ResponseUtils.error('room_id is required', statusCode: 400);
      }
      if (content == null || content.isEmpty) {
        return ResponseUtils.error('content is required', statusCode: 400);
      }

      final message = await _messageService.sendMessage(userId, roomId, content);
      return ResponseUtils.success(
        message.toMap(),
        statusCode: 201,
        message: 'Message sent successfully',
      );
    } on AppException catch (e) {
      return ResponseUtils.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error('Failed to send message: ${e.toString()}', statusCode: 500);
    }
  }

  /// GET /api/messages/room/<roomId>?limit=50&offset=0
  Future<Response> getRoomMessages(Request request, String roomId) async {
    try {
      final userId = getUserIdFromRequest(request);
      final queryParams = request.url.queryParameters;
      final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
      final offset = int.tryParse(queryParams['offset'] ?? '') ?? 0;

      final messages = await _messageService.getRoomMessages(
        roomId,
        userId,
        limit: limit,
        offset: offset,
      );

      return ResponseUtils.success(
        messages.map((m) => m.toMap()).toList(),
        message: 'Fetched room messages successfully',
      );
    } on AppException catch (e) {
      return ResponseUtils.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error('Failed to fetch messages: ${e.toString()}', statusCode: 500);
    }
  }
}
