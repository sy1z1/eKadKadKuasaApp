import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Account extends StatefulWidget {
  final Map<String, dynamic>? officerData;
  const Account({Key? key, required this.officerData}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isDarkMode = false; // Dark mode toggle state

  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

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

  @override
  Widget build(BuildContext context) {
    final officer = widget.officerData!;
    String statusText = officer['Status'] == 1 ? 'Active' : 'Resigned';
    Color statusColor = officer['Status'] == 1 ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20,),

              Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded),
                      color: isDarkMode ? Colors.white38 : Colors.black,
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(noSiri: officer['NoSiri']),));
                      },

                    ),
                    SizedBox(width: 100,)
                  ]
              ),

              // Profile Header
              Row(
                children: [
                  // Profile Image
                  ClipOval(
                    child: Image.memory(
                      base64Decode(officer['ProfileURL'].split(',').last),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Officer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          officer['Nama'] ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Color(0xFFE5E5E5) : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No KP: ${officer['NoKP'] ?? ''}',
                          style: TextStyle(
                            color: isDarkMode ? Color(0xFFB3B3B3) : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jawatan: ${officer['Jawatan'] ?? ''}',
                          style: TextStyle(
                            color: isDarkMode ? Color(0xFFB3B3B3) : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Status (Active/Resigned)
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(
                                color: isDarkMode ? Color(0xFFB3B3B3) : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Personal Information Section
              Card(
                color: isDarkMode ? Color(0xFF252525) : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Color(0xFFFF3B3B) : Color(0xFF800000),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.email, color: isDarkMode ? Color(0xFFFF3B3B) : Color(0xFF800000)),
                        title: Text (
                          'Email',
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        subtitle: Text(
                          officer['Email'] ?? '',
                          style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey[600]),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.credit_card_rounded, color: isDarkMode ? Color(0xFFFF3B3B) : Color(0xFF800000)),
                        title: Text(
                          'KadKuasa Created On',
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        subtitle: Text(
                          officer['TarikhKeluar'] ?? '',
                          style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey[600]),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.link, color: isDarkMode ? Color(0xFFFF3B3B) : Color(0xFF800000)),
                        title: Text(
                          'Website',
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        subtitle: Text(
                          "https://www.aelb.gov.my/v2/kadkuasa/${officer['Bahagian']}",
                          style: TextStyle(color: isDarkMode ? Color(0xFF26C6DA) : Color(0xFF800000)),
                        ),
                        onTap: () {
                          // Open the personal website link
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Settings Section
              Card(
                color: isDarkMode ? Color(0xFF252525) : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Color(0xFFFF3B3B) : Color(0xFF800000),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.lock, color: isDarkMode ? Color(0xFFFF3B3B) : Color(0xFF800000)),
                        title: Text(
                          'Change Password',
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        onTap: () {
                          // Change password action
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.brightness_6, color: isDarkMode ? Color(0xFFFF3B3B) : Color(0xFF800000)),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              isDarkMode = value;
                            });
                            _saveDarkModePreference(value);
                          },
                          activeColor: Colors.red,          // Color of the thumb when the switch is on
                          activeTrackColor: Colors.red[200], // Color of the track when the switch is on
                          inactiveThumbColor: Colors.grey,   // Color of the thumb when the switch is off
                          inactiveTrackColor: Colors.grey[300], // Color of the track when the switch is off
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}