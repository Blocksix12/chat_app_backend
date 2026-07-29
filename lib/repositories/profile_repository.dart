import 'package:supabase/supabase.dart';

import '../config/database.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository({SupabaseClient? client})
      : _client = client ?? DatabaseConfig.client;

  static const String _table = "profiles";

  Future<ProfileModel> createProfile(ProfileModel profile) async {
    final response = await _client
        .from(_table)
        .insert(profile.toMap())
        .select()
        .single();

    return ProfileModel.fromMap(response);
  }

  Future<ProfileModel?> getProfile(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq("user_id", userId)
        .maybeSingle();

    if (response == null) return null;

    return ProfileModel.fromMap(response);
  }
}