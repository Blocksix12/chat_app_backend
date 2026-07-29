class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException(this.message, {this.statusCode = 400});

  @override
  String toString() => 'AppException: $message (Code: $statusCode)';
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized access'])
      : super(message, statusCode: 401);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found'])
      : super(message, statusCode: 404);
}

class BadRequestException extends AppException {
  BadRequestException([String message = 'Bad request'])
      : super(message, statusCode: 400);
}

class RoomNotFoundException extends NotFoundException {
  RoomNotFoundException([String message = 'Chat room not found'])
      : super(message);
}

class NotRoomMemberException extends AppException {
  NotRoomMemberException([String message = 'You are not a member of this chat room'])
      : super(message, statusCode: 403);
}

class MessageNotFoundException extends NotFoundException {
  MessageNotFoundException([String message = 'Message not found'])
      : super(message);
}
