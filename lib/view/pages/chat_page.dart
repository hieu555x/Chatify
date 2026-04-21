import 'package:amicons/amicons.dart';
import 'package:chattify/constant.dart';
import 'package:chattify/cubit/chat/chat_cubit.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/cubit/rooms/rooms_cubit.dart';
import 'package:chattify/services/language/helper.dart';
import 'package:chattify/view/pages/chat_bubble.dart';
import 'package:chattify/view/widgets/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  final String otherUserID;

  const ChatPage({super.key, required this.otherUserID});

  static Route<void> route(
    String roomID,
    String otherUserID,
    ProfilesCubit profilesCubit,
    RoomCubit roomsCubit,
  ) {
    return MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<ProfilesCubit>.value(value: profilesCubit),
          BlocProvider<RoomCubit>.value(value: roomsCubit),
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit()..setMessageListener(roomID),
          ),
        ],
        child: ChatPageWrapper(roomID: roomID, otherUserID: otherUserID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    return BlocBuilder<ProfilesCubit, ProfilesState>(
      builder: (context, profileState) {
        final profile = context.read<ProfilesCubit>().profiles[otherUserID];

        return Scaffold(
          appBar: AppBar(
            title: GradientText(
              text: profile!.userName,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            centerTitle: true,
          ),
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
                      child: Center(
                        child: Text(context.appStrings.chatDescription),
                      ),
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
      },
    );
  }
}

class ChatPageWrapper extends StatefulWidget {
  final String roomID;
  final String otherUserID;

  const ChatPageWrapper({
    super.key,
    required this.roomID,
    required this.otherUserID,
  });

  @override
  State<ChatPageWrapper> createState() => _ChatPageWrapperState();
}

class _ChatPageWrapperState extends State<ChatPageWrapper> {
  late RoomCubit _roomsCubit;
  late ProfilesCubit _profilesCubit;

  @override
  void initState() {
    super.initState();

    _roomsCubit = context.read<RoomCubit>();
    _profilesCubit = context.read<ProfilesCubit>();

    if (!_profilesCubit.profiles.containsKey(widget.otherUserID)) {
      debugPrint('📥 Loading profile for user: ${widget.otherUserID}');
      _profilesCubit.getProfile(widget.otherUserID);
    }

    try {
      _roomsCubit.pauseRoomNotifications(widget.roomID);
      debugPrint('✅ Paused notifications for room: ${widget.roomID}');
    } catch (e) {
      debugPrint('❌ Error pausing notifications: $e');
    }
  }

  @override
  void dispose() {
    try {
      _roomsCubit.resumeRoomNotifications(widget.roomID);
      debugPrint('✅ Resumed notifications for room: ${widget.roomID}');
    } catch (e) {
      debugPrint('❌ Error resuming notifications: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatPage(otherUserID: widget.otherUserID);
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
      child: SafeArea(
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
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: context.appStrings.typeAMessage,
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[200]
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: InkWell(
                  onTap: submitMessage,
                  borderRadius: BorderRadius.circular(26),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return buttonGradient(context).createShader(bounds);
                    },
                    child: Icon(
                      Amicons.iconly_send_curved_fill,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitMessage() async {
    final text = textController.text;
    if (text.isEmpty) {
      context.showErrorSnackBar(message: context.appStrings.typeAMessage);
      return;
    }
    BlocProvider.of<ChatCubit>(context).sendMessage(text);
    textController.clear();
  }
}
