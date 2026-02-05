import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  static Route<void> route() {
    final profileCubit = ProfilesCubit();
    return MaterialPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [BlocProvider<ProfilesCubit>(create: (_) => profileCubit)],
          child: ProfilePage(),
        );
      },
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    final session = supabase.auth.currentUser;
    if (session != null) {
      context.read<ProfilesCubit>().getProfile(session.id);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    final currentUserId = supabase.auth.currentUser?.id;
    return BlocBuilder<ProfilesCubit, ProfilesState>(
      builder: (context, state) {
        if (state is ProfilesInitial) {
          return preloader;
        } else if (state is ProfilesLoaded) {
          final currentProfile = state.profiles[currentUserId];

          return Scaffold(
            appBar: AppBar(title: Text(currentProfile?.userName ?? '')),
            body: Center(
              child: currentProfile == null
                  ? preloader
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Text(
                            currentProfile.userName
                                .substring(0, 2)
                                .toUpperCase(),
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          currentProfile.userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text('Profile')),
          body: Center(child: preloader),
        );
      },
    );
  }
}
