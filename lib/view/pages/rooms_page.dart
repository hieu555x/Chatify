import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/cubit/rooms/rooms_cubit.dart';
import 'package:chattify/models/profile.dart';
import 'package:chattify/services/language/helper.dart';
import 'package:chattify/view/pages/chat_page.dart';
import 'package:chattify/view/pages/profile_page.dart';
import 'package:chattify/view/widgets/gradient_text.dart';
import 'package:chattify/view/widgets/profile_avatar.dart';
import 'package:chattify/view/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) {
        // ✅ Sử dụng ProfilesCubit global thay vì tạo mới
        final profilesCubit = context.read<ProfilesCubit>();
        return MultiBlocProvider(
          providers: [
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
  final FocusNode searchFocusNode = FocusNode();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    final currentUserID = supabase.auth.currentUser?.id;
    if (currentUserID != null) {
      context.read<ProfilesCubit>().getProfile(currentUserID);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (FocusScope.of(context).focusedChild == searchFocusNode) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    searchController.clear();
    setState(() {
      searchQuery = "";
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserID = supabase.auth.currentUser?.id;

    return BlocBuilder<ProfilesCubit, ProfilesState>(
      builder: (profileContext, profileState) {
        final currentProfile = profileState is ProfilesLoaded
            ? profileState.profiles[currentUserID]
            : null;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : Colors.white,
            title: GradientText(
              text: context.appStrings.appName,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () =>
                    Navigator.of(context).push(ProfilePage.route()),
                icon: profileState is ProfilesInitial
                    ? Icon(Icons.person)
                    : ProfileAvatar(user: currentProfile),
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
                        focusNode: searchFocusNode,
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
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
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: GradientText(
                          text: context.appStrings.welcomeBack,
                          textStyle: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    if (searchQuery.isNotEmpty)
                      SearchResults(users: filteredUsers),
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
      },
    );
  }

  Widget buildRoomList(BuildContext context, RoomState state) {
    if (state is! RoomLoaded) return SizedBox();

    final rooms = state.rooms;
    final profilesCubit = context.read<ProfilesCubit>();

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
              avatarIcon: ProfileAvatar(user: otherUser),
              userTitle: otherUser?.userName ?? context.appStrings.loading,
              lastMessage: room.lastMessage?.content.toString() ?? "",
              lastTime: format(room.lastMessage?.createAt ?? room.createdAt),
              onTap: () {
                try {
                  final roomsCubit = context.read<RoomCubit>();
                  Navigator.of(context).push(
                    ChatPage.route(
                      room.id,
                      room.otherUserID,
                      profilesCubit,
                      roomsCubit,
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorSnackBar(
                      message: context.appStrings.errorCreateRoom,
                    );
                  }
                }
              },
            );
          },
        );
      },
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
            leading: ProfileAvatar(user: user, radius: 20),
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
