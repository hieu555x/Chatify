import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String name;
  final double height;
  final double width;
  final Function onPress;

  const RoundedButton({
    super.key,
    required this.name,
    required this.height,
    required this.width,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.25),
        color: Color.fromRGBO(0, 82, 218, 1),
      ),
      child: TextButton(
        onPressed: () {
          onPress();
        },
        child: Text(
          name,
          style: TextStyle(fontSize: 21, color: Colors.white, height: 1.5),
        ),
      ),
    );
  }
}
