import 'package:shelf/shelf.dart';

Middleware loggerMiddleware() {
  return logRequests();
}
