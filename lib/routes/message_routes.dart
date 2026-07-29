import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/message_controller.dart';
import '../core/middleware/auth_middleware.dart';

class MessageRoutes {
  final MessageController _controller;

  MessageRoutes({MessageController? controller})
      : _controller = controller ?? MessageController();

  Router get router {
    final router = Router();

    router.post('/', (Request req) => _controller.sendMessage(req));
    router.get('/room/<roomId>', (Request req, String roomId) => _controller.getRoomMessages(req, roomId));

    return router;
  }

  Handler get handler {
    final pipeline = const Pipeline().addMiddleware(authMiddleware());
    return pipeline.addHandler(router.call);
  }
}
