// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talking_book/models/authenticationModel.dart';
import 'package:talking_book/screens/authentication.dart';
import 'package:talking_book/screens/constants.dart';
import 'package:talking_book/screens/dashboard/home.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth =
      FirebaseAuth.instance; //Instacne created for Firebase Authentication
  final FirebaseFirestore db =
      FirebaseFirestore.instance; //Instacne created for Firebase Firestore
  late final Rx<User?> firebaseUser;
  final Rx<AuthenticationModel?> userData = Rx<AuthenticationModel?>(null);
  final isUserLoggedIn = false.obs;
  RxString name = "".obs;
  RxString profileImageUrl = "".obs;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, setInitialScreen);
  }

  setInitialScreen(User? user) {
    if (user == null) {
      isUserLoggedIn.value = false;
      Get.offAll(() => const Authentication());
    } else {
      isUserLoggedIn.value = true;
      loadUserData(user.email!);
      Get.offAll(() => const HomeScreen());
    }
  }

  loadUserData(String email) async {
    AuthenticationModel? user = await getUserData(email);
    userData.value = user;
    name.value = user!.name;
    profileImageUrl.value = user.imageUrl!;
  }

  Future<AuthenticationModel?> getUserData(String email) async {
    final snapshot =
        await db.collection('Users').where('email', isEqualTo: email).get();
    if (snapshot.docs.isEmpty) {
      print('NO Data');
      return null;
    }
    final userData = AuthenticationModel.fromJson(snapshot.docs.first);
    return userData;
  }

  Future<void> createUser(
      {required AuthenticationModel auth,
      required BuildContext context}) async {
    try {
      AppConstants.showLoadingDialog(
          context: context, title: "Creating Your Account");
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: auth.email, password: auth.password);
      auth.id = userCredential.user!.uid;
      await db.collection("Users").doc(auth.id).set({
        'id': auth.id,
        'name': auth.name,
        'email': auth.email,
        'imageUrl': auth.imageUrl,
        'password': auth.password,
      }).whenComplete(() {
        isUserLoggedIn.value = true;
        loadUserData(auth.email);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      AppConstants.showAlertDialog(
          context: context, title: "Error", content: e.toString());
    } catch (e) {
      print(e);
    }
  }

  //Logging in user
  Future<void> fetchData(
      {required String email,
      required String password,
      required BuildContext context}) async {
    Map<String, dynamic>? userData;
    try {
      AppConstants.showLoadingDialog(context: context, title: "Logging In....");
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then(
            (value) async => {
              await FirebaseFirestore.instance
                  .collection('Users')
                  .where('email', isEqualTo: email)
                  .get()
                  .then((value) => {})
                  .whenComplete(
                () {
                  isUserLoggedIn.value = true;
                  loadUserData(email);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
              ),
            },
          );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      AppConstants.showAlertDialog(
          context: context, title: "Error", content: e.toString());
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut().whenComplete(() {
      userData.value = null;
      print("Logged Out");
    });
    Navigator.pushNamedAndRemoveUntil(
        context, '/afterlogout', (route) => false);
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      AppConstants.showLoadingDialog(
          context: context, title: 'Deleting Your Profile');
      User? user = FirebaseAuth.instance.currentUser;
      String uId = userData.value!.id!;
      if (user == null || user.uid != uId) {
        throw Exception('No user is currently signed in or user ID mismatch.');
      }
      String userId = user.uid;
      Reference storageRef =
          FirebaseStorage.instance.ref().child('profilePictures/$userId');

      List<String> extensions = ['jpeg', 'png', 'jpg'];

      // Attempt to delete each possible profile picture
      for (String ext in extensions) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profilePictures/$userId.$ext');
        try {
          await storageRef.delete();
          print('Deleted profile picture with extension .$ext');
        } catch (e) {
          // If the file doesn't exist, log and continue
          if (e is FirebaseException && e.code == 'object-not-found') {
            print('Profile picture .$ext does not exist.');
          } else {
            throw e; // Re-throw if it's a different error
          }
        }
      }
      await FirebaseFirestore.instance.collection('Users').doc(userId).delete();

      await user.delete();
      userData.value = null;

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Success',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF9B897B),
                ),
              ),
              content: const Text(
                'Your Profile has been Deleted...!',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Ok",
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
    } catch (e) {
      Navigator.pop(context);
      AppConstants.showAlertDialog(
          context: context, title: 'Error', content: e.toString());
    }
  }
}
