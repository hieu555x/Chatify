import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:chattify/view/widgets/adaptive_dialog.dart';
import 'package:chattify/view/widgets/info_card.dart';
import 'package:flutter/cupertino.dart';
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
            appBar: AppBar(title: Text('Profile')),
            body: Center(
              child: currentProfile == null
                  ? preloader
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        formSpacer,
                        Stack(
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          currentProfile.userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        formSpacer,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    16,
                                  ),
                                ),
                                elevation: 6,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsGeometry.all(16),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Information",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(height: 1),
                                    InfoCard(
                                      icon: Icons.person,
                                      label: "User Name",
                                      value: currentProfile.userName,
                                    ),
                                  ],
                                ),
                              ),
                              formSpacer,
                              Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    16,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsGeometry.all(16),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Account setting",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(height: 1),
                                    InfoCard(
                                      icon: Icons.key,
                                      label: "Change your password",
                                      value: "",
                                    ),
                                    InfoCard(
                                      icon: Icons.person,
                                      label: "Change your user name",
                                      value: "",
                                      onTap: () async {
                                        final newUserName = await
                                            showAdaptiveInputDialog(
                                              context,
                                              "Input your new user name ",
                                              "Input your new user name",
                                            );
                                        newUserName == ""
                                            ? print("null")
                                            : print(newUserName);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => LogoutDialog(),
                  );
                },
                child: Text("Log out"),
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

  Widget LogoutDialog() {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android
        ? AlertDialog(
            title: Text("Do you want to logout"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                  Navigator.of(
                    context,
                  ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
                },
                child: Text("Confirm"),
              ),
            ],
          )
        : CupertinoAlertDialog(
            title: Text("Do you want to logout"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                  Navigator.of(
                    context,
                  ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
                },
                child: Text("Confirm"),
              ),
            ],
          );
  }
}
