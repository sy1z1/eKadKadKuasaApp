import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../api_constants.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _noKPController = TextEditingController();
  File? _profileImage;
  File? _signImage;
  final ImagePicker _picker = ImagePicker();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _passwordError;
  String? _noKPError;

  void _signUp() async {
    try {
      final url = Uri.parse('$baseApiUrl/sign-up/'); // Replace with your API URL
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'confirm_password': _confirmPasswordController.text,
          'NoKP': _noKPController.text,
          'Profile': _profileImage != null ? base64Encode(_profileImage!.readAsBytesSync()) : '',
          'Sign': _signImage != null ? base64Encode(_signImage!.readAsBytesSync()) : '',
        }),
      );

      if (response.statusCode == 201) {
        _showMessage('Account created successfully!', Colors.green);
      } else {
        _showMessage('Failed to create account. Please try again.', Colors.red);
      }
    } catch (e) {
      _showMessage('Error: $e', Colors.red);
    }
  }


  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Toggle confirm password visibility
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  // Validate inputs
  void _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _noKPError = null;

      // Validate email
      if (!_emailController.text.endsWith('@aelb.gov.my') &&
          _emailController.text != 'danish25122004@gmail.com') {
        _emailError = 'Email must end with @aelb.gov.my or be danish25122004@gmail.com';
      }

      // Validate password confirmation
      if (_confirmPasswordController.text != _passwordController.text) {
        _passwordError = 'Passwords do not match';
      }


      // If all inputs are valid, show success message
      if (_emailError == null && _passwordError == null && _noKPError == null) {
        _showMessage('All inputs are valid!', Colors.green);
      }
    });
  }

  // Show message (success or error)
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(pickedFile.path);
          } else {
            _signImage = File(pickedFile.path);
          }
        });
      } else {
        _showMessage('No image selected', Colors.red);
      }
    } catch (e) {
      _showMessage('Error picking image: $e', Colors.red);
    }
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
              SizedBox(height: 80),

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
                  child: Text("Login to your account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),)
              ),

              SizedBox(height: 10,),

              // Email Text Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    isPassword: false,
                    errorText: _emailError,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color for input
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, // Soft shadow color
                        blurRadius: 10, // Amount of blur for shadow
                        offset: Offset(0, 5), // Vertical shadow offset
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Password Text Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'Password (8 character only)',
                    isPassword: true,
                    toggleVisibility: _togglePasswordVisibility,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color for input
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, // Soft shadow color
                        blurRadius: 10, // Amount of blur for shadow
                        offset: Offset(0, 5), // Vertical shadow offset
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Confirm Password Text Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  child: _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password (8 character only)',
                    isPassword: true,
                    toggleVisibility: _togglePasswordVisibility,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color for input
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, // Soft shadow color
                        blurRadius: 10, // Amount of blur for shadow
                        offset: Offset(0, 5), // Vertical shadow offset
                      ),
                    ],
                  ),
                ),
              ),

              if (_passwordError != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _passwordError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 20),

              // NoKP Text Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  child: _buildTextField(
                    controller: _noKPController,
                    label: 'NoKP',
                    isPassword: false,
                    errorText: _noKPError,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color for input
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, // Soft shadow color
                        blurRadius: 10, // Amount of blur for shadow
                        offset: Offset(0, 5), // Vertical shadow offset
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Profile Image Input
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Profile Img (JPG only)",
                    style: TextStyle(color: Colors.grey),)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(true), // Pick profile image
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF3B4B4), // Maroon color
                          borderRadius: BorderRadius.circular(50), // Fully rounded border
                        ),
                        child: _profileImage == null
                            ? Center(child: Icon(Icons.account_box, size: 40, color: Colors.white)) // Add photo icon
                            : Image.file(_profileImage!, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Sign Image Input
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Sign Img (JPG only)", style: TextStyle(color: Colors.grey),)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(false), // Pick sign image
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF3B4B4), // Maroon color
                          borderRadius: BorderRadius.circular(50), // Fully rounded border
                        ),
                        child: _signImage == null
                            ? Center(child: Icon(Icons.add_photo_alternate, size: 40, color: Colors.white)) // Add photo icon
                            : Image.file(_signImage!, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Sign Up Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _validateInputs();
                    if (_emailError == null && _passwordError == null && _noKPError == null) {
                      _signUp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF800000), // Maroon color
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40,),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ensures the row only takes up necessary space
                  crossAxisAlignment: CrossAxisAlignment.center, // Aligns both vertically
                  children: [
                    Text('Already Registered? '),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove default padding
                        minimumSize: Size(0, 0), // Ensures no extra space is added
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces hit area to the text size
                      ),
                      onPressed: () {
                        // Navigate to signup page
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
                      },
                      child: Text(
                        'Login Here',
                        style: TextStyle(
                          color: Color(0xFF800000), // Maroon color
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // TextField Widget with error handling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    void Function()? toggleVisibility,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword ? (toggleVisibility != null ? _obscurePassword : false) : false,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white70, width: 0.5), // Initial border color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white70, width: 0.5), // Grey border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF800000)), // Maroon border on focus
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFF800000),
              ),
              onPressed: toggleVisibility,
            )
                : null,
          ),
        ),
        if (errorText != null) // Display error message if exists
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
