import 'dart:async';

import 'package:chattify/models/chat.dart';
import 'package:chattify/providers/authentication_provider.dart';
import 'package:chattify/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPageProvider extends ChangeNotifier {
  AuthenticationProvider auth;

  late DatabaseService db;

  List<Chat>? chats;

  late StreamSubscription chatStream;

  ChatPageProvider(this.auth) {
    db = GetIt.instance.get<DatabaseService>();
    getChat();
  }

  void getChat() async {}

  @override
  void dispose() {
    chatStream.cancel();
    super.dispose();
  }
}
