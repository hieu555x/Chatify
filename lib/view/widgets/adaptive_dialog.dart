import 'package:chattify/services/language/helper.dart';
import 'package:chattify/view/widgets/gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<String?> showAdaptiveInputDialog(
  BuildContext context,
  String title,
  String placeholder, {
  bool isPassword = false,
}) async {
  final controller = TextEditingController();
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Column(
          children: [
            SizedBox(height: 10),
            CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              obscureText: isPassword,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.appStrings.exit,
              style: TextStyle(color: Colors.red),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: Text(context.appStrings.confirm),
          ),
        ],
      ),
    );
  } else {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: placeholder),
          obscureText: isPassword,
        ),
        actions: [
          GradientButton(
            onPressed: () => Navigator.pop(context),
            isCancel: true,
            text: context.appStrings.exit,
          ),
          GradientButton(
            onPressed: () => Navigator.pop(context, controller.text),
            isCancel: false,
            text: context.appStrings.confirm,
          ),
        ],
      ),
    );
  }
}
