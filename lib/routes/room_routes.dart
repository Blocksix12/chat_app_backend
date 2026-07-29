import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/room_controller.dart';
import '../core/middleware/auth_middleware.dart';

class RoomRoutes {
  final RoomController _controller;

  RoomRoutes({RoomController? controller})
      : _controller = controller ?? RoomController();

  Router get router {
    final router = Router();

    router.post('/direct', (Request req) => _controller.createDirectRoom(req));
    router.get('/', (Request req) => _controller.getUserRooms(req));
    router.get('/<id>', (Request req, String id) => _controller.getRoomDetail(req, id));

    return router;
  }

  Handler get handler {
    final pipeline = const Pipeline().addMiddleware(authMiddleware());
    return pipeline.addHandler(router.call);
  }
}
