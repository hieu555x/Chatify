part of 'rooms_cubit.dart';

@immutable
abstract class RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<Profile> newUsers;
  final List<Room> rooms;

  RoomLoaded({required this.rooms, required this.newUsers});
}

class RoomEmpty extends RoomState {
  final List<Profile> newUsers;

  RoomEmpty({required this.newUsers});
}

class RoomError extends RoomState {
  final String message;

  RoomError(this.message);
}
