import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class HelpCentre extends StatefulWidget {
  const HelpCentre({super.key});

  @override
  State<HelpCentre> createState() => _AccountState();
}

class _AccountState extends State<HelpCentre> {

  void checkPlatform() {
    if (kIsWeb) {
      print("Running on the Web");
    } else if (Platform.isIOS) {
      print("Running on iOS");
    } else if (Platform.isAndroid) {
      print("Running on Android");

    } else {
      print("Running on another platform");
    }
  }
  @override
  void initState() {
    super.initState();
    checkPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Help Centre"),
    );
  }
}
