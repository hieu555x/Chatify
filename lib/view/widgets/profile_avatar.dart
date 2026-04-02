import 'package:chattify/models/profile.dart';
import 'package:chattify/services/language/helper.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final Profile? user;
  final double radius;

  const ProfileAvatar({super.key, this.user, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return CircleAvatar(
        radius: radius,
        child: SizedBox(
          width: radius * 1.5,
          height: radius * 1.5,
          child: Icon(Icons.person),
        ),
      );
    }

    final hasImage =
        user!.profileImage.isNotEmpty && user!.profileImage != "null";

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      backgroundImage: hasImage ? NetworkImage(user!.profileImage) : null,
      onBackgroundImageError: hasImage
          ? (exception, stackTrace) =>
                debugPrint("${context.appStrings.errorAvatar} $exception")
          : null,
      child: !hasImage
          ? Text(
              user!.userName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
