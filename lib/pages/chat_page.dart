import 'package:chattify/providers/authentication_provider.dart';
import 'package:chattify/providers/chat_page_provider.dart';
import 'package:chattify/widget/custom_list_view_tiles.dart';
import 'package:chattify/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late double deviceHeight;
  late double deviceWidth;

  late AuthenticationProvider auth;
  late ChatPageProvider pageProvider;

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(auth),
        ),
      ],
      child: buildUI(),
    );
  }

  Widget buildUI() {
    return Builder(
      builder: (BuildContext context) {
        pageProvider = context.watch<ChatPageProvider>();
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: deviceWidth * 0.03,
            vertical: deviceHeight * 0.02,
          ),
          height: deviceHeight * 0.98,
          width: deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                barTitle: "Chats",
                primaryAction: IconButton(
                  onPressed: () {
                    auth.logout();
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Color.fromRGBO(0, 82, 218, 1),
                  ),
                ),
              ),
              chatTile(),
            ],
          ),
        );
      },
    );
  }

  Widget chatList() {
    return Expanded(child: chatTile());
  }

  Widget chatTile() {
    return CustomListViewTiles(
      height: deviceHeight * 0.1,
      title: "Spader",
      subTitle: "Hello!",
      imagePath: "https://i.pravatar.cc/300",
      isActive: false,
      isActivity: false,
      onTap: () {},
    );
  }
}
