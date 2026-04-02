import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/cubit/rooms/rooms_cubit.dart';
import 'package:chattify/models/profile.dart';
import 'package:chattify/services/language/helper.dart';
import 'package:chattify/services/notification_service.dart';
import 'package:chattify/view/pages/chat_page.dart';
import 'package:chattify/view/pages/profile_page.dart';
import 'package:chattify/view/widgets/gradient_text.dart';
import 'package:chattify/view/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) {
        final profilesCubit = ProfilesCubit();
        return MultiBlocProvider(
          providers: [
            BlocProvider<ProfilesCubit>(create: (_) => profilesCubit),
            BlocProvider<RoomCubit>(
              create: (_) =>
                  RoomCubit(profilesCubit: profilesCubit)
                    ..initializeRooms(context),
            ),
          ],
          child: const RoomsPage(),
        );
      },
    );
  }

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    NotificationService.setNotificationTapCallback((roomID) async {
      final profilesCubit = context.read<ProfilesCubit>();
      final roomsCubit = context.read<RoomCubit>();
      final state = roomsCubit.state;

      if (state is RoomLoaded) {
        final room = state.rooms.firstWhere((r) => r.id == roomID);
        Navigator.of(context).push(
          ChatPage.route(roomID, room.otherUserID, profilesCubit, roomsCubit),
        );
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        title: GradientText(
          text: context.appStrings.appName,
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(ProfilePage.route()),
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) return preloader;

          List<Profile> allUsers = [];
          if (state is RoomLoaded) allUsers = state.newUsers;
          if (state is RoomEmpty) allUsers = state.newUsers;

          final filteredUsers = allUsers.where((user) {
            return user.userName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Search user ...",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[200]
                          : Colors.grey[800],
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                searchController.clear();
                                setState(() => searchQuery = "");
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: GradientText(
                    text: context.appStrings.welcomeBack,
                    textStyle: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                if (searchQuery.isNotEmpty) SearchResults(users: filteredUsers),
                if (searchQuery.isEmpty)
                  Expanded(
                    child: state is RoomEmpty
                        ? Center(
                            child: Text(
                              "Search for someone to start chatting!",
                            ),
                          )
                        : buildRoomList(context, state),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildRoomList(BuildContext context, RoomState state) {
    if (state is! RoomLoaded) return SizedBox();

    final rooms = state.rooms;
    final profilesCubit = context.read<ProfilesCubit>();
    final profiles = profilesCubit.profiles;

    return BlocBuilder<ProfilesCubit, ProfilesState>(
      builder: (context, profileState) {
        final profiles = (profileState is ProfilesLoaded)
            ? profileState.profiles
            : {};
        return ListView.builder(
          itemCount: rooms.length,
          cacheExtent: 500,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final otherUser = profiles[room.otherUserID];

            return UserCard(
              avatarIcon: _ProfileAvatar(user: otherUser),
              userTitle: otherUser?.userName ?? context.appStrings.loading,
              lastMessage: "lastMessage",
              lastTime: format(room.lastMessage?.createAt ?? room.createdAt),
              onTap: () {},
            );
          },
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final Profile? user;
  final double radius;

  const _ProfileAvatar({this.user, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return CircleAvatar(
        radius: radius,
        child: SizedBox(
          width: radius * 1.5,
          height: radius * 1.5,
          child: preloader,
        ),
      );
    }

    final hasImage =
        user!.profileImage.isNotEmpty && user!.profileImage != "null";

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      backgroundImage: hasImage ? NetworkImage(user!.profileImage) : null,
      onBackgroundImageError: hasImage
          ? (exception, stackTrace) =>
                debugPrint("${context.appStrings.errorAvatar} $exception")
          : null,
      child: !hasImage
          ? Text(
              user!.userName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}

class SearchResults extends StatelessWidget {
  final List<Profile> users;

  const SearchResults({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Text(context.appStrings.noUser),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: _ProfileAvatar(user: user, radius: 20),
            title: Text(user.userName),
            onTap: () async {
              try {
                final roomID = await context.read<RoomCubit>().createRoom(
                  user.id,
                );
                if (context.mounted) {
                  final profilesCubit = context.read<ProfilesCubit>();
                  final roomsCubit = context.read<RoomCubit>();
                  Navigator.of(context).push(
                    ChatPage.route(roomID, user.id, profilesCubit, roomsCubit),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  context.showErrorSnackBar(
                    message: context.appStrings.errorCreateRoom,
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
