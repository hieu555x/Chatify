import 'package:chattify/pages/home_page.dart';
import 'package:chattify/pages/login_page.dart';
import 'package:chattify/pages/register_page.dart';
import 'package:chattify/pages/slash_page.dart';
import 'package:chattify/providers/authentication_provider.dart';
import 'package:chattify/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    SlashPage(
      key: UniqueKey(),
      onInitializationComplete: () {
        runApp(MainApp());
      },
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext context) {
            return AuthenticationProvider();
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Chatify",
        theme: ThemeData(
          splashColor: Color.fromRGBO(36, 35, 49, 1),
          scaffoldBackgroundColor: Color.fromRGBO(36, 35, 49, 1),
          bottomAppBarTheme: BottomAppBarThemeData(
            color: Color.fromRGBO(30, 29, 37, 1),
          ),
        ),
        navigatorKey: NavigationServices.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext context) => LoginPage(),
          '/home': (BuildContext context) => HomePage(),
          '/register': (BuildContext context) => RegisterPage(),
        },
      ),
    );
  }
}
