import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:chat_app_backend/app.dart';
import 'package:chat_app_backend/config/database.dart';
import 'package:chat_app_backend/config/env.dart';

void main(List<String> args) async {
  // Load environment variables from .env
  Env.init();

  // Initialize Supabase Database Connection
  await DatabaseConfig.initialize();

  // Create App Pipeline
  final handler = createAppHandler();

  // Server configuration
  final ip = InternetAddress.anyIPv4;
  final port = int.tryParse(Env.port) ?? 8080;

  final server = await io.serve(handler, ip, port);
  print('Server listening on http://${server.address.host}:${server.port}');
  print('WebSocket endpoint available at ws://${server.address.host}:${server.port}/ws?token=<jwt_token>');
}
