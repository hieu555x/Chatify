import 'package:chattify/constant.dart';
import 'package:chattify/models/message.dart';
import 'package:chattify/models/profile.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (context) => ChatPage());

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> messagesStream;
  final Map<String, Profile> profileCache = {};

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;
    messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (maps) => maps
              .map((map) => Message.fromMap(map: map, myUserID: myUserId))
              .toList(),
        );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadProfileCache(String profileID) async {
    if (profileCache[profileID] != null) {
      return;
    }
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', profileID)
        .single();
    final profile = Profile.fromMap(data);
    setState(() {
      profileCache[profileID] = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              supabase.auth.signOut();
              Navigator.of(
                context,
              ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? Center(child: Text('Let send your first message <3'))
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            loadProfileCache(message.profileID);
                            return ChatBubble(
                              message: message,
                              profile: profileCache[message.profileID],
                            );
                          },
                        ),
                ),
                MessageBar(),
              ],
            );
          } else {
            return preloader;
          }
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
  late final TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: textEditingController,
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
      ),
    );
  }

  void submitMessage() async {
    final text = textEditingController.text;
    final myUserID = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      toastification.show(
        context: context,
        alignment: Alignment.bottomCenter,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: Duration(seconds: 2),
        title: Text("Please type a message !"),
      );
      return;
    }

    textEditingController.clear();
    try {
      await supabase
          .from('messages')
          .insert({'profile_id': myUserID, 'content': text})
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout - Kiểm tra kết nối mạng');
            },
          );
    } on PostgrestException catch (e) {
      textEditingController.text = text;
      toastification.show(
        context: context,
        alignment: Alignment.bottomCenter,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: Duration(seconds: 3),
        title: Text('Database error: ${e.message}'),
      );
    } catch (e) {
      // Khôi phục lại text nếu gửi thất bại
      textEditingController.text = text;
      toastification.show(
        context: context,
        alignment: Alignment.bottomCenter,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: Duration(seconds: 3),
        title: Text('Lỗi: ${e.toString()}'),
      );
    }
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final Profile? profile;
  const ChatBubble({super.key, required this.message, required this.profile});

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine)
        CircleAvatar(
          child: profile == null
              ? preloader
              : profile?.profileImage != null
              ? Image.network(profile!.profileImage.toString())
              : Text(profile!.userName.substring(0, 2)),
        ),
      SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: message.isMine
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      SizedBox(width: 12),

      Text(covertDate()),
      SizedBox(width: 60),
    ];
    if (message.isMine) chatContents = chatContents.reversed.toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }

  String covertDate() {
    final now = DateTime.now();
    final messageTime = message.createAt.toUtc().add(Duration(hours: 7));

    if (now.day == messageTime.day &&
        now.month == messageTime.month &&
        now.year == messageTime.year) {
      return DateFormat(
        'kk:mm',
      ).format(message.createAt.toUtc().add(Duration(hours: 7)));
    } else {
      return DateFormat(
        'kk:mm dd/MM/yyyy',
      ).format(message.createAt.toUtc().add(Duration(hours: 7))).toString();
    }
  }
}
