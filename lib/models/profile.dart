class Profile {
  final String id;
  final String userName;
  final DateTime createAt;
  final String profileImage;

  Profile({
    required this.id,
    required this.userName,
    required this.createAt,
    required this.profileImage,
  });

  Profile.fromMap(Map<String, dynamic> map)
    : id = map['id'],
      userName = map['username'],
      createAt = DateTime.parse(map['created_at']),
      profileImage = map['profile_image'].toString();
}
