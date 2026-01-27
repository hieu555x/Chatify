import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/cubit/rooms/rooms_cubit.dart';
import 'package:chattify/models/profile.dart';
import 'package:chattify/view/pages/chat_page.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<RoomCubit>(
        create: (context) => RoomCubit()..initializeRooms(context),
        child: RoomsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rooms'),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.of(
                context,
              ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
            },
            child: Text('Logout'),
          ),
        ],
      ),
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return preloader;
          } else if (state is RoomLoaded) {
            final newUsers = state.newUsers;
            final rooms = state.rooms;
            return BlocBuilder<ProfilesCubit, ProfilesState>(
              builder: (context, state) {
                if (state is ProfilesLoaded) {
                  final profiles = state.profiles;
                  return Column(
                    children: [
                      NewUsers(newUsers: newUsers),
                      Expanded(
                        child: ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final otherUser = profiles[room.otherUserID];

                            return ListTile(
                              onTap: () => Navigator.of(
                                context,
                              ).push(ChatPage.route(room.id)),
                              leading: CircleAvatar(
                                child: otherUser == null
                                    ? preloader
                                    : Text(otherUser.userName.substring(0, 2)),
                              ),
                              title: Text(
                                otherUser == null
                                    ? "Loading ..."
                                    : otherUser.userName,
                              ),
                              subtitle: room.lastMessage != null
                                  ? Text(
                                      room.lastMessage!.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text('Room created'),
                              trailing: Text(
                                format(
                                  room.lastMessage?.createAt ?? room.createdAt,
                                  locale: 'en_short',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return preloader;
                }
              },
            );
          } else if (state is RoomEmpty) {
            final newUsers = state.newUsers;
            return Column(
              children: [
                NewUsers(newUsers: newUsers),
                Expanded(
                  child: Center(
                    child: Text('Start a chat by tapping on available users'),
                  ),
                ),
              ],
            );
          } else if (state is RoomError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

class NewUsers extends StatelessWidget {
  final List<Profile> newUsers;
  const NewUsers({super.key, required this.newUsers});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: newUsers
            .map<Widget>(
              (user) => InkWell(
                onTap: () async {
                  try {
                    final roomID = await BlocProvider.of<RoomCubit>(
                      context,
                    ).createRoom(user.id);
                    Navigator.of(context).push(ChatPage.route(roomID));
                  } catch (_) {
                    context.showErrorSnackBar(
                      message: 'Failed creating a new room',
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      children: [
                        CircleAvatar(
                          child: Text(user.userName.substring(0, 2)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          user.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
