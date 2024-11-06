import 'dart:convert';

import 'package:eKadKuasa/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_constants.dart';
import 'forgot.dart';
import 'home.dart';
import 'api_constants.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if the user is already logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn ?? false) {
      // Navigate to home page directly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(noSiri: prefs.getString('NoSiri') ?? ''),
        ),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              LoadingAnimationWidget.halfTriangleDot(
                color: Color(0xFF800000),
                size: 50,
              ),
              SizedBox(width: 20),
              Text("Loading..."),
            ],
          ),
        );
      },
    );

    try {
      print('Before API call');
      final url = Uri.parse('$baseApiUrl/login/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'NoSiri': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );
      print('After API call, response: ${response.statusCode}');

      // Dismiss the loading dialog
      Navigator.of(context).pop(); // Close the loading dialog

      if (response.statusCode == 200) {
        // Save login status and NoSiri to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('NoSiri', _emailController.text.trim());
        await prefs.setString('Password', _passwordController.text.trim());

        // Navigate to the next screen after successful login
        Navigator.pushReplacement(
          context, PageTransition(
            type: PageTransitionType.fade,
            curve: Curves.easeOut,
            child:Home(noSiri: _emailController.text.trim())),
        );
      } else {
        String errorMessage = 'An error occurred, please try again.';
        if (response.statusCode == 401) {
          errorMessage = 'Invalid email or password.';
        }
        // Show the error message in a dialog
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Dismiss the loading dialog
      Navigator.of(context).pop(); // Close the loading dialog
      // Show the error message in a dialog
      _showErrorDialog('An error in api occurred, please try again. $e');
    }
  }

// Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF800000), // Highlighted button color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
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
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start (left)
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
                  "Login to your account",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),

              SizedBox(height: 10,),

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
                    label: 'NoSiri',
                    isPassword: false,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Password Input Field
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
                    controller: _passwordController,
                    label: 'Password',
                    isPassword: true,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Login Button
              Center(
                child: ElevatedButton(
                  onPressed: _login,
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
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                    onPressed: (){
                      Navigator.push(context, PageTransition(
                        type: PageTransitionType.fade,
                        child:ForgotPassword(),
                      )
                      );
                    },
                    child: Text("Forgot Password?", style: TextStyle(color: Color(0xFF800000)),)
                ),
              ),

              SizedBox(height: 70),

              // "Or login with" Section
              Center(
                child: Text(
                  '-or login with-',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              SizedBox(height: 10),

              // Icon Buttons for Social Logins
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 90),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            // Add Microsoft login logic here
                          },
                          icon: Image.asset(
                            'assets/outlookLogo.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            // Add Microsoft login logic here
                          },
                          icon: Image.asset(
                            'assets/googleLogo.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            // Add Microsoft login logic here
                          },
                          icon: Image.asset(
                            'assets/appleLogo.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Registration Prompt
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Request registration '),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context, PageTransition(
                            type: PageTransitionType.fade,
                            curve: Curves.easeOut,
                            child: SignUpPage()),
                        );
                      },
                      child: Text(
                        'Here',
                        style: TextStyle(
                          color: Color(0xFF800000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      obscureText: isPassword ? _obscurePassword : false,
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
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFF800000),
          ),
          onPressed: _togglePasswordVisibility,
        )
            : null,
      ),
    );
  }
}
