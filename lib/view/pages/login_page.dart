import 'dart:async';

import 'package:amicons/amicons.dart';
import 'package:chattify/constant.dart';
import 'package:chattify/cubit/theme/theme_cubit.dart';
import 'package:chattify/services/language/helper.dart';
import 'package:chattify/view/pages/register_page.dart';
import 'package:chattify/view/pages/rooms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => LoginPage());
  }
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final StreamSubscription<AuthState> authSubscription;

  @override
  void initState() {
    bool haveNavigated = false;
    authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && !haveNavigated) {
        haveNavigated = true;
        Navigator.of(context).pushReplacement(RoomsPage.route());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appStrings.login),
        centerTitle: true,
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: Icon(
                  isDark ? Amicons.remix_sun_fill : Amicons.remix_moon_fill,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: formPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 32),
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Amicons.remix_chat3,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 40),
            Text(
              context.appStrings.welcomeBack,
              style: TextStyle(
                fontSize: 32,
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              context.appStrings.registerDescription,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            formSpacer,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "EMAIL",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey : Colors.grey,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(hintText: 'your@email.com'),
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PASSWORD",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey : Colors.grey,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: buttonGradient(context),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(32),
                  ),
                ),
                child: isLoading
                    ? Center(child: preloader)
                    : Text(
                        context.appStrings.login,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            formSpacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.appStrings.notHaveAccount,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(RegisterPage.route());
                  },
                  child: Text(
                    context.appStrings.register,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (emailController.text == "" || passwordController.text == "") {
        throw Exception();
      } else {
        await supabase.auth.signInWithPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
