import 'dart:async';

import 'package:chattify/constant.dart';
import 'package:chattify/view/pages/register_page.dart';
import 'package:chattify/view/pages/rooms_page.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: ListView(
        padding: formPadding,
        children: [
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          formSpacer,
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          formSpacer,
          ElevatedButton(
            onPressed: isLoading ? null : signIn,
            child: Text('Login'),
          ),
          formSpacer,
          TextButton(
            onPressed: () {
              Navigator.of(context).push(RegisterPage.route());
            },
            child: Text('I am not have an account'),
          ),
        ],
      ),
    );
  }
}
