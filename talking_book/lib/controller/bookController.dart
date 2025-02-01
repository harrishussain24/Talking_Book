// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:talking_book/screens/constants.dart';

class BookController extends GetxController {
  static BookController instance = Get.find();

  List<String> pageTexts = <String>[].obs;
  List<Uint8List> pageAudios = <Uint8List>[].obs;
  List<PlatformFile> selectedFiles = <PlatformFile>[].obs;
  RxBool isPlaying = false.obs;
  RxBool isPaused = false.obs;
  RxInt currentPage = 0.obs;
  RxBool listenButton = true.obs;
  RxBool playButton = true.obs;

  Future<void> uploadPdf(PlatformFile file, BuildContext context) async {
    try {
      AppConstants.showLoadingDialog(
          context: context, title: 'Getting Things Ready...!');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://f9b848fc-5079-4b77-a0fc-88b5adaa44a8-00-2b25th4bfbh9o.janeway.replit.dev/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        var responseText = await streamedResponse.stream.bytesToString();
        var jsonData = jsonDecode(responseText) as List;

        pageTexts.clear();
        pageAudios.clear();

        for (var page in jsonData) {
          String audioBase64 = page['audio_base64'];
          Uint8List audioBytes = base64.decode(audioBase64);
          pageTexts.add(page['text']);
          pageAudios.add(audioBytes);
        }
        listenButton.value = !listenButton.value;
        Navigator.pop(context);
        print('File uploaded successfully');
      } else {
        Navigator.pop(context);
        AppConstants.showAlertDialog(
            context: context,
            title: 'Something went Wrong...!',
            content: '${streamedResponse.reasonPhrase}');
        print('Failed to upload file: ${streamedResponse.reasonPhrase}');
      }
    } catch (e) {
      Navigator.pop(context);
      AppConstants.showAlertDialog(
          context: context, title: 'Something went Wrong...!', content: '$e');
      print('Error uploading file: $e');
    }
  }

  void pickFiles() async {
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
      selectedFiles = files.cast<PlatformFile>();
    } catch (e) {
      print("Error picking files: $e");
    }
  }
}
