// ignore_for_file: avoid_print, must_be_immutable
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talking_book/controller/authController.dart';
import 'package:talking_book/controller/bookController.dart';
import 'package:talking_book/models/authenticationModel.dart';
import 'package:talking_book/screens/constants.dart';
import 'package:talking_book/screens/dashboard/file_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = Get.put(AuthController());
  final bookController = Get.put(BookController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color(0xFF9B897B),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      drawer: AppConstants.dashboardDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(
              () {
                AuthenticationModel? userData = controller.userData.value;
                if (userData != null && userData.name != '') {
                  return Text(
                    'Hello ${userData.name}...!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      fontFamily: "SingleDay",
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Center(
              child: Obx(
                () {
                  if (bookController.selectedFiles.isNotEmpty) {
                    return SizedBox(
                      height: 800,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: bookController.selectedFiles.length,
                          itemBuilder: (context, index) {
                            final file = bookController.selectedFiles[index];
                            return buildFile(file);
                          }),
                    );
                  } else {
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.7,
                      child: const Center(
                        child: Text(
                          'No Document Selected',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: [
                'pdf',
              ],
            );
            if (result == null) return;
            //final file = result.files.first;
            PlatformFile allFiles = result.files.first;
            print("PDF: ${result.files.first.path}");
            bookController.selectedFiles.add(allFiles);
            print(bookController.selectedFiles);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor: const Color(0xFF9B897B),
          child: const Icon(
            Icons.upload_file,
            size: 40,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildFile(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    final extension = file.extension ?? 'none';
    var color = extension == 'pdf' ? Colors.red : Colors.blue[900];

    return InkWell(
      onTap: () {
        openFile(file);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    extension,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              title: Text(
                file.name,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                fileSize,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> saveFile(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File("${appStorage.path}/Talking-Book/${file.name}");
    print(newFile.path);
    return File(file.path!).copy(newFile.path);
  }

  void openFile(PlatformFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewPage(
          filePath: file.path!,
          file: file,
          fileName: file.name,
        ),
      ),
    );
  }

  //not in use just for example
  Future<List<File>> pickFiles() async {
    List<File> files = [];

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
        ], // Specify the allowed file extensions
      );

      if (result != null) {
        files = result.paths.map((path) => File(path!)).toList();
      }
    } catch (e) {
      print("Error picking files: $e");
    }
    return files;
  }
}
