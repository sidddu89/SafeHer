import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.verificationId,
  });

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _seconds = 30;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 30;
    Future.doWhile(() async {
      if (_seconds == 0) return false;
      await Future.delayed(Duration(seconds: 1));
      if (mounted) setState(() => _seconds--);
      return _seconds > 0;
    });
  }

  void _verifyOtp() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the 4-digit OTP.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, '/contacts');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.code}\n${e.message ?? ''}'),
        ),
      );
    }
  }

  void _resendOtp() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}', // Assuming India's country code
        verificationCompleted: (PhoneAuthCredential credential) async {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auto-verification completed!')),
          );
          // Auto-verification logic can be handled here if needed.
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _loading = false);
          String errorMessage = 'Failed to resend OTP';
          if (e.code == 'too-many-requests') {
            errorMessage = 'Too many attempts. Please try again later.';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _loading = false;
            _seconds = 30;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP has been resent.')),
          );
          _startTimer(); // Restart timer
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if necessary
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      // Ignored: Could not resend OTP.
      debugPrint('Resend OTP error: $e');

    }
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('OTP Verification'),
        backgroundColor: Color(0xFFFF8A80),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the 4-digit OTP (try 1234 for demo).',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      width: 48,
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        controller: _otpControllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.length == 1 && i < 3) {
                            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                          } else if (val.isEmpty && i > 0) {
                            FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
                          }
                        },
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Resend in 00:${_seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: _seconds == 0 && !_loading ? _resendOtp : null,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: _seconds == 0 && !_loading ? Color(0xFFFF8A80) : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color(0xFFFF8A80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Verify OTP'),
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
