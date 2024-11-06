import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_constants.dart';
import 'account.dart';
import 'help.dart';
import 'login.dart';


class Home extends StatefulWidget {
  final String noSiri;
  const Home({super.key, required this.noSiri});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  bool isFlipped = false;
  Map<String, dynamic>? officerData;
  Map<String, dynamic>? historyData;
  int _selectedIndex = 0;
  late PageController _pageController;
  //String? generatedToken;

  static const String termsText =
      'By using the e-Kad Kuasa application, you agree to:\n\n'
      '• Adhere to all applicable laws and regulations regarding the use of sensitive information.\n'
      '• Not use the e-Kad Kuasa ID card for forging documents or identity theft.\n'
      '• Ensure that the information contained within this application remains confidential and is not disclosed to unauthorized parties.\n'
      '• Use this application responsibly and ethically.';

  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;
  bool isDarkMode = false;
  bool _isVisible = false;

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveDarkModePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> _checkTermsAcceptance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasAcceptedTerms = prefs.getBool('hasAcceptedTerms');

    if (hasAcceptedTerms == null || !hasAcceptedTerms) {
      _showTermsDialog();
    }
  }


  Future<void> _showTermsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Dialog(
            backgroundColor: isDarkMode ? const Color(0xFF252525) : Colors.white, // Background color
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                Image.asset(
                  'assets/logoAtom.png', // Replace with your image asset
                  width: 200, // Adjust the height as needed
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black, // Title text color
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        termsText,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black, // Regular text color
                          fontSize: 10
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: isDarkMode ? const Color(0xFFE00A24) : const Color(0xFF800000), // Highlighted button color
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Accept'),
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('hasAcceptedTerms', true);
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: isDarkMode ? const Color(0xFFFF3B3B) : Colors.black, // Text color for decline button
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Decline'),
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.clear(); // Clear all shared preferences
                              SystemNavigator.pop(); // Exit the app
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //-----------------------------------start of cache data code--------------------------------------

  // Timer? _timer;
  // bool _isOnline = false;
  //
  // void startMonitoring() {
  //   _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
  //     bool currentStatus = await isOnline();
  //
  //     if (currentStatus) {
  //       if (!_isOnline) {
  //         // Device has come online; trigger API fetching function
  //         await fetchHistoryData(); // Replace this with your actual API call
  //         await fetchOfficerData();
  //         print('Device is online. Fetching data...');
  //       }
  //     } else {
  //       // Device is offline; show notification
  //       if (_isOnline) {
  //         _showNotification(); // Call the method to show the notification only if offline
  //       }
  //     }
  //
  //     _isOnline = currentStatus; // Update the current status
  //   });
  // }
  Future<bool> isOnline2() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Device has internet access
      }
    } on SocketException catch (_) {
      _showNotification(); // Call the method to show the notification
      return false; // No internet access
    }
    return false;
  }

  void _showNotification() {
    setState(() {
      _isVisible = true; // Show the notification
    });

    // Hide the notification after 2 seconds
    Timer(const Duration(seconds: 5), () {
      setState(() {
        _isVisible = false; // Hide the notification
      });
    });
  }

  // // Function to create the iOS-style notification display
  Widget iosNotificationDisplay(String message, {String title = 'Notification'}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You are Offline",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            "It seems you're offline. We are displaying the last available data. Please connect to the internet to access the latest updates.",
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  // late final double latitude;
  // late final double longitude;
  //
  // Future<void> _fetchCurrentLocation() async {
  //   // Check if location services are enabled
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     setState(() {
  //       _locationMessage = 'Location services are disabled.';
  //     });
  //     return;
  //   }
  //
  //   // Check for location permission
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       setState(() {
  //         _locationMessage = 'Location permissions are denied.';
  //       });
  //       return;
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     setState(() {
  //       _locationMessage = 'Location permissions are permanently denied.';
  //     });
  //     return;
  //   }
  //
  //   // Fetch the current location
  //   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _locationMessage = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  //   });
  // }

  // Check if the device is online
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Device has internet access
      }
    } on SocketException catch (_) {
      //_showNotification(); // Call the method to show the notification
      return false; // No internet access
    }
    return false;
  }
// Fetch officer data and cache it when online
  Future<void> fetchOfficerData() async {
    final box = Hive.box('cacheBox');
    bool online = await isOnline();

    if (online) {
      final url = Uri.parse('$baseApiUrl/officer/${widget.noSiri}/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          officerData = jsonData['officer'] as Map<String, dynamic>; // Explicitly cast to Map<String, dynamic>
          box.put('officerData', officerData); // Cache the data locally
          isLoading = false;
        });
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login(),));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clear all shared preferences
      }
    } else {
      // Fetch cached officer data if offline
      final cachedData = box.get('officerData');

      // Check if cachedData is of type Map<dynamic, dynamic> and convert
      if (cachedData is Map) {
        // Convert to Map<String, dynamic>
        officerData = Map<String, dynamic>.from(cachedData);
        setState(() {
          isLoading = false;
        });
      } else {
        // Handle case where no cached data is available
      }
    }
  }

