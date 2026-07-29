import '../core/exceptions/app_exception.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import '../repositories/user_repository.dart';

class UserService {
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;

  UserService({
    UserRepository? userRepository,
    ProfileRepository? profileRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _profileRepository = profileRepository ?? ProfileRepository();

  ///==========================================================
  /// GET PROFILE
  ///==========================================================
  Future<Map<String, dynamic>> getProfile(String userId) async {
    final user = await _userRepository.getUserById(userId);

    if (user == null) {
      throw NotFoundException("User not found");
    }

    final profile =
        await _profileRepository.getProfileByUserId(userId);

    return {
      "id": user.id,
      "username": user.username,
      "email": user.email,
      "phone": user.phone,
      "status": user.status,
      "created_at": user.createdAt.toIso8601String(),
      "profile": profile == null
          ? null
          : {
              "avatar_url": profile.avatarUrl,
              "full_name": profile.fullName,
              "bio": profile.bio,
              "address": profile.address,
              "updated_at": profile.updatedAt.toIso8601String(),
            }
    };
  }

  ///==========================================================
  /// UPDATE PROFILE
  ///==========================================================
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? address,
  }) async {
    final profile =
        await _profileRepository.getProfileByUserId(userId);

    if (profile == null) {
      throw NotFoundException("Profile not found");
    }

    final updatedProfile = ProfileModel(
      id: profile.id,
      userId: profile.userId,
      avatarUrl: avatarUrl ?? profile.avatarUrl,
      fullName: fullName ?? profile.fullName,
      bio: bio ?? profile.bio,
      address: address ?? profile.address,
      updatedAt: DateTime.now(),
    );

    final result =
        await _profileRepository.updateProfile(updatedProfile);

    return {
      "avatar_url": result.avatarUrl,
      "full_name": result.fullName,
      "bio": result.bio,
      "address": result.address,
      "updated_at": result.updatedAt.toIso8601String(),
    };
  }

  ///==========================================================
  /// SEARCH USERS
  ///==========================================================
  Future<List<Map<String, dynamic>>> searchUsers(
      String keyword) async {

    final users = await _userRepository.searchUsers(keyword);

    if (users.isEmpty) {
      return [];
    }

    final profiles = await _profileRepository.getProfilesByUserIds(
      users.map((e) => e.id).toList(),
    );

    final profileMap = {
      for (final p in profiles) p.userId: p,
    };

    return users.map((user) {

      final profile = profileMap[user.id];

      return {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "phone": user.phone,
        "status": user.status,
        "created_at": user.createdAt.toIso8601String(),

        "profile": profile == null
            ? null
            : {
                "avatar_url": profile.avatarUrl,
                "full_name": profile.fullName,
                "bio": profile.bio,
                "address": profile.address,
                "updated_at": profile.updatedAt.toIso8601String(),
              }
      };
    }).toList();
  }
}