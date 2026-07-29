import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';

class AuthRoutes {
  final AuthController _controller;

  AuthRoutes({AuthController? controller})
      : _controller = controller ?? AuthController();

  Router get router {
    final router = Router();

    router.post('/token', (Request req) => _controller.generateToken(req));
    router.post('/login', (Request req) => _controller.login(req));

    return router;
  }

  Handler get handler {
    return router.call;
  }
}
