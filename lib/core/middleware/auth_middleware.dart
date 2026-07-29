import 'package:shelf/shelf.dart';
import '../security/jwt_helper.dart';
import '../utils/response_utils.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return ResponseUtils.error('Missing or invalid Authorization header', statusCode: 401);
      }

      final token = authHeader.substring(7);
      final payload = JwtHelper.verifyToken(token);

      if (payload == null) {
        return ResponseUtils.error('Invalid or expired token', statusCode: 401);
      }

      final updatedRequest = request.change(context: {
        'user': payload,
        'userId': payload['id'] ?? payload['userId'] ?? payload['sub'],
      });
      return await innerHandler(updatedRequest);
    };
  };
}

String getUserIdFromRequest(Request request) {
  final userId = request.context['userId'] as String?;
  if (userId == null) {
    throw Exception('User ID not found in request context');
  }
  return userId;
}
