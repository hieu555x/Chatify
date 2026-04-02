import 'dart:io';

import 'package:chattify/constant.dart';
import 'package:chattify/cubit/language/local_cubit.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/services/language/helper.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:chattify/view/widgets/adaptive_dialog.dart';
import 'package:chattify/view/widgets/gradient_text.dart';
import 'package:chattify/view/widgets/info_card.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../cubit/theme/theme_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const ProfilePage());
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
            appBar: AppBar(
              title: GradientText(
                text: context.appStrings.profileText,
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              actions: [
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) {
                    return IconButton(
                      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                      icon: Icon(
                        mode == ThemeMode.light
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    );
                  },
                ),
              ],
            ),
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
                          GradientText(
                            text: currentProfile.userName,
                            textStyle: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
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
                                      context.appStrings.information,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(height: 1),
                                InfoCard(
                                  icon: Icons.person,
                                  label: context.appStrings.userName,
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
                                      context.appStrings.accountSetting,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(height: 1),
                                InfoCard(
                                  icon: Icons.key,
                                  label: context.appStrings.changePasswordTitle,
                                  value: "",
                                  onTap: () async {
                                    final oldPassword =
                                        await showAdaptiveInputDialog(
                                          context,
                                          context
                                              .appStrings
                                              .enterYourCurrentPassword,
                                          context
                                              .appStrings
                                              .enterYourCurrentPassword,
                                          isPassword: true,
                                        );

                                    if (oldPassword == null ||
                                        oldPassword.isEmpty) {
                                      return;
                                    }

                                    final newPassword =
                                        await showAdaptiveInputDialog(
                                          context,
                                          context
                                              .appStrings
                                              .enterYourNewPassword,
                                          context
                                              .appStrings
                                              .enterYourNewPassword,
                                          isPassword: true,
                                        );

                                    if (newPassword == null ||
                                        newPassword.isEmpty) {
                                      if (mounted) {
                                        context.showErrorSnackBar(
                                          message: context
                                              .appStrings
                                              .enterYourNewPassword,
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
                                  label: context.appStrings.changeUsernameTitle,
                                  value: "",
                                  onTap: () async {
                                    final newUserName =
                                        await showAdaptiveInputDialog(
                                          context,
                                          context
                                              .appStrings
                                              .enterYourNewUsername,
                                          context
                                              .appStrings
                                              .enterYourNewUsername,
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
                                            context.appStrings.usernameUnvalid,
                                      );
                                    }
                                  },
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
                                  padding: EdgeInsetsGeometry.all(16),
                                  child: Align(
                                    alignment: AlignmentGeometry.centerLeft,
                                    child: Text(
                                      context.appStrings.accountSetting,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(height: 1),
                                InfoCard(
                                  icon: Icons.language,
                                  label: context.appStrings.changeLanguage,
                                  value:
                                      Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'vi'
                                      ? "Tiếng việt"
                                      : "English",
                                  onTap: () => _showLanguagePicker(context),
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
                child: Text(
                  context.appStrings.logout,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(context.appStrings.profileText)),
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
        context.showSnackBar(message: context.appStrings.updateUserNameSuccess);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          message: '${context.appStrings.errorUpdateUserName}: $e',
        );
      }
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      final email = supabase.auth.currentUser?.email;
      if (email == null) {
        context.showErrorSnackBar(message: context.appStrings.notFoundEmail);
        return;
      }

      await supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      if (mounted) {
        context.showSnackBar(message: context.appStrings.passwordUpdateSuccess);
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('Invalid login credentials')) {
          context.showErrorSnackBar(
            message: context.appStrings.oldPasswordInvalid,
          );
        } else {
          context.showErrorSnackBar(
            message: '${context.appStrings.errorPasswordUpdate} $e',
          );
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
        context.showSnackBar(message: context.appStrings.uploadImageSuccess);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          message: '${context.appStrings.errorUploadImage} $e',
        );
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
            title: Text(context.appStrings.logoutTitle),
            content: Text(context.appStrings.logoutContent),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text(context.appStrings.exit),
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
                child: Text(context.appStrings.confirm),
              ),
            ],
          );
        }
        return AlertDialog(
          title: Text(context.appStrings.logoutTitle),
          content: Text(context.appStrings.logoutContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.appStrings.exit),
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
              child: Text(
                context.appStrings.confirm,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                context.appStrings.changeLanguageTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: CountryFlag.fromLanguageCode('en'),
                title: Text("English"),
                trailing: Localizations.localeOf(context).languageCode == 'en'
                    ? Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  context.read<LocaleCubit>().setLocale('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CountryFlag.fromLanguageCode('vi'),
                title: Text("Tiếng việt"),
                trailing: Localizations.localeOf(context).languageCode == 'vi'
                    ? Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  context.read<LocaleCubit>().setLocale('vi');
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
