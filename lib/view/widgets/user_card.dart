import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final Widget avatarIcon;
  final String userTitle;
  final String lastMessage;
  final String lastTime;
  final Function onTap;
  const UserCard({
    super.key,
    required this.avatarIcon,
    required this.userTitle,
    required this.lastMessage,
    required this.lastTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap,
      child: SizedBox(
        width: double.infinity,
        height: 80,
        child: Row(
          children: [
            avatarIcon,
            SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: Text("data"),
                      ),
                      Align(
                        alignment: AlignmentGeometry.centerRight,
                        child: Text("data"),
                      ),
                    ],
                  ),
                  Text("data"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
