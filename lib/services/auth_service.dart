import 'package:uuid/uuid.dart';

import '../core/exceptions/app_exception.dart';
import '../core/security/bcrypt_helper.dart';
import '../core/security/jwt_helper.dart';

import '../models/user_model.dart';
import '../models/profile_model.dart';

import '../repositories/user_repository.dart';
import '../repositories/profile_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;

  AuthService({
    UserRepository? userRepository,
    ProfileRepository? profileRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _profileRepository = profileRepository ?? ProfileRepository();

  ///==========================================================
  /// Generate JWT
  ///==========================================================
  String generateTokenForUser(
    String userId, {
    String? email,
    String? username,
  }) {
    return JwtHelper.generateToken({
      "id": userId,
      "sub": userId,
      if (email != null) "email": email,
      if (username != null) "username": username,
    });
  }

  ///==========================================================
  /// LOGIN
  ///==========================================================
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final user = await _userRepository.getUserByEmail(email);

    if (user == null) {
      throw UnauthorizedException("Invalid email or password");
    }

    final isPasswordValid =
        BcryptHelper.verifyPassword(password, user.password);

    if (!isPasswordValid) {
      throw UnauthorizedException("Invalid email or password");
    }

    final token = generateTokenForUser(
      user.id,
      email: user.email,
      username: user.username,
    );

    return {
      // "user": user.toPublicJson(),
      "token": token,
    };
  }

  ///==========================================================
  /// REGISTER
  ///==========================================================
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    //---------------------------------------------------------
    // Check Email
    //---------------------------------------------------------
    final existed = await _userRepository.getUserByEmail(email);

    if (existed != null) {
      throw AppException(
         "Email already exists",
           statusCode: 400,
);
    }

    //---------------------------------------------------------
    // Create User
    //---------------------------------------------------------
    final userId = const Uuid().v4();

    final hashedPassword =
        BcryptHelper.hashPassword(password);

    final user = UserModel(
      id: userId,
      email: email,
      username: username,
      phone: phone,
      password: hashedPassword,
      status: "ACTIVE",
      createdAt: DateTime.now(),
    );

    final createdUser =
        await _userRepository.createUser(user);

    //---------------------------------------------------------
    // Create Profile
    //---------------------------------------------------------
    final profile = ProfileModel(
      id: const Uuid().v4(),
      userId: createdUser.id,
      avatarUrl: "",
      fullName: username,
      bio: "",
      address: "",
      updatedAt: DateTime.now(),
    );

    await _profileRepository.createProfile(profile);

    //---------------------------------------------------------
    // Generate Token
    //---------------------------------------------------------
    final token = generateTokenForUser(
      createdUser.id,
      email: createdUser.email,
      username: createdUser.username,
    );

    return {
      // "user": createdUser.toPublicJson(),
      "token": token,
    };
  }
}