// ignore_for_file: file_names, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talking_book/controller/authController.dart';
import 'package:talking_book/models/authenticationModel.dart';
import 'package:talking_book/screens/constants.dart';

class ProfileImageController extends GetxController {
  static ProfileImageController instance = Get.find();

  final controller = Get.put(AuthController());

  Rx<File?> imageFile = Rx<File?>(null);
  RxBool isButtonEnabled = false.obs;

  void saveImage(File? image) {
    imageFile.value = image;
  }

  void toggleButtonState() {
    isButtonEnabled.value = !isButtonEnabled.value;
  }

  void uploadData(
      AuthenticationModel authenticationModel, BuildContext context) async {
    AppConstants.showLoadingDialog(
        context: context, title: 'Uploading your Image');
    File? finalImage = imageFile.value;
    UploadTask uploadTask = FirebaseStorage.instance
        .ref('profilePictures')
        .child(authenticationModel.id.toString())
        .putFile(finalImage!);

    TaskSnapshot snapshot = await uploadTask.onError((error, stackTrace) {
      throw {
        Get.back(),
        AppConstants.showAlertDialog(
            context: context, title: 'Error', content: error.toString())
      };
    });

    String imageUrl = await snapshot.ref.getDownloadURL();
    authenticationModel.imageUrl = imageUrl;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(authenticationModel.id.toString())
        .set(authenticationModel.toJson())
        .whenComplete(() {
      controller.profileImageUrl.value = imageUrl;
      Get.back();
    }).onError((error, stackTrace) {
      Get.back();
      AppConstants.showAlertDialog(
          context: context, title: 'Error', content: error.toString());
    });
    print('Data Uploaded');
  }
}
