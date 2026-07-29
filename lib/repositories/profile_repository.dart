import 'package:supabase/supabase.dart';

import '../config/database.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository({SupabaseClient? client})
      : _client = client ?? DatabaseConfig.client;

  static const String _tableName = "profiles";

  Future<ProfileModel> createProfile(ProfileModel profile) async {
    final response = await _client
        .from(_tableName)
        .insert(profile.toMap())
        .select()
        .single();

    return ProfileModel.fromMap(response);
  }

  Future<ProfileModel?> getProfileByUserId(String userId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq("user_id", userId)
        .maybeSingle();

    if (response == null) return null;

    return ProfileModel.fromMap(response);
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final response = await _client
        .from(_tableName)
        .update({
          "avatar_url": profile.avatarUrl,
          "full_name": profile.fullName,
          "bio": profile.bio,
          "address": profile.address,
          "updated_at": DateTime.now().toIso8601String(),
        })
        .eq("user_id", profile.userId)
        .select()
        .single();

    return ProfileModel.fromMap(response);
  }

  Future<List<ProfileModel>> searchProfiles(String keyword) async {
    final response = await _client
        .from(_tableName)
        .select()
        .or("full_name.ilike.%$keyword%,bio.ilike.%$keyword%");

    return (response as List)
        .map((e) => ProfileModel.fromMap(e))
        .toList();
  }
  ///==========================================================
/// GET PROFILES BY USER IDS
///==========================================================
Future<List<ProfileModel>> getProfilesByUserIds(
    List<String> userIds) async {

  if (userIds.isEmpty) return [];

  final response = await _client
      .from(_tableName)
      .select()
      .inFilter("user_id", userIds);

  return (response as List)
      .map((e) => ProfileModel.fromMap(e))
      .toList();
}
}