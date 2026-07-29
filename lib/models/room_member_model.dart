class RoomMemberModel {
  final String id;
  final String roomId;
  final String userMember;
  final String roleUser;
  final DateTime updatedAt;

  RoomMemberModel({
    required this.id,
    required this.roomId,
    required this.userMember,
    required this.roleUser,
    required this.updatedAt,
  });

  factory RoomMemberModel.fromMap(Map<String, dynamic> map) {
    return RoomMemberModel(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      userMember: map['user_member'] as String,
      roleUser: map['role_user'] as String,
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.parse(map['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'user_member': userMember,
      'role_user': roleUser,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RoomMemberModel copyWith({
    String? id,
    String? roomId,
    String? userMember,
    String? roleUser,
    DateTime? updatedAt,
  }) {
    return RoomMemberModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userMember: userMember ?? this.userMember,
      roleUser: roleUser ?? this.roleUser,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
