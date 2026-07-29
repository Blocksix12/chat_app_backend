import 'package:supabase/supabase.dart';
import '../config/database.dart';
import '../models/room_member_model.dart';

class RoomMemberRepository {
  final SupabaseClient _client;

  RoomMemberRepository({SupabaseClient? client})
      : _client = client ?? DatabaseConfig.client;

  static const String _tableName = 'rooms_member';

  Future<RoomMemberModel> addMember(RoomMemberModel member) async {
    final response = await _client
        .from(_tableName)
        .insert(member.toMap())
        .select()
        .single();
    return RoomMemberModel.fromMap(response);
  }

  Future<List<RoomMemberModel>> getMembersByRoomId(String roomId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('room_id', roomId);

    return (response as List).map((e) => RoomMemberModel.fromMap(e)).toList();
  }

  Future<List<RoomMemberModel>> getRoomsForUser(String userId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_member', userId);

    return (response as List).map((e) => RoomMemberModel.fromMap(e)).toList();
  }

  Future<void> removeMember(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  Future<void> removeMemberFromRoom(String roomId, String userId) async {
    await _client
        .from(_tableName)
        .delete()
        .eq('room_id', roomId)
        .eq('user_member', userId);
  }
}
