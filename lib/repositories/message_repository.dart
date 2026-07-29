import 'package:supabase/supabase.dart';
import '../config/database.dart';
import '../models/message_model.dart';

class MessageRepository {
  final SupabaseClient _client;

  MessageRepository({SupabaseClient? client})
      : _client = client ?? DatabaseConfig.client;

  static const String _tableName = 'messages';

  Future<MessageModel> createMessage(MessageModel message) async {
    final response = await _client
        .from(_tableName)
        .insert(message.toMap())
        .select()
        .single();
    return MessageModel.fromMap(response);
  }

  Future<MessageModel?> getMessageById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MessageModel.fromMap(response);
  }

  Future<List<MessageModel>> getMessagesByRoomId(
    String roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => MessageModel.fromMap(e)).toList();
  }

  Future<MessageModel> updateMessageStatus(String id, String status) async {
    final response = await _client
        .from(_tableName)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return MessageModel.fromMap(response);
  }

  Future<void> deleteMessage(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}
