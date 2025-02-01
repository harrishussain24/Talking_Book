// ignore_for_file: file_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api, unused_local_variable

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talking_book/controller/authController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2700))
      ..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller!);

    // Schedule the navigation to happen after 3 seconds
    Timer(
      const Duration(seconds: 3),
      () {
        final controller = Get.put(AuthController());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation!,
              child: SizedBox(
                width: 200.0,
                height: 200.0,
                child: Image.asset('assets/images/transparent_logoo.png'),
              ),
              builder: (BuildContext? context, Widget? _widget) {
                return Transform.rotate(
                  angle: _animation!.value,
                  child: _widget,
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Talking Book",
              style: TextStyle(
                fontFamily: "SingleDay",
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }
}
