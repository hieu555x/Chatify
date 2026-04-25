import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/cubit/rooms/rooms_cubit.dart';
import 'package:chattify/view/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationHandler {
  static final NavigationHandler _instance = NavigationHandler._internal();
  factory NavigationHandler() => _instance;
  NavigationHandler._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> navigateToChat({
    required String roomId,
    required String otherUserId,
    required BuildContext context,
  }) async {
    try {
      final profilesCubit = context.read<ProfilesCubit>();
      final roomsCubit = context.read<RoomCubit>();

      // Load the other user's profile if not already loaded
      if (!profilesCubit.profiles.containsKey(otherUserId)) {
        await profilesCubit.getProfile(otherUserId);
      }

      // Navigate to the chat page
      if (context.mounted) {
        Navigator.of(context).push(
          ChatPage.route(
            roomId,
            otherUserId,
            profilesCubit,
            roomsCubit,
          ),
        );
      }
    } catch (e) {
      // Handle navigation error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error navigating to chat: $e')),
        );
      }
    }
  }

  Future<void> handleNotificationTap({
    required String roomId,
    required String otherUserId,
  }) async {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      await navigateToChat(
        roomId: roomId,
        otherUserId: otherUserId,
        context: context,
      );
    }
  }
}