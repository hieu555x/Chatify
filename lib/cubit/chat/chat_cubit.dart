import 'dart:async';

import 'package:chattify/constant.dart';
import 'package:chattify/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  StreamSubscription<List<Message>>? messagesSubscription;
  List<Message> message = [];

  late final String roomID;
  late final String myUserID;

  void setMessageListener(String roomID) {
    this.roomID = roomID;

    myUserID = supabase.auth.currentUser!.id;

    messagesSubscription = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomID)
        .order('created_at')
        .map<List<Message>>(
          (data) => data
              .map<Message>(
                (row) => Message.fromMap(map: row, myUserID: myUserID),
              )
              .toList(),
        )
        .listen((messages) {
          message = messages;
          if (message.isEmpty) {
            emit(ChatEmpty());
          } else {
            emit(ChatLoaded(message));
          }
        });
  }

  Future<void> sendMessage(String text) async {
    final message = Message(
      id: 'new',
      profileID: myUserID,
      content: text,
      createAt: DateTime.now(),
      isMine: true,
    );
    this.message.insert(0, message);
    emit(ChatLoaded(this.message));
    try {
      await supabase.from('messages').insert(message.toMap());
    } catch (_) {
      emit(ChatError('Error submitting message.'));
      this.message.removeWhere((message) => message.id == 'new');
      emit(ChatLoaded(this.message));
    }
  }
}
