import '../core/exceptions/app_exception.dart';
import '../core/security/bcrypt_helper.dart';
import '../core/security/jwt_helper.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;

  AuthService({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  /// Generate a valid JWT token for a given user ID
  String generateTokenForUser(String userId, {String? email, String? username}) {
    return JwtHelper.generateToken({
      'id': userId,
      'sub': userId,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
    });
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final user = await _userRepository.getUserByEmail(email);
    if (user == null) {
      throw UnauthorizedException('Invalid email or password');
    }

    final isPasswordValid = BcryptHelper.verifyPassword(password, user.password);
    if (!isPasswordValid) {
      throw UnauthorizedException('Invalid email or password');
    }

    final token = generateTokenForUser(user.id, email: user.email, username: user.username);
    return {
      'user': user.toPublicJson(),
      'token': token,
    };
  }
}
