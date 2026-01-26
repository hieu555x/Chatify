part of 'chat_cubit.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  List<Message> messages;

  ChatLoaded(this.messages);
}

class ChatEmpty extends ChatState {}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
