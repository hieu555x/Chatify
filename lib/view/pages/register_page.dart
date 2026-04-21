import 'dart:async';

import 'package:amicons/amicons.dart';
import 'package:chattify/constant.dart';
import 'package:chattify/cubit/theme/theme_cubit.dart';
import 'package:chattify/env.dart';
import 'package:chattify/services/language/helper.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:chattify/view/pages/rooms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  final bool isRegistering;

  const RegisterPage({super.key, required this.isRegistering});

  @override
  State<RegisterPage> createState() => _RegisterPageState();

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  late final StreamSubscription<AuthState> authSubscription;

  @override
  void initState() {
    super.initState();
    bool haveNavigated = false;

    authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && !haveNavigated) {
        haveNavigated = true;
        Navigator.of(
          context,
        ).pushAndRemoveUntil(RoomsPage.route(), (route) => false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    authSubscription.cancel();
  }

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = emailController.text;
    final password = passwordController.text;
    final username = usernameController.text;
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
        emailRedirectTo: SUPABASE_LOGIN_URL,
      );
      context.showErrorSnackBar(
        message: 'Please check your inbox for confirmation email.',
      );
    } on AuthApiException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      debugPrint(error.toString());
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.appStrings.registerTitle),
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
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: formPadding,
          child: Column(
            children: [
              SizedBox(height: 32),
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Icon(
                  Amicons.lucide_users,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 40),
              Text(
                context.appStrings.registerTitle,
                style: TextStyle(
                  fontSize: 32,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(context.appStrings.registerDescription),
              SizedBox(height: 40),
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
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(hint: Text('your@email.com')),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              formSpacer,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "USER NAME",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey : Colors.grey,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(hint: Text('User name')),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                  if (!isValid) {
                    return '3-24 long with alphanumeric or underscore';
                  }
                  return null;
                },
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
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(hint: Text('Password')),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
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
                  onPressed: isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(32),
                    ),
                  ),
                  child: isLoading
                      ? preloader
                      : Text(
                          context.appStrings.register,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              formSpacer,
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
                },
                child: Text(context.appStrings.haveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
