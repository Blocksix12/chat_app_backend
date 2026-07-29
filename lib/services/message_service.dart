import 'package:uuid/uuid.dart';
import '../core/exceptions/app_exception.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';
import '../repositories/room_member_repository.dart';
import 'websocket_service.dart';

class MessageService {
  final MessageRepository _messageRepository;
  final RoomMemberRepository _roomMemberRepository;
  final WebSocketService _webSocketService;

  MessageService({
    MessageRepository? messageRepository,
    RoomMemberRepository? roomMemberRepository,
    WebSocketService? webSocketService,
  })  : _messageRepository = messageRepository ?? MessageRepository(),
        _roomMemberRepository = roomMemberRepository ?? RoomMemberRepository(),
        _webSocketService = webSocketService ?? WebSocketService();

  /// Send a chat message into a room
  /// Validates membership and broadcasts real-time `new_message` socket event
  Future<MessageModel> sendMessage(
    String senderId,
    String roomId,
    String content,
  ) async {
    if (content.trim().isEmpty) {
      throw BadRequestException('Message content cannot be empty');
    }

    // Verify sender is a member of the room
    final members = await _roomMemberRepository.getMembersByRoomId(roomId);
    final isMember = members.any((m) => m.userMember == senderId);
    if (!isMember) {
      throw NotRoomMemberException('You are not a member of this room');
    }

    final now = DateTime.now();
    final message = MessageModel(
      id: const Uuid().v4(),
      roomId: roomId,
      senderId: senderId,
      content: content.trim(),
      status: 'sent',
      createdAt: now,
      updatedAt: now,
    );

    final savedMessage = await _messageRepository.createMessage(message);

    // Broadcast new message event via WebSocket to room members
    final memberUserIds = members.map((m) => m.userMember).toList();
    _webSocketService.notifyNewMessage(memberUserIds, savedMessage.toMap());

    return savedMessage;
  }

  /// Get message history for a chat room
  Future<List<MessageModel>> getRoomMessages(
    String roomId,
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    // Verify requesting user is a member of the room
    final members = await _roomMemberRepository.getMembersByRoomId(roomId);
    final isMember = members.any((m) => m.userMember == userId);
    if (!isMember) {
      throw NotRoomMemberException('You are not a member of this room');
    }

    return await _messageRepository.getMessagesByRoomId(
      roomId,
      limit: limit,
      offset: offset,
    );
  }
}
