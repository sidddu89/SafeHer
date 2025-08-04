// This file is deprecated. Use otp_verification_screen.dart instead.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // Added for jsonEncode
import 'package:http/http.dart' as http; // Added for http

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
<<<<<<< HEAD
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });
=======
  const OtpScreen({super.key, required this.phoneNumber, required this.verificationId});
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  void _verifyOtp() async {
    setState(() => _loading = true);
    final smsCode = _otpController.text.trim();
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() => _loading = false);
<<<<<<< HEAD
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserDetailsScreen(phoneNumber: widget.phoneNumber),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid OTP')));
      }
=======
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsScreen(phoneNumber: widget.phoneNumber),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
<<<<<<< HEAD
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 36,
              ),
=======
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 36),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter the OTP sent to',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.phoneNumber,
<<<<<<< HEAD
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
=======
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
<<<<<<< HEAD
                    decoration: const InputDecoration(labelText: 'OTP'),
=======
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                    ),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _verifyOtp,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Verify'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserDetailsScreen extends StatefulWidget {
  final String phoneNumber;
  const UserDetailsScreen({super.key, required this.phoneNumber});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
<<<<<<< HEAD
  final List<TextEditingController> _contactNameControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _contactPhoneControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
=======
  final List<TextEditingController> _contactNameControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _contactPhoneControllers = List.generate(5, (_) => TextEditingController());
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
  bool _loading = false;

  void _submit() async {
    final name = _nameController.text.trim();
<<<<<<< HEAD
    final contacts = List.generate(
      5,
      (i) => {
        'name': _contactNameControllers[i].text.trim(),
        'phone': _contactPhoneControllers[i].text.trim(),
      },
    );
    if (name.isEmpty ||
        contacts.any((c) => c['name']!.isEmpty || c['phone']!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields.')));
=======
    final contacts = List.generate(5, (i) => {
      'name': _contactNameControllers[i].text.trim(),
      'phone': _contactPhoneControllers[i].text.trim(),
    });
    if (name.isEmpty || contacts.any((c) => c['name']!.isEmpty || c['phone']!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
      return;
    }
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'name': name,
        'phone': widget.phoneNumber,
        'emergencyContacts': contacts,
      }),
    );
    setState(() => _loading = false);
<<<<<<< HEAD
    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile saved!')));
        // Navigate to home or dashboard
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile.')));
      }
=======
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved!')),
      );
      // Navigate to home or dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile.')),
      );
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Details'),
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
<<<<<<< HEAD
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
=======
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
=======
                    const Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                    TextField(controller: _nameController),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
<<<<<<< HEAD
                        const Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Skip emergency contacts, just submit name
                            if (_nameController.text.trim().isEmpty) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please enter your name.'),
                                  ),
                                );
                              }
=======
                        const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                        TextButton(
                          onPressed: () {
                            // Skip emergency contacts, just submit name
                            if (_nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please enter your name.')),
                              );
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                              return;
                            }
                            setState(() => _loading = true);
                            // Submit with empty contacts
                            final user = FirebaseAuth.instance.currentUser;
<<<<<<< HEAD
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );
                            try {
                              final idToken = await user!.getIdToken();
=======
                            user!.getIdToken().then((idToken) async {
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                              final response = await http.post(
                                Uri.parse('http://localhost:5000/api/profile'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $idToken',
                                },
                                body: jsonEncode({
                                  'name': _nameController.text.trim(),
                                  'phone': widget.phoneNumber,
                                  'emergencyContacts': [],
                                }),
                              );
                              setState(() => _loading = false);
<<<<<<< HEAD
                              if (mounted) {
                                if (response.statusCode == 200) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text('Profile saved!')),
                                  );
                                  // Navigate to home or dashboard
                                } else {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to save profile.'),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              setState(() => _loading = false);
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Error saving profile: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...List.generate(
                      5,
                      (i) => Column(
                        children: [
                          TextField(
                            controller: _contactNameControllers[i],
                            decoration: InputDecoration(
                              labelText: 'Contact ${i + 1} Name',
                            ),
                          ),
                          TextField(
                            controller: _contactPhoneControllers[i],
                            decoration: InputDecoration(
                              labelText: 'Contact ${i + 1} Phone',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
=======
                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Profile saved!')),
                                );
                                // Navigate to home or dashboard
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to save profile.')),
                                );
                              }
                            });
                          },
                          child: const Text('Skip', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...List.generate(5, (i) => Column(
                      children: [
                        TextField(
                          controller: _contactNameControllers[i],
                          decoration: InputDecoration(labelText: 'Contact ${i+1} Name'),
                        ),
                        TextField(
                          controller: _contactPhoneControllers[i],
                          decoration: InputDecoration(labelText: 'Contact ${i+1} Phone'),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                      ],
                    )),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
<<<<<<< HEAD
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save'),
=======
                        child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save'),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
} 
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
