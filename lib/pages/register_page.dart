import 'package:chattify/providers/authentication_provider.dart';
import 'package:chattify/services/cloud_storage_service.dart';
import 'package:chattify/services/database_service.dart';
import 'package:chattify/services/navigation_services.dart';
import 'package:chattify/widget/custom_input_field.dart';
import 'package:chattify/widget/rounded_button.dart';
import 'package:chattify/widget/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double deviceHeight;
  late double deviceWidth;

  late AuthenticationProvider auth;
  late DatabaseService db;
  late CloudStorageService cloudStorageService;

  late NavigationServices navigationServices;

  String? email;
  String? password;
  String? name;
  final registerFormKey = GlobalKey<FormState>();

  TextEditingController profileImage = TextEditingController();

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthenticationProvider>(context);
    db = GetIt.instance.get<DatabaseService>();
    cloudStorageService = GetIt.instance.get<CloudStorageService>();
    navigationServices = GetIt.instance.get<NavigationServices>();
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: deviceWidth * 0.03,
          vertical: deviceHeight * 0.02,
        ),
        height: deviceHeight * 0.98,
        width: deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            profileImageField(),
            SizedBox(height: deviceHeight * 0.02),
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: TextField(
                    controller: profileImage,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Color.fromRGBO(30, 29, 37, 1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Image link address",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(deviceHeight * 0.02),
                      color: Color.fromRGBO(0, 82, 218, 1),
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text(
                        "Print image",
                        style: TextStyle(color: Colors.white, height: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: deviceHeight * 0.05),
            registerForm(),
            SizedBox(height: deviceHeight * 0.05),
            registerButton(),
            SizedBox(height: deviceHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget profileImageField() {
    return profileImage.text != ""
        ? RoundedImageNetwork(
            key: UniqueKey(),
            imagePath: profileImage.text,
            size: deviceHeight * 0.15,
          )
        : RoundedImageNetwork(
            key: UniqueKey(),
            imagePath: "https://avatar.iran.liara.run/public/boy?username=Ash",
            size: deviceHeight * 0.15,
          );
  }

  Widget registerForm() {
    return SizedBox(
      height: deviceHeight * 0.35,
      child: Form(
        key: registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomInputField(
              onSave: (value) {
                setState(() {
                  name = value;
                });
              },
              regEx: r'.{8,}',
              hintText: "Name",
              obscureText: false,
            ),
            CustomInputField(
              onSave: (value) {
                setState(() {
                  email = value;
                });
              },
              regEx: r'.{8,}',
              hintText: "Email",
              obscureText: false,
            ),
            CustomInputField(
              onSave: (value) {
                setState(() {
                  password = value;
                });
              },
              regEx: r'.{8,}',
              hintText: "Password",
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget registerButton() {
    return RoundedButton(
      name: 'Register',
      height: deviceHeight * 0.065,
      width: deviceWidth * 0.65,
      onPress: () async {
        if (registerFormKey.currentState!.validate() &&
            profileImage.text != "") {
          registerFormKey.currentState!.save();
          String? uid = await auth.registerUserUsingEmailAndPassword(
            email!,
            password!,
          );
          if (uid != null) {
            await db.createUser(uid, email!, name!, profileImage.text);
            // navigationServices.goBack();
            await auth.logout();
            await auth.loginUsingEmailAndPassword(email!, password!);
          }
        }
      },
    );
  }
}