// Fetch history data and cache it when online
  Future<Map<String, dynamic>> fetchHistoryData() async {
    final box = Hive.box('cacheBox');
    bool online = await isOnline();

    if (online) {
      final url = Uri.parse('$baseApiUrl/recordView/${widget.noSiri}/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        box.put('historyData', jsonData); // Cache the history data locally
        return jsonData; // Return the data fetched from the API
      } else {
        // Handle error, return an empty map or throw an exception
        return {}; // Return an empty map to indicate failure
      }
    } else {
      // Fetch cached history data if offline
      final cachedData = box.get('historyData');

      // Ensure we handle type casting correctly
      if (cachedData is Map) {
        return Map<String, dynamic>.from(cachedData); // Safely convert to Map<String, dynamic>
      } else {
        return {}; // Return an empty map if none
      }
    }
  }
  //-----------------------------------end of cache data code-------------------------------------


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchOfficerData();
    _checkTermsAcceptance();
    _loadDarkModePreference();
    isOnline2();
    //generateQrCodeToken(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to handle bottom navigation taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
    }
    _pageController.jumpToPage(index);
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th'; // 11th, 12th, 13th are exceptions
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Clear login status
    await prefs.remove('NoSiri'); // Optionally clear NoSiri
    await prefs.remove('hasAcceptedTerms');

    // Navigate to the login page after logging out
    Navigator.pushReplacement(
      context, PageTransition(
        type: PageTransitionType.fade,
        curve: Curves.easeOut,
        child: const Login()),
    );
  }

  //---------------------------------encrypted generateQrCodeToken API-------------------------
  //Future<void> generateQrCodeToken(BuildContext context) async {
  //  SharedPreferences prefs = await SharedPreferences.getInstance();
//
  //  String retrievedNoSiri = prefs.getString('NoSiri') ?? '';
  //  String retrievedPassword = prefs.getString('Password') ?? '';


  // Map<String, String> data = {
  //    'email': retrievedNoSiri,
//    'password': retrievedPassword,
//    };
//
  //  final response = await http.post(
  //  Uri.parse('http://${apiLink}/api/generated-token/'),
  //  headers: {
//    'Content-Type': 'application/json'
  //    },
  //  body: jsonEncode(data),
  //);

    // Check the response
  //if (response.statusCode == 200) {
  //  print('Data sent successfully!');
  //  // Handle the token received from the API
  //  String token = jsonDecode(response.body)['token'];
  //  print('Token: $generatedToken');
  //  setState(() {
//    generatedToken = token; // Update the state with the new token
  //    });

//  startCountdownTimer(context);
  //  } else {
