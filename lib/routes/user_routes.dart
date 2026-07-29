import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../controllers/user_controller.dart';
import '../core/middleware/auth_middleware.dart';

class UserRoutes {
  final UserController _controller;

  UserRoutes({UserController? controller})
      : _controller = controller ?? UserController();

  Router get router {
    final router = Router();

    //---------------------------------------------------------
    // GET /api/users/profile
    //---------------------------------------------------------
    router.get(
      '/profile',
      authMiddleware()(
        (Request req) => _controller.getProfile(req),
      ),
    );

    //---------------------------------------------------------
    // PUT /api/users/profile
    //---------------------------------------------------------
    router.put(
      '/profile',
      authMiddleware()(
        (Request req) => _controller.updateProfile(req),
      ),
    );

    //---------------------------------------------------------
    // GET /api/users?keyword=
    //---------------------------------------------------------
    router.get(
      '/',
      authMiddleware()(
        (Request req) => _controller.searchUsers(req),
      ),
    );

    return router;
  }

  Handler get handler => router.call;
}