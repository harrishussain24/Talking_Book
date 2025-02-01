// ignore_for_file: must_be_immutable, avoid_print, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talking_book/controller/bookController.dart';
import 'package:talking_book/screens/constants.dart';

class FileViewPage extends StatefulWidget {
  final String filePath, fileName;
  PlatformFile file;
  FileViewPage(
      {super.key,
      required this.filePath,
      required this.file,
      required this.fileName});

  @override
  State<FileViewPage> createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
  final controller = Get.put(BookController());

  late AudioPlayer audioPlayer;
  PDFViewController? pdfController;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerComplete.listen((event) {
      if (controller.currentPage < controller.pageTexts.length - 1) {
        controller.currentPage++;
        pdfController?.setPage(
            controller.currentPage.value); // Explicitly change PDF page
        playAudio(); // Play audio for the next page
      } else {
        controller.isPlaying.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color(0xFF9B897B),
        title: Text(
          widget.fileName == "" ? "File" : widget.fileName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        leading: Obx(
          () {
            if (controller.listenButton.value == false) {
              return IconButton(
                onPressed: () {
                  controller.listenButton.value = true;
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              );
            } else {
              return IconButton(
                onPressed: () {
                  controller.listenButton.value = true;
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              );
            }
          },
        ),
      ),
      body: widget.filePath == ""
          ? const Center(child: Text("No Path"))
          : Column(
              children: [
                SizedBox(
                  height: 600,
                  width: double.infinity,
                  child: PDFView(
                    swipeHorizontal: false,
                    fitEachPage: true,
                    filePath: widget.filePath,
                    autoSpacing: true,
                    onPageChanged: (page, total) {
                      setState(() {
                        controller.currentPage.value = page ?? 0;
                        print(
                            "Page changed to: ${controller.currentPage.value}");
                      });
                    },
                    onViewCreated: (PDFViewController vc) {
                      pdfController = vc;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(
                      () {
                        if (controller.listenButton.value == true) {
                          return AppConstants.button(
                            buttonHeight: 0.07,
                            buttonWidth: 0.6,
                            buttonText: 'Listen Now',
                            textSize: 20,
                            onTap: () => {
                              controller
                                  .uploadPdf(widget.file, context)
                                  .whenComplete(
                                    () => print('Text Extracted Successfully'),
                                  )
                                  .onError(
                                    (error, stackTrace) =>
                                        print('Error Occurred: $error'),
                                  ),
                            },
                            context: context,
                          );
                        } else {
                          return Row(
                            children: [
                              Obx(
                                () {
                                  if (controller.playButton.isTrue) {
                                    return audioButtons(
                                      onTap: () {
                                        playAudio();
                                      },
                                      text: 'Play',
                                      width: 0.3,
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              audioButtons(
                                onTap: () {
                                  pauseAudio();
                                },
                                text: 'Stop',
                                width: 0.3,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              audioButtons(
                                onTap: () {
                                  resumeAudio();
                                },
                                text: 'Resume',
                                width: 0.3,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
    );
  }

  Future<void> playAudio() async {
    if (controller.currentPage.value < controller.pageAudios.length) {
      await audioPlayer.stop();
      await saveAudioFile(controller.pageAudios[controller.currentPage.value]);
      await audioPlayer.play(DeviceFileSource(await getAudioFilePath()));
      controller.isPlaying.value = true;
      controller.isPaused.value = false;
      controller.playButton.value = false;
    }
  }

  void pauseAudio() {
    if (audioPlayer.state == PlayerState.playing) {
      audioPlayer.pause();
      controller.isPlaying.value = false;
      controller.isPaused.value = true;
    }
  }

  void stopAudio() {
    if (audioPlayer.state == PlayerState.playing) {
      audioPlayer.stop();
      controller.isPlaying.value = false;
      controller.isPaused.value = false;
    }
  }

  void togglePauseResumeAudio() {
    if (audioPlayer.state == PlayerState.playing) {
      pauseAudio();
    } else if (audioPlayer.state == PlayerState.paused) {
      resumeAudio();
    }
  }

  Future<void> resumeAudio() async {
    if (audioPlayer.state == PlayerState.paused) {
      await audioPlayer.resume();
      controller.isPlaying.value = true;
      controller.isPaused.value = false;
    }
  }

  Future<void> restartAudio() async {
    if (audioPlayer.state == PlayerState.playing ||
        audioPlayer.state == PlayerState.paused) {
      await audioPlayer.stop();
    }
    await playAudio();
  }

  Future<void> saveAudioFile(Uint8List audioBytes) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String audioFilePath =
        '$appDocPath/output_page_${controller.currentPage.value}.mp3';
    await File(audioFilePath).writeAsBytes(audioBytes);
  }

  Future<String> getAudioFilePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    return '$appDocPath/output_page_${controller.currentPage.value}.mp3';
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Widget audioButtons(
      {required GestureTapCallback onTap,
      required String text,
      required double width}) {
    return AppConstants.button(
      buttonWidth: width,
      buttonHeight: 0.05,
      onTap: onTap,
      buttonText: text,
      textSize: 15,
      context: context,
    );
  }
}
