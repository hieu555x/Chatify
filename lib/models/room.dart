import 'package:chattify/models/message.dart';

class Room {
  final String id;
  final DateTime createdAt;
  final String otherUserID;
  final Message? lastMessage;

  Room({
    required this.id,
    required this.createdAt,
    required this.otherUserID,
    this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'createdAt': createdAt.millisecondsSinceEpoch};
  }

  Room.fromRoomParticipants(Map<String, dynamic> map)
    : id = map['room_id'],
      otherUserID = map['profile_id'],
      createdAt = DateTime.parse(map['created_at']),
      lastMessage = null;

  Room copyWith({
    String? id,
    DateTime? createAt,
    String? otherUserID,
    Message? lastMessage,
  }) {
    return Room(
      id: id ?? this.id,
      createdAt: createAt ?? this.createdAt,
      otherUserID: otherUserID ?? this.otherUserID,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
