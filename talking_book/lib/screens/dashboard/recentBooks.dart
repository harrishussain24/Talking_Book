// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:talking_book/screens/constants.dart';

class RecentBooksScreen extends StatefulWidget {
  const RecentBooksScreen({super.key});

  @override
  State<RecentBooksScreen> createState() => _RecentBooksScreenState();
}

class _RecentBooksScreenState extends State<RecentBooksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color(0xFF9B897B),
        title: const Text(
          "Recent Books",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      drawer: AppConstants.dashboardDrawer(context),
      body: const SafeArea(
        child: Center(
          child: Text("Recent Books"),
        ),
      ),
    );
  }
}
