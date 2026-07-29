class ProfileModel {
  final String id;
  final String userId;
  final String? avatarUrl;
  final String? fullName;
  final String? bio;
  final String? address;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.userId,
    this.avatarUrl,
    this.fullName,
    this.bio,
    this.address,
    required this.updatedAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      userId: map['user_id'],
      avatarUrl: map['avatar_url'],
      fullName: map['full_name'],
      bio: map['bio'],
      address: map['address'],
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "user_id": userId,
      "avatar_url": avatarUrl,
      "full_name": fullName,
      "bio": bio,
      "address": address,
      "updated_at": updatedAt.toIso8601String(),
    };
  }
}