// This file is deprecated. Use registration_screen.dart instead.
import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;

  void _sendOtp() async {
    final phone = '+91${_phoneController.text.trim()}';
    setState(() => _loading = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto sign-in (optional)
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: \\${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _loading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: phone,
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(Icons.shield, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to SafeHer',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your safety, our mission',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixText: '+91 ',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _loading
                          ? null
                          : () {
                              if (_phoneController.text.trim().isNotEmpty) {
                                _sendOtp();
                              }
                            },
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Send OTP'),
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