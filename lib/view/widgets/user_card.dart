import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final Widget avatarIcon;
  final String userTitle;
  final String lastMessage;
  final String lastTime;
  final GestureTapCallback onTap;
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
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            avatarIcon,
            SizedBox(width: 12),
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
                        child: Text(
                          userTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentGeometry.centerRight,
                        child: Text(lastTime),
                      ),
                    ],
                  ),
                  Text(lastMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
