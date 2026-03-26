import 'package:chattify/constant.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:chattify/view/widgets/adaptive_dialog.dart';
import 'package:chattify/view/widgets/info_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

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
            resizeToAvoidBottomInset: true,
            appBar: AppBar(title: Text('Profile')),
            body: currentProfile == null
                ? Center(child: preloader)
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          formSpacer,
                          Stack(
                            children: [
                              currentProfile.profileImage == ""
                                  ? CircleAvatar(
                                      radius: 50,
                                      child: Text(
                                        currentProfile.userName
                                            .substring(0, 2)
                                            .toUpperCase(),
                                        style: TextStyle(fontSize: 32),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                        currentProfile.profileImage,
                                      ),
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
                                child: GestureDetector(
                                  onTap: () {
                                    uploadImage(currentProfile.id);
                                  },
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
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
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16),
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
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16),
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
                                  onTap: () async {
                                    final oldPassword =
                                        await showAdaptiveInputDialog(
                                          context,
                                          "Enter your current password",
                                          "Enter your current password",
                                          isPassword: true,
                                        );

                                    if (oldPassword == null ||
                                        oldPassword.isEmpty) {
                                      return;
                                    }

                                    final newPassword =
                                        await showAdaptiveInputDialog(
                                          context,
                                          "Enter your new password",
                                          "Enter your new password",
                                          isPassword: true,
                                        );

                                    if (newPassword == null ||
                                        newPassword.isEmpty) {
                                      if (mounted) {
                                        context.showErrorSnackBar(
                                          message: 'Vui lòng nhập password mới',
                                        );
                                      }
                                      return;
                                    }

                                    await updatePassword(
                                      oldPassword,
                                      newPassword,
                                    );
                                  },
                                ),
                                InfoCard(
                                  icon: Icons.person,
                                  label: "Change your user name",
                                  value: "",
                                  onTap: () async {
                                    final newUserName =
                                        await showAdaptiveInputDialog(
                                          context,
                                          "Input your new user name",
                                          "Input your new user name",
                                        );

                                    if (newUserName != null &&
                                        newUserName.trim().isNotEmpty) {
                                      await updateUserName(
                                        currentProfile.id,
                                        newUserName.trim(),
                                      );
                                    } else if (newUserName != null && mounted) {
                                      context.showErrorSnackBar(
                                        message:
                                            'Please enter a valid user name',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => _showLogoutDialog(context),
                child: Text("Log out", style: TextStyle(color: Colors.white)),
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

  Future<void> updateUserName(String id, String newUserName) async {
    try {
      await supabase
          .from('profiles')
          .update({'username': newUserName})
          .eq('id', id);

      final session = supabase.auth.currentUser;
      if (session != null && mounted) {
        context.read<ProfilesCubit>().clearProfile(session.id);
        await context.read<ProfilesCubit>().getProfile(session.id);
        context.showSnackBar(message: 'Cập nhật tên người dùng thành công');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(message: 'Lỗi cập nhật: $e');
      }
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      final email = supabase.auth.currentUser?.email;
      if (email == null) {
        context.showErrorSnackBar(message: 'Không tìm thấy email');
        return;
      }

      await supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      if (mounted) {
        context.showSnackBar(message: 'Change the password success');
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('Invalid login credentials')) {
          context.showErrorSnackBar(message: 'Old password is incorrect');
        } else {
          context.showErrorSnackBar(message: 'Error update password: $e');
        }
      }
    }
  }

  Future<void> uploadImage(String userID) async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 80,
    );

    if (image == null) return;

    try {
      final file = File(image.path);
      final fileExt = image.path.split(".").last;
      final fileName =
          '$userID-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      await supabase.storage
          .from("avatars")
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String imageUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      await supabase
          .from('profiles')
          .update({'profile_image': imageUrl})
          .eq('id', userID);

      if (mounted) {
        context.read<ProfilesCubit>().clearProfile(userID);
        await context.read<ProfilesCubit>().getProfile(userID);
        context.showSnackBar(message: 'Upload image success');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(message: 'Error upload image: $e');
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final platform = Theme.of(context).platform;
        if (platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: Text("Logout"),
            content: Text("Do you want to logout?"),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
                  }
                },
                child: Text("Confirm"),
              ),
            ],
          );
        }
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Do you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await supabase.auth.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
                }
              },
              child: Text("Confirm", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
