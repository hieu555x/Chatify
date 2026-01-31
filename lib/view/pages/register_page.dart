import 'dart:async';

import 'package:chattify/constant.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:chattify/view/pages/rooms_page.dart';
import 'package:flutter/material.dart';
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
        Navigator.of(context).pushReplacement(RoomsPage.route());
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
        emailRedirectTo: 'io.supabase.chat://login',
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
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(label: Text('Email')),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(label: Text('User name')),
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
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(label: Text('Password')),
              validator: (val){
                if(val==null||val.isEmpty){
                  return 'Required';
                }
                return null;
              },
            ),
            formSpacer,
            ElevatedButton(
              onPressed: isLoading ? null : signUp,
              child: Text('Register'),
            ),
            formSpacer,
            TextButton(
              onPressed: () {
                Navigator.of(context).push(LoginPage.route());
              },
              child: Text('I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}
