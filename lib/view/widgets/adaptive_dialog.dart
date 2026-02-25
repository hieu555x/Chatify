import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<String?> showAdaptiveInputDialog(
  BuildContext context,
  String title,
  String placeholder,
) async {
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
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: Text("Confirm"),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
