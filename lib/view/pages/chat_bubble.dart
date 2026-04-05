import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/models/message.dart';
import 'package:chattify/view/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isMine = message.isMine;
    List<Widget> chatContents = [
      if (!isMine)
        ProfileAvatar(
          user: context.read<ProfilesCubit>().profiles[message.profileID],
        ),
      SizedBox(width: 12),
      Flexible(
        child: Container(
          constraints: BoxConstraints(maxWidth: 280),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isMine ? null : Colors.grey[200],
            gradient: isMine ? buttonGradient(context) : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(isMine ? 20 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: isMine
                  ? Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black87
                  : Colors.black87,
            ),
          ),
        ),
      ),
      SizedBox(width: 12),
      Text(
        format(message.createAt, locale: 'en_short'),
        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
      ),
      SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
