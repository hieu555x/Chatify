import 'package:chattify/constant.dart';
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

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
          formSpacer,
          ElevatedButton(onPressed: isLoading?null:signIn, child: Text('Login'))
        ],
      ),
    );
  }
}
