// ignore_for_file: library_prefixes, unused_local_variable, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talking_book/controller/authController.dart';
import 'package:talking_book/models/authenticationModel.dart';
import 'package:talking_book/screens/constants.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final controller = Get.put(AuthController());
  bool isLogin = false, show = false;
  late final emailController = TextEditingController(),
      passwordController = TextEditingController(),
      nameController = TextEditingController();

  toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  passwordToggler() {
    setState(() {
      show = !show;
    });
  }

  bool validateSignUpData(
      {required String userName,
      required String email,
      required String password}) {
    if (userName == "" && email == "" && password == "") {
      AppConstants.showAlertDialog(
          context: context,
          title: "Error",
          content: "Please fill all the fields");
      return false;
    } else if (!RegExp(r"^[a-zA-Z]").hasMatch(userName) ||
        !RegExp(r"^[a-zA-z0-9]+@[a-z]+.[a-z]").hasMatch(email) ||
        !RegExp(r"^.{6,}$").hasMatch(password)) {
      AppConstants.showAlertDialog(
          context: context,
          title: "Error",
          content: "Entered data badly formatted");
      return false;
    } else {
      return true;
    }
  }

  bool validateSignInData({required String email, required String password}) {
    if (email == "" && password == "") {
      AppConstants.showAlertDialog(
          context: context,
          title: "Error",
          content: "Please fill all the fields");
      return false;
    } else if (!RegExp(r"^[a-zA-z0-9]+@[a-z]+.[a-z]").hasMatch(email) ||
        !RegExp(r"^.{6,}$").hasMatch(password)) {
      AppConstants.showAlertDialog(
          context: context,
          title: "Error",
          content: "Entered data badly formatted");
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height * 0.45,
              width: MediaQuery.sizeOf(context).width * 1,
              color: const Color(0xFF9B897B),
              // decoration: const BoxDecoration(
              //   gradient: LinearGradient(
              //       colors: [
              //         Color(0xDD9B897B),
              //         Color(0xFF8B796B),
              //       ],
              //       begin: FractionalOffset(0.0, 0.0),
              //       end: FractionalOffset(0.5, 0.0),
              //       stops: [0.0, 1.0],
              //       tileMode: TileMode.clamp),
              // ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.07,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        "assets/images/white_logo.png",
                        height: 80,
                        width: 120,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 0.0),
                      child: Text(
                        "Welcome".toUpperCase(),
                        style: const TextStyle(
                          fontFamily: "SingleDay",
                          fontSize: 35,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        isLogin
                            ? "Sign Up To Get Started With Your Account"
                            : "Please Enter Your Credentials To Continue",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              heightFactor: isLogin ? 2.2 : 2.3,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                    color: const Color(0xFF9B897B),
                  ),
                ),
                // height: MediaQuery.sizeOf(context).height * 0.5,
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      isLogin
                          ? Column(
                              children: [
                                AppConstants.inputField(
                                    label: "Name",
                                    hintText: "Enter Your Name",
                                    controller: nameController,
                                    icon: Icons.person_sharp,
                                    obsecureText: false,
                                    suffixIcon: null,
                                    keyboardType: TextInputType.name),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.02,
                                ),
                              ],
                            )
                          : Container(),
                      AppConstants.inputField(
                          label: "Email",
                          hintText: "Enter Your Email",
                          controller: emailController,
                          icon: Icons.email_rounded,
                          obsecureText: false,
                          suffixIcon: null,
                          keyboardType: TextInputType.emailAddress),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.02,
                      ),
                      AppConstants.inputField(
                        label: "Password",
                        hintText: "Enter Your Password",
                        controller: passwordController,
                        icon: Icons.lock,
                        obsecureText: show ? false : true,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            passwordToggler();
                          },
                          child: show
                              ? const Icon(
                                  Icons.visibility_off,
                                  color: Color(0xFF9B897B),
                                )
                              : const Icon(
                                  Icons.visibility,
                                  color: Color(0xFF9B897B),
                                ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      isLogin
                          ? Container()
                          : Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                                child: const Text(
                                  "forgot password...?",
                                  style: TextStyle(
                                    color: Color(0xFF9B897B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.05,
                      ),
                      AppConstants.button(
                        buttonWidth: 0.8,
                        buttonHeight: 0.07,
                        onTap: isLogin
                            ? () {
                                var valid = validateSignUpData(
                                    userName: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim());
                                if (valid) {
                                  final user = AuthenticationModel(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      imageUrl: '',
                                      password: passwordController.text.trim());
                                  controller.createUser(
                                      auth: user, context: context);
                                  nameController.clear();
                                  emailController.clear();
                                  passwordController.clear();
                                }
                              }
                            : () {
                                var valid = validateSignInData(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim());
                                if (valid) {
                                  controller.fetchData(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      context: context);
                                  emailController.clear();
                                  passwordController.clear();
                                }
                              },
                        buttonText: isLogin
                            ? "Signup".toUpperCase()
                            : "Login".toUpperCase(),
                        textSize: 20,
                        context: context,
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Text(
                              isLogin
                                  ? "Already have an Account ...?"
                                  : "Don't have an Account ...?",
                              style: const TextStyle(
                                color: Colors.black,
                                wordSpacing: 1,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              toggle();
                            },
                            style: ButtonStyle(
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                            child: Text(
                              isLogin ? "Login" : "Sign Up",
                              style: const TextStyle(
                                color: Color(0xFF9B897B),
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
