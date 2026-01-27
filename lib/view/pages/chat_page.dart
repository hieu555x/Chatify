import 'package:chattify/constant.dart';
import 'package:chattify/cubit/chat/chat_cubit.dart';
import 'package:chattify/models/message.dart';
import 'package:chattify/view/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static Route<void> route(String roomID) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessageListener(roomID),
        child: ChatPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            context.showErrorSnackBar(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ChatInitial) {
            return preloader;
          } else if (state is ChatLoaded) {
            final messages = state.messages;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
                ),
                MessageBar(),
              ],
            );
          } else if (state is ChatEmpty) {
            return Column(
              children: [
                Expanded(
                  child: Center(child: Text('Start your conversation now ')),
                ),
                MessageBar(),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

class MessageBar extends StatefulWidget {
  const MessageBar({super.key});

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  late final TextEditingController textController;

  @override
  void initState() {
    textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsetsGeometry.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.text,
                maxLines: null,
                autofocus: true,
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            TextButton(onPressed: () => submitMessage(), child: Text('Send')),
          ],
        ),
      ),
    );
  }

  void submitMessage() async {
    final text = textController.text;
    if (text.isEmpty) {
      context.showErrorSnackBar(message: 'Please type a message');
      return;
    }
    BlocProvider.of<ChatCubit>(context).sendMessage(text);
    textController.clear();
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine) UserAvatar(userID: message.profileID),
      SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: message.isMine
                ? Colors.grey[300]
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      SizedBox(width: 12),
      Text(format(message.createAt, locale: 'en_short')),
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
