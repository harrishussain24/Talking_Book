// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talking_book/controller/authController.dart';
import 'package:talking_book/controller/profileImageController.dart';
import 'package:talking_book/models/authenticationModel.dart';
import 'package:talking_book/screens/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = Get.put(AuthController());
  final imageController = Get.put(ProfileImageController());

  @override
  void initState() {
    super.initState();
  }

  void selectImage(ImageSource source, AuthenticationModel authenticationModel,
      BuildContext context) async {
    try {
      // Request permissions
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        await cropImage(pickedFile, authenticationModel, context);
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  cropImage(XFile file, AuthenticationModel authenticationModel,
      BuildContext context) async {
    try {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressQuality: 15,
        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
      );

      if (croppedImage != null) {
        imageController.imageFile.value = File(croppedImage.path);
        print("Image Saved");
        await confirmation(authenticationModel, context);
      } else {
        print("Image cropping canceled");
      }
    } catch (e) {
      print("Error cropping image: $e");
    }
  }

  confirmation(AuthenticationModel authenticationModel, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Confirm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF9B897B),
              ),
            ),
            content: const Text(
              'Are You sure you want to set this photo as your Profile photo...?',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  imageController.imageFile.value = null;
                  Navigator.pop(context);
                },
                child: const Text(
                  "No",
                  style: TextStyle(
                    color: Color(
                      0xFF9B897B,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  imageController.uploadData(authenticationModel, context);
                },
                child: const Text(
                  "Yes",
                  style: TextStyle(
                    color: Color(
                      0xFF9B897B,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void checkValue(
      BuildContext context, AuthenticationModel authenticationModel) {
    if (imageController.imageFile.value == null) {
      AppConstants.showAlertDialog(
        context: context,
        title: 'Error',
        content: 'Please Upload your Picture',
      );
    } else {
      imageController.uploadData(authenticationModel, context);
    }
  }

  void handleButtonPress(
      BuildContext context, AuthenticationModel authenticationModel) {
    if (imageController.isButtonEnabled.value) {
      checkValue(context, authenticationModel);
    } else {
      AppConstants.showAlertDialog(
          context: context, title: 'Error', content: 'No Changes Made Yet');
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationModel? autData = controller.userData.value;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color(0xFF9B897B),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      drawer: AppConstants.dashboardDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              ),
              Stack(
                children: [
                  Obx(() {
                    AuthenticationModel? userData = controller.userData.value;
                    if (userData != null &&
                        imageController.imageFile.value == null &&
                        userData.imageUrl != "") {
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
                          backgroundImage:
                              (imageController.imageFile.value != null)
                                  ? FileImage(imageController.imageFile.value!)
                                  : null,
                          child: (imageController.imageFile.value == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFF9B897B),
                                )
                              : null,
                        ),
                      );
                    }
                  }),
                  Obx(() {
                    if (controller.profileImageUrl != '') {
                      return Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(),
                      );
                    } else {
                      return Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xFF9B897B),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Get.bottomSheet(
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      const Text(
                                        "Select an Option",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(
                                        thickness: 1,
                                        endIndent: 30,
                                        indent: 30,
                                        color: Color(0xFF9B897B),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.back();
                                          selectImage(ImageSource.camera,
                                              autData!, context);
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.7,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color(0xFF9B897B),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 15),
                                            child: Center(
                                              child: Text(
                                                "Camera".toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  letterSpacing: 1,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.back();
                                          selectImage(ImageSource.gallery,
                                              autData!, context);
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.7,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color(0xFF9B897B),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 15),
                                            child: Center(
                                              child: Text(
                                                "Gallery".toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  letterSpacing: 1,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 60,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                      );
                    }
                  })
                ],
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.01,
              ),
              Obx(
                () {
                  AuthenticationModel? userData = controller.userData.value;
                  if (userData != null && userData.name != '') {
                    return Text(
                      userData.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: "SingleDay",
                      ),
                    );
                  } else {
                    return const Text(
                      "Talking Book",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: "SingleDay",
                      ),
                    );
                  }
                },
              ),
              Obx(
                () {
                  AuthenticationModel? userData = controller.userData.value;
                  if (userData != null && userData.email != '') {
                    return Text(
                      userData.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 26,
                        fontFamily: "SingleDay",
                      ),
                    );
                  } else {
                    return const Text(
                      "talkingbook@gmail.com",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 26,
                        fontFamily: "SingleDay",
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              AppConstants.button(
                buttonWidth: 0.5,
                buttonHeight: 0.06,
                onTap: () {
                  controller.deleteUser(context);
                },
                buttonText: "Delete Profile",
                textSize: 20,
                context: context,
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.025,
              ),
              const Divider(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.035,
              ),
              ProfileListTile(
                title: "Settings",
                icon: Icons.settings,
                onPress: () {},
                endIcon: true,
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.025,
              ),
              ProfileListTile(
                title: "Information",
                icon: Icons.info,
                onPress: () {},
                endIcon: true,
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.025,
              ),
              ProfileListTile(
                  title: "Logout",
                  icon: Icons.logout_outlined,
                  onPress: () {
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
                            onPressed: () {
                              controller.logout(context);
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
                  endIcon: false,
                  textColor: Colors.red),
            ]),
          ),
        ),
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  const ProfileListTile(
      {super.key,
      required this.title,
      required this.icon,
      required this.onPress,
      required this.endIcon,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color(0xFF9B897B).withOpacity(0.1)),
        child: Icon(
          icon,
          color: const Color(0xFF9B897B),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
      ),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: endIcon ? Colors.grey.withOpacity(0.2) : null),
        child: Icon(
          endIcon ? Icons.arrow_forward_ios : null,
          size: 15,
          color: Colors.grey,
        ),
      ),
    );
  }
}
