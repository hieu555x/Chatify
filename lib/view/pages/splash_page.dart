import 'package:chattify/constant.dart';
import 'package:chattify/view/pages/chat_page.dart';
import 'package:chattify/view/pages/login_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  Future<void> redirect() async {
    await Future.delayed(Duration.zero);
    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(
        context,
      ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else {
      Navigator.of(
        context,
      ).pushAndRemoveUntil(ChatPage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: preloader);
  }
}
