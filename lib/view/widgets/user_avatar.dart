import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserAvatar extends StatelessWidget {
  final String userID;
  const UserAvatar({super.key, required this.userID});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilesCubit, ProfilesState>(
      builder: (context, state) {
        if (state is ProfilesLoaded) {
          final user = state.profiles[userID];
          return CircleAvatar(
            child: user == null
                ? preloader
                : Text(user.userName.substring(0, 2)),
          );
        } else {
          return CircleAvatar(child: preloader);
        }
      },
    );
  }
}
