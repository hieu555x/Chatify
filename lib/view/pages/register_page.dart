import 'package:chattify/constant.dart';
import 'package:chattify/view/pages/chat_page.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:chattify/view/widgets/custom_text_form_field.dart';
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

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Form(
        key: formKey,
        child: ListView(
          padding: formPadding,
          children: [
            CustomTextFormField(
              labelText: 'Email',
              validator: (val) {
                return val == null || val.isEmpty ? 'Required' : null;
              },
              controller: emailController,
            ),
            formSpacer,
            CustomTextFormField(
              labelText: 'Password',
              controller: passwordController,
              obscureText: true,
              validator: (val) {
                return val == null || val.isEmpty
                    ? 'Required'
                    : val.length < 6
                    ? '6 characters minimum'
                    : null;
              },
            ),
            formSpacer,
            CustomTextFormField(
              labelText: "User name ",
              controller: usernameController,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Required";
                }
                final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                return !isValid
                    ? '3-24 long with alphanumeric or underscore'
                    : null;
              },
            ),
            formSpacer,
            ElevatedButton(
              onPressed: isLoading ? null : signUp,
              child: const Text('Register'),
            ),
            formSpacer,
            TextButton(
              child: Text('I already have an account'),
              onPressed: () {
                Navigator.of(context).push(LoginPage.route());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) return;

    final String email = emailController.text;
    final String password = passwordController.text;
    final String username = usernameController.text;

    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      Navigator.of(
        context,
      ).pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (e) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}
