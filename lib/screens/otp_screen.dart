// This file is deprecated. Use otp_verification_screen.dart instead.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // Added for jsonEncode
import 'package:http/http.dart' as http; // Added for http

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const OtpScreen({super.key, required this.phoneNumber, required this.verificationId});

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 36),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                    ),
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
  final List<TextEditingController> _contactNameControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _contactPhoneControllers = List.generate(5, (_) => TextEditingController());
  bool _loading = false;

  void _submit() async {
    final name = _nameController.text.trim();
    final contacts = List.generate(5, (i) => {
      'name': _contactNameControllers[i].text.trim(),
      'phone': _contactPhoneControllers[i].text.trim(),
    });
    if (name.isEmpty || contacts.any((c) => c['name']!.isEmpty || c['phone']!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                    TextField(controller: _nameController),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                        TextButton(
                          onPressed: () {
                            // Skip emergency contacts, just submit name
                            if (_nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please enter your name.')),
                              );
                              return;
                            }
                            setState(() => _loading = true);
                            // Submit with empty contacts
                            final user = FirebaseAuth.instance.currentUser;
                            user!.getIdToken().then((idToken) async {
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save'),
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
} 