import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../core/exceptions/app_exception.dart';
import '../core/utils/response_utils.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService;

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// POST /api/auth/token
  /// Request body: { "user_id": "319a3414-d031-4f39-bcfd-dbea8a645ee9" }
  Future<Response> generateToken(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final userId = (body['user_id'] ?? body['userId']) as String?;
      if (userId == null || userId.isEmpty) {
        return ResponseUtils.error('user_id is required', statusCode: 400);
      }

      final token = _authService.generateTokenForUser(userId);
      return ResponseUtils.success({
        'user_id': userId,
        'token': token,
      }, message: 'Token generated successfully');
    } on AppException catch (e) {
      return ResponseUtils.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error('Failed to generate token: ${e.toString()}', statusCode: 500);
    }
  }

  /// POST /api/auth/login
  /// Request body: { "email": "...", "password": "..." }
  Future<Response> login(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final email = body['email'] as String?;
      final password = body['password'] as String?;

      if (email == null || password == null) {
        return ResponseUtils.error('Email and password are required', statusCode: 400);
      }

      final result = await _authService.login(email, password);
      return ResponseUtils.success(result, message: 'Logged in successfully');
    } on AppException catch (e) {
      return ResponseUtils.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error('Login failed: ${e.toString()}', statusCode: 500);
    }
  }
}
