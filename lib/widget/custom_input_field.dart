import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final Function(String) onSave;
  final String regEx;
  final String hintText;
  final bool obscureText;

  const CustomInputField({
    super.key,
    required this.onSave,
    required this.regEx,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: (value) => onSave(value!),
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      validator: (value) {
        return RegExp(regEx).hasMatch(value!) ? null : "Enter a valid value";
      },
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(30, 29, 37, 1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54),
      ),
    );
  }
}
