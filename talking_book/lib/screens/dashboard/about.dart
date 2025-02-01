import 'package:flutter/material.dart';
import 'package:talking_book/screens/constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color(0xFF9B897B),
        title: const Text(
          "About",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      drawer: AppConstants.dashboardDrawer(context),
      body: const SafeArea(
        child: Center(
          child: Text("About"),
        ),
      ),
    );
  }
}
