class RoomModel {
  final String id;
  final String host;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String roomType;
  final String? roomName;

  RoomModel({
    required this.id,
    required this.host,
    required this.createdAt,
    required this.updatedAt,
    required this.roomType,
    this.roomName,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] as String,
      host: map['host'] as String,
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.parse(map['created_at'].toString()),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.parse(map['updated_at'].toString()),
      roomType: map['room_type'] as String,
      roomName: map['room_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'host': host,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'room_type': roomType,
      'room_name': roomName,
    };
  }

  RoomModel copyWith({
    String? id,
    String? host,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roomType,
    String? roomName,
  }) {
    return RoomModel(
      id: id ?? this.id,
      host: host ?? this.host,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomType: roomType ?? this.roomType,
      roomName: roomName ?? this.roomName,
    );
  }
}
