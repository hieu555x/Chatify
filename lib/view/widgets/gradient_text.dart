// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chattify/constant.dart';
import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  int maxLines = 1;
  TextOverflow overflow;
  Gradient? gradient;
  GradientText({
    super.key,
    required this.text,
    required this.textStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = buttonGradient(context);
    return ShaderMask(
      shaderCallback: (bounds) =>
          (gradient ?? defaultGradient).createShader(bounds),
      child: Text(
        text,
        style: textStyle.copyWith(color: Colors.white),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
