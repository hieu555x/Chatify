import 'package:chattify/constant.dart';
import 'package:chattify/view/pages/register_page.dart';
import 'package:chattify/view/pages/rooms_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    getInitialSession();
    super.initState();
  }

  Future<void> getInitialSession() async {
    await Future.delayed(Duration.zero);
    try {
      final session = supabase.auth.currentSession;
      if (session == null) {
        Navigator.of(
          context,
        ).pushAndRemoveUntil(RegisterPage.route(), (_) => false);
      } else {
        Navigator.of(
          context,
        ).pushAndRemoveUntil(RoomsPage.route(), (_) => false);
      }
    } catch (_) {
      context.showErrorSnackBar(
        message: 'Error occurred during session refresh',
      );
      Navigator.of(
        context,
      ).pushAndRemoveUntil(RegisterPage.route(), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
