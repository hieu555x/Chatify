import 'package:chattify/models/chat_message.dart';
import 'package:chattify/models/chat_user.dart';

class Chat {
  final String uid;
  final String currentUserUID;
  final bool activity;
  final bool group;
  final List<ChatUser> members;
  List<ChatMessage> messages;

  late final List<ChatUser> recipients;

  Chat({
    required this.uid,
    required this.currentUserUID,
    required this.members,
    required this.messages,
    required this.activity,
    required this.group,
  }) {
    recipients = members.where((i) => i.uid != currentUserUID).toList();
  }

  List<ChatUser> recepients() {
    return recipients;
  }

  String title() {
    return !group
        ? recipients.first.name
        : recipients.map((user) => user.name).join(", ");
  }

  String imageURL() {
    return !group
        ? recipients.first.imageURL
        : "https://png.pngtree.com/png-clipart/20200225/original/pngtree-group-chat-icon-png-image_5282821.jpg";
  }
}
