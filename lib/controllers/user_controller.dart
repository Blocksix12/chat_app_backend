import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../core/exceptions/app_exception.dart';
import '../core/middleware/auth_middleware.dart';
import '../core/utils/response_utils.dart';
import '../services/user_service.dart';

class UserController {
  final UserService _userService;

  UserController({UserService? userService})
      : _userService = userService ?? UserService();

  ///==========================================================
  /// GET /api/users/profile
  ///==========================================================
  Future<Response> getProfile(Request request) async {
    try {
      final userId = getUserIdFromRequest(request);

      final result = await _userService.getProfile(userId);

      return ResponseUtils.success(
        result,
        message: "Get profile successfully",
      );
    } on AppException catch (e) {
      return ResponseUtils.error(
        e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return ResponseUtils.error(
        e.toString(),
        statusCode: 500,
      );
    }
  }

  ///==========================================================
  /// PUT /api/users/profile
  ///==========================================================
  Future<Response> updateProfile(Request request) async {
    try {
      final userId = getUserIdFromRequest(request);

      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;

      final result = await _userService.updateProfile(
        userId: userId,
        fullName: body["full_name"],
        avatarUrl: body["avatar_url"],
        bio: body["bio"],
        address: body["address"],
      );

      return ResponseUtils.success(
        result,
        message: "Profile updated successfully",
      );
    } on AppException catch (e) {
      return ResponseUtils.error(
        e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return ResponseUtils.error(
        e.toString(),
        statusCode: 500,
      );
    }
  }

  ///==========================================================
  /// GET /api/users?keyword=
  ///==========================================================
  Future<Response> searchUsers(Request request) async {
    try {
      final keyword =
          request.url.queryParameters["keyword"] ?? "";

      final result =
          await _userService.searchUsers(keyword);

      return ResponseUtils.success(
        result,
        message: "Search users successfully",
      );
    } on AppException catch (e) {
      return ResponseUtils.error(
        e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return ResponseUtils.error(
        e.toString(),
        statusCode: 500,
      );
    }
  }
}