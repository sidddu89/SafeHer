import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  void _continue() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name and phone number.')),
      );
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number must be exactly 10 digits.')),
      );
      return;
    }
    setState(() {
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          setState(() {
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Auto-verification completed!')),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _loading = false;
          });
          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many attempts. Please try again later.';
          } else if (e.code == 'captcha-check-failed') {
            errorMessage = 'reCAPTCHA verification failed. Please try again.';
          } else if (e.code == 'network-request-failed') {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _loading = false;
          });
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: {
              'name': name,
              'phone': phone,
              'verificationId': verificationId,
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'SMS code retrieval timeout. Please check your messages.',
              ),
            ),
          );
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 36,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF8A80),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Icon(Icons.shield, size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SafeHer',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to SafeHer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your safety, our mission',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixText: '+91 ',
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color(0xFFFF8A80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Note: If you encounter reCAPTCHA issues, please disable reCAPTCHA in Firebase Console under Authentication → Settings → Sign-in method → Phone',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
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
