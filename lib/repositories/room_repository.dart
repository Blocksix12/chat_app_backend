import 'package:supabase/supabase.dart';
import '../config/database.dart';
import '../models/room_model.dart';

class RoomRepository {
  final SupabaseClient _client;

  RoomRepository({SupabaseClient? client})
      : _client = client ?? DatabaseConfig.client;

  static const String _tableName = 'rooms';

  Future<RoomModel> createRoom(RoomModel room) async {
    final response = await _client
        .from(_tableName)
        .insert(room.toMap())
        .select()
        .single();
    return RoomModel.fromMap(response);
  }

  Future<RoomModel?> getRoomById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return RoomModel.fromMap(response);
  }

  Future<List<RoomModel>> getRoomsByHost(String hostId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('host', hostId);

    return (response as List).map((e) => RoomModel.fromMap(e)).toList();
  }

  Future<RoomModel> updateRoom(RoomModel room) async {
    final response = await _client
        .from(_tableName)
        .update(room.toMap())
        .eq('id', room.id)
        .select()
        .single();
    return RoomModel.fromMap(response);
  }

  Future<void> deleteRoom(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}
