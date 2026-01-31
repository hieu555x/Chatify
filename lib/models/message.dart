class Message {
  final String id;
  final String profileID;
  final String content;
  final DateTime createAt;
  final bool isMine;
  final String roomID;

  Message({
    required this.id,
    required this.profileID,
    required this.content,
    required this.createAt,
    required this.isMine,
    required this.roomID,
  });

  Message.fromMap({required Map<String, dynamic> map, required String myUserID})
    : id = map['id'],
      profileID = map['profile_id'],
      content = map['content'],
      createAt = DateTime.parse(map['created_at']),
      roomID = map["room_id"],
      isMine = myUserID == map['profile_id'];

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileID,
      'content': content,
      'created_at': createAt.toIso8601String(),
      'room_id': roomID,
    };
  }
}