//  print('Error sending data: ${response.statusCode}');
//  }
  //}

  //void startCountdownTimer(BuildContext context) {
  //  const duration = Duration(minutes: 5);
  //  Timer(duration, () {
  //    // Automatically request a new token after 5 minutes
  //    print('Token expired, requesting a new token...');
  //    generateQrCodeToken(context); // Call the function again to generate a new token
  //  });
  //}

  Widget _buildCard() {
    return Card(
      color: isDarkMode ? const Color(0xFF252525) : Colors.white, // Card background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Check the Status
            if (officerData?['Status'] == 1) ...[
              // If Status is 1, show the current content
              Stack(
                alignment: Alignment.center, // Center the QR code
                children: [
                  // Front ID Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(officerData!['KadKuasa'].split(',').last), // Decode base64 if needed
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // QR Code
                  Positioned(
                    bottom: 3, // Change this value to move the QR code up/down
                    right: 1, // Change this value to move the QR code left/right
                    child: QrImageView(
                      data: "http://$baseDNS/user_authorized/${officerData!['NoSiri']}",
                      version: QrVersions.auto,
                      size: 80.0, // Set size of the QR code
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Back Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(officerData!['KadKuasaBelakang'].split(',').last),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (officerData?['Status'] == 0) ...[
              // If Status is 0, show invalid content
              Column(
                children: [
                  Icon(
                    Icons.cancel, // Big red invalid icon
                    color: isDarkMode ? const Color(0xFFFF3B3B) : Colors.red, // Icon color based on dark mode
                    size: 100, // Adjust size as needed
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Your e-Kad Kuasa is no longer valid",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFD32F2F) : Colors.red, // Title text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Contact UrusSetia KadKuasa if there's been a mistake.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? const Color(0xFFB3B3B3) : Colors.black54, // Regular text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ] else ...[
              // Handle other cases or unknown status
              Text(
                "Status unknown or not provided.",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Text color for unknown status
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Background color
      body: Stack(
          children: [
            officerData == null
              ? Center(
            child: LoadingAnimationWidget.halfTriangleDot(
              color: isDarkMode ? const Color(0xFFFF3B3B) : const Color(0xFF800000), // Loading animation color
              size: 50,
            ),
          )
              : PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              // Home Page
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Welcome Message and Officer's Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 50),
                                Text(
                                  'Welcome,',
                                  style: TextStyle(color: isDarkMode ? const Color(0xFFB3B3B3) : Colors.grey, fontSize: 16), // Welcome text color
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Officer Name Text
                                    Expanded(
                                      child: Text(
                                        officerData?['Nama'] ?? 'Loading...',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode ? const Color(0xFFE5E5E5) : const Color(0xFF800000), // Officer name color
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      officerData?['Status'] == 1
                                          ? Icons.check_circle // Green tick icon
                                          : officerData?['Status'] == 0
                                          ? Icons.cancel // Red cross icon
                                          : Icons.help_outline, // Default icon if status is unknown
                                      color: officerData?['Status'] == 1
                                          ? Colors.blue[300]
                                          : officerData?['Status'] == 0
                                          ? Colors.red[300]
                                          : Colors.grey, // Default color if status is unknown
                                      size: 24, // Adjust icon size as needed
                                    ),
                                    const SizedBox(width: 90),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.settings_outlined, size: 28, color: isDarkMode ? Colors.white30 : Colors.black38), // Icon color based on theme
                            onSelected: (String value) {
                              switch (value) {
                                case 'Dark Mode':
                                // Implement theme toggling functionality here
                                  break;
                                case 'Account':
                                  Navigator.push(
                                    context, PageTransition(
                                      type: PageTransitionType.fade,
                                      curve: Curves.easeOut,
                                      child: Account(officerData: officerData)),
                                  );
                                  break;
                                case 'Help Center':
                                  Navigator.push(
                                    context, PageTransition(
                                      type: PageTransitionType.fade,
                                      curve: Curves.easeOut,
                                      child: const HelpCentre()),
                                  );
                                  break;
                                case 'Log Out':
                                  _logout(context); // Call the logout function
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                'Dark Mode',
                                'Account',
                                'Help Center',
                                'Log Out',
                              ].map((String option) {
                                return PopupMenuItem<String>(
                                  value: option,
                                  padding: EdgeInsets.zero, // Remove padding for a cleaner look
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding for each item
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space items apart
                                          children: [
                                            Text(
                                              option,
                                              style: TextStyle(
                                                fontSize: 16, // Adjust font size
                                                fontWeight: FontWeight.w500, // Medium weight for better emphasis
                                                color: isDarkMode ? const Color(0xFFB3B3B3) : Colors.black, // Item text color
                                              ),
                                            ),
                                            if (option == 'Dark Mode') ...[
                                              Switch(
                                                value: isDarkMode, // Replace with your theme state
                                                onChanged: (value) {
                                                  setState(() {
                                                    isDarkMode = value;
                                                  });
                                                  _saveDarkModePreference(value);
                                                  Navigator.pop(context);
                                                },
                                                activeColor: Colors.red,          // Color of the thumb when the switch is on
                                                activeTrackColor: Colors.red[200], // Color of the track when the switch is on
                                                inactiveThumbColor: Colors.grey,   // Color of the thumb when the switch is off
                                                inactiveTrackColor: Colors.grey[300], // Color of the track when the switch is off
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (option != 'Log Out') Divider(height: 1, color: isDarkMode ? const Color(0xFF3B3B3B) : Colors.grey.shade300), // Subtle line between options
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Rounded corners for the whole menu
                            ),
                            color: isDarkMode ? const Color(0xFF252525) : Colors.white, // Menu background color
                          )
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Profile Section
                      Card(
                        color: isDarkMode ? const Color(0xFF252525) : Colors.white, // Card background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Profile Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(officerData!['ProfileURL'].split(',').last),
                                  height: 120,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Officer Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      officerData!['Nama'] ?? 'Loading...',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? const Color(0xFFE5E5E5) : Colors.black, // Officer name color
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'No KP: ${officerData!['NoKP'] ?? ''}',
                                      style: TextStyle(
                                        color: isDarkMode ? const Color(0xFFB3B3B3) : Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Jawatan: ${officerData!['Jawatan'] ?? ''}',
                                      style: TextStyle(
                                        color: isDarkMode ? const Color(0xFFB3B3B3) : Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // My Info Section
                      const Text(
                        'MY CARD',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB3B3B3),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Digital ID Images
                      _buildCard(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // QR Code Section
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),

                        // Main Heading (Scan Here!)
                        Text(
                          "Scan Here!",
                          style: TextStyle(
                            fontSize: 34, // Increase font size for the main heading
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? const Color(0xFFFF3B3B) : const Color(0xFF800000), // Dark red color for emphasis
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8), // Slight space below the heading

                        // Subheading (Show your QR to access your personal Atom website)
                        Text(
                          "Show your QR to access your personal Atom website",
                          style: TextStyle(
                            fontSize: 18, // Smaller size for subheading
                            color: isDarkMode ? const Color(0xFF8C8C8C) : Colors.black54, // Lighter color for a softer tone
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30), // More space after subheading

                        // Neumorphic QR Code Card
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Background color (#f5fbff)
                            borderRadius: BorderRadius.circular(50), // Border radius of 50px
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode ? const Color(0xFF292929) : const Color(0xFFE1E7EB), // Dark shadow color (#e1e7eb)
                                offset: const Offset(5, 5), // Offset for the dark shadow (5px 5px)
                                blurRadius: 10, // Blur radius of 10px
                              ),
                              BoxShadow(
                                color: isDarkMode ? const Color(0xFF252525) : const Color(0xFFE1E7EB), // Light shadow color (#ffffff)
                                offset: const Offset(-2, -2), // Offset for the light shadow (-5px -5px)
                                blurRadius: 10, // Blur radius of 10px
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (officerData?['Status'] == 1) ...[
                                  // QR Code if Status is 1
                                  QrImageView(
                                    data: "http://$baseDNS/user_authorized/${officerData!['NoSiri']}/",
                                    version: QrVersions.auto,
                                    size: 350.0, // Adjust size as needed
                                    foregroundColor: isDarkMode ? const Color(0xFFE5E5E5) : const Color(0xFF800000), // White pixels
                                    backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Dark background
                                    // eyeStyle: const QrEyeStyle(
                                    //   eyeShape: QrEyeShape.circle, // Makes the corners of the eyes round
                                    //   color: Colors.white, // Color for the eyes
                                    // ),
                                    // dataModuleStyle: const QrDataModuleStyle(
                                    //   dataModuleShape: QrDataModuleShape.circle, // Makes the data modules (pixels) rounded
                                    //   color: Colors.white, // Color for the data modules
                                    // ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.5),
                                    child: Text(
                                      "Do not share this QR code with unauthorized personnel. It contains sensitive information.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ] else if (officerData?['Status'] == 0) ...[
                                  // Invalid status content
                                  const Column(
                                    children: [
                                      Icon(
                                        Icons.cancel, // Big red invalid icon
                                        color: Colors.red,
                                        size: 100, // Adjust size as needed
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "QR Code Invalid",
                                        style: TextStyle(
                                          fontSize: 24, // Emphasize this message more
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Please contact Urus Setia KadKuasa if there's been a mistake.",
                                        style: TextStyle(
                                          fontSize: 16, // Slightly smaller than the error heading
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // Handle other status cases
                                  const Text(
                                    "Status unknown or not provided.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30), // Additional spacing after QR code card

                        // Optional Footer text or additional info can go here
                      ],
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      // Header
                      const Text(
                        'History',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      // Bar Chart
                      FutureBuilder(
                        future: fetchHistoryData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 190),
                              child: Center(
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: isDarkMode ? const Color(0xFFFF3B3B) : const Color(0xFF800000), // Loading animation color
                                  size: 90,
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            Map<String, dynamic>? data = snapshot.data as Map<String, dynamic>?;

                            if (data != null && data['raw'] != null && data['raw'].isNotEmpty) {
                              // Extract the raw data
                              List<List<dynamic>> rawData = List<List<dynamic>>.from(data['raw']);

                              // Create lists for counts and days
                              List<int> counts = rawData.map((entry) => entry[1] as int).toList();
                              List<int> days = rawData.map((entry) => entry[0] as int).toList();

                              // Create a mapping of days to counts
                              Map<int, int> dayCountMap = Map.fromIterables(days, counts);

                              return SizedBox(
                                height: 300, // Set a fixed height for the chart
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceEvenly,
                                    maxY: counts.reduce((a, b) => a > b ? a : b).toDouble() + 1, // Add 1 for better padding
                                    barGroups: days.map<BarChartGroupData>((day) {
                                      return BarChartGroupData(
                                        x: day - 1, // Adjust index for 0-based
                                        barRods: [
                                          BarChartRodData(
                                            toY: dayCountMap[day]?.toDouble() ?? 0,
                                            gradient: LinearGradient(
                                              colors: isDarkMode ? [const Color(0xFFBF2828), const Color(0xFF550E0E)] : [Colors.redAccent,  const Color(0xFF800000),], // Gradient color for bars
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            width: 15, // Bar width
                                            borderRadius: BorderRadius.circular(6), // Rounded corners
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: 1, // Force integer intervals
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDarkMode ? const Color(0xFFE5E5E5) : Colors.black54, // Subtle axis label color
                                              ),
                                            );
                                          },
                                        ),
                                        axisNameWidget: Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            'Count',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? const Color(0xFFE5E5E5) : Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            int index = value.toInt();
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                index < days.length ? days[index].toString() : '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDarkMode ? const Color(0xFFE5E5E5) : Colors.black54,  // Axis label color
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        axisNameWidget: const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'Days',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                          color: isDarkMode ? const Color(0xFF3B3B3B) : Colors.grey.shade200
                                      ), // Subtle border color
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: true,
                                      drawHorizontalLine: true,
                                      verticalInterval: 1, // Ensure vertical grid lines at each bar
                                      horizontalInterval: 1, // Horizontal grid interval
                                      getDrawingVerticalLine: (value) {
                                        return FlLine(
                                            color: isDarkMode ? const Color(0xFF3B3B3B) : Colors.grey.shade200,
                                            strokeWidth: 1
                                        ); // Subtle vertical grid lines
                                      },
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                            color: isDarkMode ? const Color(0xFF3B3B3B) : Colors.grey.shade200,
                                            strokeWidth: 1
                                        ); // Subtle horizontal grid lines
                                      },
                                    ),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '${days[group.x.toInt()]}: ${rod.toY.toInt()}',
                                            TextStyle(
                                              color: isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        tooltipMargin: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const Center(child: Text('No History'));
                            }
                          } else {
                            return const Center(child: Text('No data available'));
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // List View
                      FutureBuilder(
                        future: fetchHistoryData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data is Map<String, dynamic>) {
                              Map<String, dynamic>? data = snapshot.data;
                              if (data?['raw'] != null && data?['raw'].isNotEmpty) {
                                return SizedBox(
                                  height: 350.0, // Set the height for the scrollable ListView
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: data?['raw'].length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                        child: Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          color: isDarkMode ? const Color(0xFF252525) : Colors.white,
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                            title: Text(
                                              '${data?['raw'][index][0].toString()}${getDaySuffix(data?['raw'][index][0])} ${data?["month_name"]} 2024',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode ? const Color(0xFFFF3B3B) : const Color(0xFF800000),
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Count: ${data?['raw'][index][1].toString()}',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: isDarkMode ? const Color(0xFFB3B3B3) : Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return const Center(child: Text('No History', style: TextStyle(fontSize: 16.0)));
                              }
                            } else {
                              return const Center(child: Text('Invalid data', style: TextStyle(fontSize: 16.0)));
                            }
                          } else {
                            return const Center(child: Text(""));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            //Notification Widget
            if (_isVisible) // Show notification if _isVisible is true
              Positioned(
                top: 50, // Adjust position as needed
                left: 0,
                right: 0,
                child: iosNotificationDisplay("You are Offline"), // Call your notification display method
              ),
          ]
      ),


      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Padding to float
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ), // Rounded corners
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), // Animation duration
            curve: Curves.easeInOut, // Smooth animation curve
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFFFF3B3B) : const Color(0xFF800000), // Red background color // Rounded corners for the floating effect
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5), // Shadow color with transparency
                  blurRadius: 10, // Soft shadow blur
                  offset: const Offset(0, 5), // Shadow position
                ),
              ],
            ),
            child: BottomNavigationBar(
              elevation: 0, // No default elevation (shadow)
              backgroundColor: Colors.transparent, // Transparent background to match container
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300), // Animation for icon size
                    child: const Icon(Icons.home, color: Colors.white),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300), // Animation for icon size
                    child: const Icon(Icons.qr_code_2, color: Colors.white),
                  ),
                  label: 'QR Code',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300), // Animation for icon size
                    child: const Icon(Icons.history, color: Colors.white),
                  ),
                  label: 'History',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,// Emphasize selected text
              showUnselectedLabels: false,
              selectedIconTheme: const IconThemeData(size: 40),
              unselectedIconTheme: const IconThemeData(size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
