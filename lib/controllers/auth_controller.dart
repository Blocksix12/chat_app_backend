import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../core/exceptions/app_exception.dart';
import '../core/utils/response_utils.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService;

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// ==========================================================
  /// POST /api/auth/token
  /// ==========================================================
  Future<Response> generateToken(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final userId = (body['user_id'] ?? body['userId']) as String?;

      if (userId == null || userId.isEmpty) {
        return ResponseUtils.error(
          'user_id is required',
          statusCode: 400,
        );
      }

      final token = _authService.generateTokenForUser(userId);

      return ResponseUtils.success(
        {
          'user_id': userId,
          'token': token,
        },
        message: 'Token generated successfully',
      );
    } on AppException catch (e) {
      return ResponseUtils.error(
        e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return ResponseUtils.error(
        'Failed to generate token: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// ==========================================================
  /// POST /api/auth/login
  /// ==========================================================
  Future<Response> login(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final email = body['email'] as String?;
      final password = body['password'] as String?;

      if (email == null || password == null) {
        return ResponseUtils.error(
          'Email and password are required',
          statusCode: 400,
        );
      }

      final result = await _authService.login(
        email,
        password,
      );

      return ResponseUtils.success(
        result,
        message: 'Logged in successfully',
      );
    } on AppException catch (e) {
      return ResponseUtils.error(
        e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return ResponseUtils.error(
        'Login failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// ==========================================================
  /// POST /api/auth/register
  /// ==========================================================
  Future<Response> register(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final username = body['username'] as String?;
      final email = body['email'] as String?;
      final phone = body['phone'] as String?;
      final password = body['password'] as String?;


      if (username == null ||
          username.isEmpty ||
          email == null ||
          email.isEmpty ||
          phone == null ||
          phone.isEmpty ||
          password == null ||
          password.isEmpty) {
        return ResponseUtils.error(
          "Username, email and password are required",
          statusCode: 400,
        );
      }

      final result = await _authService.register(
        username: username,
        email: email,
        phone: phone,
        password: password,
      );

      return ResponseUtils.success(
        result,
        message: "Registered successfully",
      );
    } on AppException catch (e) {
      return ResponseUtils.error(
        e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return ResponseUtils.error(
        "Register failed: ${e.toString()}",
        statusCode: 500,
      );
    }
  }
}