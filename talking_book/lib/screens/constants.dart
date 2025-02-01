import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talking_book/controller/authController.dart';
import 'package:talking_book/models/authenticationModel.dart';
import 'package:talking_book/screens/dashboard/about.dart';
import 'package:talking_book/screens/dashboard/home.dart';
import 'package:talking_book/screens/dashboard/profile.dart';

class AppConstants {
  //TextField
  static Widget inputField(
      {required String label,
      required String hintText,
      required TextEditingController controller,
      required IconData icon,
      required bool obsecureText,
      Widget? suffixIcon,
      required TextInputType keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obsecureText,
      cursorColor: const Color(0xFF9B897B),
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIconColor: const Color(0xFF9B897B),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF9B897B),
          ),
        ),
        labelText: label,
        labelStyle: const TextStyle(
            color: Color(0xFFe5c9be), fontWeight: FontWeight.bold),
        hintText: hintText,
      ),
    );
  }

//ElevatedButton
  static Widget button(
      {required double buttonWidth,
      required double buttonHeight,
      required GestureTapCallback onTap,
      required String buttonText,
      required double textSize,
      required BuildContext context}) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * buttonWidth,
      height: MediaQuery.sizeOf(context).height * buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9B897B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Text(
          buttonText,
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //Loading Dialog
  static void showLoadingDialog(
      {required BuildContext context, required String title}) {
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF9B897B),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(title),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        return loadingDialog;
      },
    );
  }

  //Alert Dialog
  static void showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) {
        return alertDialog;
      },
    );
  }

  //Drawer
  static dashboardDrawer(BuildContext context) {
    final controller = Get.put(AuthController());
    return Drawer(
      backgroundColor: const Color(0xFF9B897B),
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.26,
            child: UserAccountsDrawerHeader(
              margin: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                color: Color(0xFFdddfe1),
                // borderRadius: BorderRadius.only(
                //   bottomRight: Radius.circular(50),
                // ),
              ),
              currentAccountPicture: Obx(() {
                AuthenticationModel? userData = controller.userData.value;
                if (userData != null && userData.imageUrl != "") {
                  return ClipOval(
                    child: Image.network(
                      userData.imageUrl!,
                      fit: BoxFit.fill,
                      height: 140,
                      width: 140,
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF9B897B),
                        ),
                        borderRadius: BorderRadius.circular(70)),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      backgroundImage: (controller.profileImageUrl.isEmpty)
                          ? null
                          : NetworkImage(controller.userData.value!.imageUrl!),
                      child: (controller.profileImageUrl.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF9B897B),
                            )
                          : null,
                    ),
                  );
                }
              }),
              accountEmail: Obx(
                () {
                  AuthenticationModel? userData = controller.userData.value;
                  if (userData != null && userData.email != '') {
                    return Text(
                      userData.email,
                      style: const TextStyle(
                          fontSize: 25.0,
                          color: Color(0xFF9B897B),
                          fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const Text(
                      'User Email',
                      style: TextStyle(
                          fontSize: 25.0,
                          color: Color(0xFF9B897B),
                          fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),
              accountName: Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Obx(
                  () {
                    AuthenticationModel? userData = controller.userData.value;
                    if (userData != null && userData.name != '') {
                      return Text(
                        userData.name,
                        style: const TextStyle(
                            fontSize: 25.0,
                            color: Color(0xFF9B897B),
                            fontWeight: FontWeight.bold),
                      );
                    } else {
                      return const Text(
                        'UserName',
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Color(0xFF9B897B),
                            fontWeight: FontWeight.bold),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          drawerButtons(
            context: context,
            navigateTo: const HomeScreen(),
            icon: Icons.home,
            text: "Home",
          ),
          /*drawerButtons(
            context: context,
            navigateTo: const RecentBooksScreen(),
            icon: Icons.book,
            text: "Recent Books",
          ),*/
          const SizedBox(
            height: 20,
          ),
          drawerButtons(
            context: context,
            navigateTo: const AboutScreen(),
            icon: Icons.info,
            text: "About",
          ),
          const SizedBox(
            height: 20,
          ),
          drawerButtons(
            context: context,
            navigateTo: const ProfileScreen(),
            icon: Icons.person,
            text: "Profile",
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 1),
              ),
            ),
            margin: const EdgeInsets.only(right: 15, left: 15),
            padding: const EdgeInsets.only(right: 15),
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    title: const Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: "SingleDay",
                      ),
                    ),
                    content: const Text(
                      "Are you sure you want to Logout",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9B897B),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await controller.logout(context);
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9B897B),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  //drawer Buttons
  static Container drawerButtons(
      {required BuildContext context,
      required Widget navigateTo,
      required IconData icon,
      required String text}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      margin: const EdgeInsets.only(right: 15, left: 15),
      padding: const EdgeInsets.only(right: 15),
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => navigateTo));
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
