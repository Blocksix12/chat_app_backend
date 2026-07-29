import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../core/exceptions/app_exception.dart';
import '../core/middleware/auth_middleware.dart';
import '../core/utils/response_utils.dart';
import '../services/room_service.dart';

class RoomController {
  final RoomService _roomService;

  RoomController({RoomService? roomService})
      : _roomService = roomService ?? RoomService();

  /// POST /api/rooms/direct
  /// Request body: { "target_user_id": "uuid" }
  Future<Response> createDirectRoom(Request request) async {
    try {
      final userId = getUserIdFromRequest(request);
      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final targetUserId = body['target_user_id'] as String?;
      if (targetUserId == null || targetUserId.isEmpty) {
        return ResponseUtils.error('target_user_id is required', statusCode: 400);
      }

      final room = await _roomService.createDirectRoom(userId, targetUserId);
      return ResponseUtils.success(
        room,
        statusCode: 201,
        message: 'Chat room created successfully',
      );
    } on AppException catch (e) {
      return ResponseUtils.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error('Failed to create room: ${e.toString()}', statusCode: 500);
    }
  }

  /// GET /api/rooms
  Future<Response> getUserRooms(Request request) async {
    try {
      final userId = getUserIdFromRequest(request);
      final rooms = await _roomService.getUserRooms(userId);
      return ResponseUtils.success(
        rooms,
        message: 'Fetched rooms successfully',
      );
    } on AppException catch (e) {
      return ResponseUtils.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error('Failed to fetch rooms: ${e.toString()}', statusCode: 500);
    }
  }

  /// GET /api/rooms/<id>
  Future<Response> getRoomDetail(Request request, String id) async {
    try {
      final userId = getUserIdFromRequest(request);
      final room = await _roomService.getRoomDetail(id, userId);
      return ResponseUtils.success(
        room,
        message: 'Fetched room detail successfully',
      );
    } on AppException catch (e) {
      return ResponseUtils.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error('Failed to fetch room detail: ${e.toString()}', statusCode: 500);
    }
  }
}
