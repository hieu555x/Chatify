import 'package:chattify/constant.dart';
import 'package:chattify/env.dart';
import 'package:chattify/view/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: SUPABASE_URL,anonKey: SUPABASE_ANON_KEY,);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: appTheme,
      home: SplashPage(),
    );
  }
}
