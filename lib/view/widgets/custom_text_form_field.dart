import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final String? Function(String?) validator;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(label: Text(labelText)),
      validator: validator,
      obscureText: obscureText,
    );
  }
}
