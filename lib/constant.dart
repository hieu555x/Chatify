import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

const preloader = Center(child: CircularProgressIndicator(color: Colors.white));

const formSpacer = SizedBox(height: 16, width: 16);

const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

const unexpectedErrorMessage = "Unexpected error occurred";

final appTheme = ThemeData.light().copyWith(
  primaryColorDark: Colors.orange,
  appBarTheme: AppBarTheme(
    elevation: 1,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
  ),
  primaryColor: Colors.orange,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.orange),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.orange,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelStyle: TextStyle(color: Colors.orange),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey, width: 2),
    ),
    focusColor: Colors.orange,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.orange, width: 2),
    ),
  ),
);

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}
