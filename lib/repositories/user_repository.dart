import 'package:supabase/supabase.dart';
import '../config/database.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository({SupabaseClient? client})
      : _client = client ?? DatabaseConfig.client;

  static const String _tableName = 'users';

  Future<UserModel> createUser(UserModel user) async {
    final response = await _client
        .from(_tableName)
        .insert(user.toMap())
        .select()
        .single();
    return UserModel.fromMap(response);
  }

  Future<UserModel?> getUserById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<UserModel> updateUser(UserModel user) async {
    final response = await _client
        .from(_tableName)
        .update(user.toMap())
        .eq('id', user.id)
        .select()
        .single();
    return UserModel.fromMap(response);
  }

  Future<void> deleteUser(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}
