import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import 'login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _noSiriController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _forgotPassword() async {
    // Show loading dialog
    _showDialog(null, null);

    try {
      final url = Uri.parse('http://ekadkuasa.atom.gov.my:8000/api/forgot-password/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'NoSiri': _noSiriController.text.trim(),
          'Email': _emailController.text.trim(),
        }),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // Show the success message
        _showDialog('Success', 'We\'ve sent you an email');
      } else {
        String errorMessage = 'An error occurred, please try again.';
        if (response.statusCode == 400) {
          errorMessage = 'Invalid NoSiri or Email.';
        } else if (response.statusCode == 404) {
          errorMessage = 'No. Siri not found.';
        }
        // Show the error message
        _showDialog('Error', errorMessage);
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      // Show the error message
      _showDialog('Error', 'An error in API occurred, please try again.');
    }
  }

  // Method to show dialog (with support for loading indicator)
  // Method to show dialog (with support for loading indicator)
  void _showDialog(String? title, String? message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (title == null && message == null) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SizedBox(
              width: 250, // Set a finite width for loading dialog
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Loading...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }

        IconData dialogIcon;
        Color iconColor;

        if (title == 'Success') {
          dialogIcon = Icons.check_circle;
          iconColor = Colors.green;
        } else if (title == 'Error') {
          dialogIcon = Icons.error;
          iconColor = Colors.red;
        } else {
          dialogIcon = Icons.info;
          iconColor = Colors.blue;
        }

        // Automatically dismiss the dialog after a few seconds
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 250),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(dialogIcon, color: iconColor, size: 40),
                  SizedBox(width: 10),
                  Text(title!, style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            content: Center(
              child: SizedBox(
                width: 250, // Set a finite width for success/error dialog
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message!, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            actions: [],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 150),

              // Logo Section
              Center(
                child: Image.asset(
                  'assets/logoAtom.png',
                  height: 100,
                ),
              ),

              SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),

              SizedBox(height: 10),

              // NoSiri Input Field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  width: 400,
                  child: _buildTextField(
                    controller: _noSiriController,
                    label: 'NoSiri',
                    isPassword: false,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Email Input Field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  width: 400,
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    isPassword: false,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Forgot Password Button
              Center(
                child: ElevatedButton(
                  onPressed: _forgotPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF800000),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Color(0xFF800000),
                    elevation: 10,
                  ),
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context, PageTransition(
                          type: PageTransitionType.fade,
                          curve: Curves.easeOut,
                          child:Login()),
                      );
                    },
                    child: Text(
                      "Back",
                      style: TextStyle(color: Color(0xFF800000)),
                    )),
              ),

              SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  // TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white70, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white70, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF800000)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
