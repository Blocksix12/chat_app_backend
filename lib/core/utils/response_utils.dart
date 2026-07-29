import 'dart:convert';
import 'package:shelf/shelf.dart';

class ResponseUtils {
  static Response success(dynamic data, {int statusCode = 200, String message = 'Success'}) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': true,
        'message': message,
        'data': data,
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  static Response error(String message, {int statusCode = 400, dynamic errors}) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'message': message,
        if (errors != null) 'errors': errors,
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
