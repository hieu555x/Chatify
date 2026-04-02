import 'dart:async';

import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/models/message.dart';
import 'package:chattify/models/profile.dart';
import 'package:chattify/models/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'rooms_state.dart';

class RoomCubit extends Cubit<RoomState> {
  final ProfilesCubit profilesCubit;

  RoomCubit({required this.profilesCubit}) : super(RoomLoading());

  final Map<String, StreamSubscription<Message?>> messageSubscriptions = {};

  String myUserID = "";

  List<Profile> newUsers = [];

  List<Room> rooms = [];
  StreamSubscription<List<Map<String, dynamic>>>? rawRoomsSubscription;
  bool haveCalledGetRooms = false;

  Future<void> initializeRooms(BuildContext context) async {
    if (haveCalledGetRooms) return;

    haveCalledGetRooms = true;

    myUserID = supabase.auth.currentUser!.id;

    List data;

    try {
      data = await supabase
          .from('profiles')
          .select()
          .not('id', 'eq', myUserID)
          .order('created_at')
          .limit(12);

      final rows = List<Map<String, dynamic>>.from(data);
      newUsers = rows.map(Profile.fromMap).toList();
    } catch (e) {
      emit(RoomError('Error loading new users ${e.toString()}'));
      return;
    }

    final rows = List<Map<String, dynamic>>.from(data);
    newUsers = rows.map(Profile.fromMap).toList();

    rawRoomsSubscription = supabase
        .from('room_participants')
        .stream(primaryKey: ['room_id', 'profile_id'])
        .listen(
          (participantsMaps) async {
            if (participantsMaps.isEmpty) {
              if (!isClosed) {
                emit(RoomEmpty(newUsers: newUsers));
              }
              return;
            }

            rooms = participantsMaps
                .map(Room.fromRoomParticipants)
                .where((room) => room.otherUserID != myUserID)
                .toList();

            final ortherUserID = rooms.map((r) => r.otherUserID).toList();
            await profilesCubit.getProfiles(ortherUserID);

            for (final room in rooms) {
              getNewestMessage(context: context, roomID: room.id);
            }
            if (!isClosed) {
              emit(RoomLoaded(rooms: rooms, newUsers: newUsers));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(RoomError("Error loading rooms"));
            }
          },
        );
  }

  void getNewestMessage({
    required BuildContext context,
    required String roomID,
  }) {
    messageSubscriptions[roomID] = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomID)
        .order('created_at', ascending: false)
        .limit(1)
        .map<Message?>(
          (data) => data.isEmpty
              ? null
              : Message.fromMap(map: data.first, myUserID: myUserID),
        )
        .listen((message) {
          final index = rooms.indexWhere((room) => room.id == roomID);

          if (index == -1) return;

          rooms[index] = rooms[index].copyWith(lastMessage: message);
          rooms.sort((a, b) {
            final aTimeStamp = a.lastMessage != null
                ? a.lastMessage!.createAt
                : a.createdAt;
            final bTimeStamp = b.lastMessage != null
                ? b.lastMessage!.createAt
                : b.createdAt;
            return bTimeStamp.compareTo(aTimeStamp);
          });
          if (!isClosed) {
            emit(RoomLoaded(rooms: rooms, newUsers: newUsers));
          }
        });
  }

  Future<String> createRoom(String otherUserID) async {
    final data = await supabase.rpc(
      'create_new_room',
      params: {'other_user_id': otherUserID},
    );
    if (!isClosed) {
      emit(RoomLoaded(rooms: rooms, newUsers: newUsers));
    }
    return data as String;
  }

  Future<void> refreshRooms(BuildContext context) async {
    await rawRoomsSubscription?.cancel();
    for (final sub in messageSubscriptions.values) {
      sub.cancel();
    }

    messageSubscriptions.clear();

    haveCalledGetRooms = false;

    await initializeRooms(context);
  }

  void pauseRoomNotifications(String roomID) {}

  void resumeRoomNotifications(String roomID) {}

  void clearRoomNotificationsHistory(String roomID) {}

  @override
  Future<void> close() {
    rawRoomsSubscription?.cancel();
    for (final subscription in messageSubscriptions.values) {
      subscription.cancel();
    }
    messageSubscriptions.clear();
    return super.close();
  }
}
