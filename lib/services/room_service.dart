import 'package:uuid/uuid.dart';
import '../core/exceptions/app_exception.dart';
import '../models/room_member_model.dart';
import '../models/room_model.dart';
import '../repositories/message_repository.dart';
import '../repositories/room_member_repository.dart';
import '../repositories/room_repository.dart';
import '../repositories/user_repository.dart';
import 'websocket_service.dart';

class RoomService {
  final RoomRepository _roomRepository;
  final RoomMemberRepository _roomMemberRepository;
  final UserRepository _userRepository;
  final MessageRepository _messageRepository;
  final WebSocketService _webSocketService;

  RoomService({
    RoomRepository? roomRepository,
    RoomMemberRepository? roomMemberRepository,
    UserRepository? userRepository,
    MessageRepository? messageRepository,
    WebSocketService? webSocketService,
  })  : _roomRepository = roomRepository ?? RoomRepository(),
        _roomMemberRepository = roomMemberRepository ?? RoomMemberRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _messageRepository = messageRepository ?? MessageRepository(),
        _webSocketService = webSocketService ?? WebSocketService();

  /// Enriches room model with members information and latest message
  Future<Map<String, dynamic>> _enrichRoomData(RoomModel room) async {
    final memberRecords = await _roomMemberRepository.getMembersByRoomId(room.id);
    final memberUserIds = memberRecords.map((m) => m.userMember).toList();
    final users = await _userRepository.getUsersByIds(memberUserIds);
    final lastMessage = await _messageRepository.getLastMessageByRoomId(room.id);

    final roomMap = room.toMap();
    roomMap['members'] = users.map((u) {
      final json = u.toPublicJson();
      json['is_online'] = _webSocketService.isUserOnline(u.id);
      return json;
    }).toList();
    roomMap['last_message'] = lastMessage?.toMap();

    return roomMap;
  }

  /// Creates a direct chat room when adding a friend / initiating direct chat.
  /// Automatically broadcasts `room_created` via WebSocket to both users
  /// containing room info, members, and last_message: null (empty chat)
  /// so their UI instantly opens/adds the new room without refreshing the DB!
  Future<Map<String, dynamic>> createDirectRoom(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      throw BadRequestException('Cannot create a chat room with yourself');
    }

    // Check if a direct room already exists between these 2 users
    final currentUserMemberships = await _roomMemberRepository.getRoomsForUser(currentUserId);
    final targetUserMemberships = await _roomMemberRepository.getRoomsForUser(targetUserId);

    final currentUserRoomIds = currentUserMemberships.map((m) => m.roomId).toSet();
    final commonRoomIds = targetUserMemberships
        .where((m) => currentUserRoomIds.contains(m.roomId))
        .map((m) => m.roomId)
        .toList();

    for (final roomId in commonRoomIds) {
      final room = await _roomRepository.getRoomById(roomId);
      if (room != null && room.roomType == 'DIRECT') {
        final enrichedRoom = await _enrichRoomData(room);
        _webSocketService.notifyRoomCreated([currentUserId, targetUserId], enrichedRoom);
        return enrichedRoom;
      }
    }

    // Create new direct room
    final roomId = const Uuid().v4();
    final now = DateTime.now();

    final roomToCreate = RoomModel(
      id: roomId,
      host: currentUserId,
      createdAt: now,
      updatedAt: now,
      roomType: 'DIRECT',
      roomName: null,
    );

    final createdRoom = await _roomRepository.createRoom(roomToCreate);

    // Add members
    final member1 = RoomMemberModel(
      id: const Uuid().v4(),
      roomId: roomId,
      userMember: currentUserId,
      roleUser: 'member',
      updatedAt: now,
    );

    final member2 = RoomMemberModel(
      id: const Uuid().v4(),
      roomId: roomId,
      userMember: targetUserId,
      roleUser: 'member',
      updatedAt: now,
    );

    await _roomMemberRepository.addMember(member1);
    await _roomMemberRepository.addMember(member2);

    final enrichedRoom = await _enrichRoomData(createdRoom);

    // Broadcast room_created event via WebSocket to both users
    _webSocketService.notifyRoomCreated(
      [currentUserId, targetUserId],
      enrichedRoom,
    );

    return enrichedRoom;
  }

  /// Get list of rooms for a specific user enriched with members and last_message
  Future<List<Map<String, dynamic>>> getUserRooms(String userId) async {
    final memberships = await _roomMemberRepository.getRoomsForUser(userId);
    final enrichedRooms = <Map<String, dynamic>>[];

    for (final membership in memberships) {
      final room = await _roomRepository.getRoomById(membership.roomId);
      if (room != null) {
        final enriched = await _enrichRoomData(room);
        enrichedRooms.add(enriched);
      }
    }

    return enrichedRooms;
  }

  /// Get detail of a room (verifying user is a member)
  Future<Map<String, dynamic>> getRoomDetail(String roomId, String userId) async {
    final members = await _roomMemberRepository.getMembersByRoomId(roomId);
    final isMember = members.any((m) => m.userMember == userId);

    if (!isMember) {
      throw NotRoomMemberException('You are not a member of this chat room');
    }

    final room = await _roomRepository.getRoomById(roomId);
    if (room == null) {
      throw RoomNotFoundException('Chat room not found');
    }

    return await _enrichRoomData(room);
  }
}
