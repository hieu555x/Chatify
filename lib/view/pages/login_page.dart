import 'package:chattify/constant.dart';
import 'package:chattify/view/pages/chat_page.dart';
import 'package:chattify/view/pages/register_page.dart';
import 'package:chattify/view/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (context) => LoginPage());

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.of(
        context,
      ).pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (e) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: ListView(
        padding: formPadding,
        children: [
          CustomTextFormField(
            labelText: "Email",
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              return null;
            },
          ),
          formSpacer,
          CustomTextFormField(
            labelText: 'Password',
            controller: passwordController,
            obscureText: true,
            validator: (val) {
              return null;
            },
          ),
          formSpacer,
          ElevatedButton(
            onPressed: isLoading ? null : signIn,
            child: Text("Login"),
          ),
          formSpacer,
          TextButton(
            child: Text('I\'m not have the account'),
            onPressed: () {
              Navigator.of(context).push(RegisterPage.route());
            },
          ),
        ],
      ),
    );
  }
}
