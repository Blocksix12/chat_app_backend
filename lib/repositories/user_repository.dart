import 'package:supabase/supabase.dart';

import '../config/database.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository({SupabaseClient? client})
      : _client = client ?? DatabaseConfig.client;

  static const String _userTable = 'users';
  static const String _profileTable = 'profiles';

  //=========================================================
  // USER
  //=========================================================

  Future<UserModel> createUser(UserModel user) async {
    final response = await _client
        .from(_userTable)
        .insert(user.toMap())
        .select()
        .single();

    return UserModel.fromMap(response);
  }

  Future<UserModel?> getUserById(String id) async {
    final response = await _client
        .from(_userTable)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return UserModel.fromMap(response);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final response = await _client
        .from(_userTable)
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;

    return UserModel.fromMap(response);
  }

  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final response = await _client
        .from(_userTable)
        .select()
        .inFilter('id', ids);

    return (response as List)
        .map((e) => UserModel.fromMap(e))
        .toList();
  }

  Future<UserModel> updateUser(UserModel user) async {
    final response = await _client
        .from(_userTable)
        .update(user.toMap())
        .eq('id', user.id)
        .select()
        .single();

    return UserModel.fromMap(response);
  }

  Future<void> deleteUser(String id) async {
    await _client
        .from(_userTable)
        .delete()
        .eq('id', id);
  }

  //=========================================================
  // PROFILE
  //=========================================================

  Future<ProfileModel> createProfile(ProfileModel profile) async {
    final response = await _client
        .from(_profileTable)
        .insert(profile.toMap())
        .select()
        .single();

    return ProfileModel.fromMap(response);
  }

  Future<ProfileModel?> getProfileByUserId(String userId) async {
    final response = await _client
        .from(_profileTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;

    return ProfileModel.fromMap(response);
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final response = await _client
        .from(_profileTable)
        .update(profile.toMap())
        .eq('user_id', profile.userId)
        .select()
        .single();

    return ProfileModel.fromMap(response);
  }
    ///=========================================================
  /// GET USER BY PHONE
  ///=========================================================

  Future<UserModel?> getUserByPhone(String phone) async {
    final response = await _client
        .from(_userTable)
        .select()
        .eq('phone', phone)
        .maybeSingle();

    if (response == null) return null;

    return UserModel.fromMap(response);
  }

  ///=========================================================
  /// SEARCH USERS
  ///=========================================================

  Future<List<UserModel>> searchUsers(String keyword) async {
    final response = await _client
        .from(_userTable)
        .select()
        .or(
          'username.ilike.%$keyword%,email.ilike.%$keyword%',
        );

    return (response as List)
        .map((e) => UserModel.fromMap(e))
        .toList();
  }
}