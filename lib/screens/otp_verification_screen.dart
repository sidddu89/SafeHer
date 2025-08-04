import 'package:flutter/material.dart';
<<<<<<< HEAD
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
=======

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _seconds = 30;
  final bool _loading = false;
  late String name;
  late String phone;

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    name = args?['name'] ?? '';
    phone = args?['phone'] ?? '';
    super.didChangeDependencies();
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
    _startTimer();
  }

  void _startTimer() {
    _seconds = 30;
    Future.doWhile(() async {
      if (_seconds == 0) return false;
      await Future.delayed(Duration(seconds: 1));
<<<<<<< HEAD
      if (mounted) {
        setState(() {
          _seconds--;
        });
      }
=======
      if (mounted) setState(() => _seconds--);
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
      return _seconds > 0;
    });
  }

<<<<<<< HEAD
  void _verifyOtp() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter the 4-digit OTP.')));
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _loading = false;
      });
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/contacts');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.code}\n${e.message ?? ''}'),
          ),
        );
      }
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
=======
  void _verifyOtp() {
    // TODO: Implement OTP verification logic
    Navigator.pushReplacementNamed(context, '/home');
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('OTP Verification'),
<<<<<<< HEAD
        backgroundColor: Color(0xFF4F8DFF),
=======
        backgroundColor: Color(0xFFFF8A80),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 8,
<<<<<<< HEAD
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 36,
              ),
=======
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
<<<<<<< HEAD
                    'Enter the 4-digit OTP (try 1234 for demo).',
=======
                    'Enter the 4-digit OTP sent to your phone number.',
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
<<<<<<< HEAD
                    children: List.generate(
                      4,
                      (i) => Container(
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
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[i + 1]);
                            } else if (val.isEmpty && i > 0) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[i - 1]);
                            }
                          },
=======
                    children: List.generate(4, (i) =>
                      Container(
                        width: 48,
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, letterSpacing: 8),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
<<<<<<< HEAD
                  Text(
                    'Resend in 00: ${_seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.black54),
                  ),
=======
                  Text('Resend in 00:${_seconds.toString().padLeft(2, '0')}', style: TextStyle(color: Colors.black54)),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
<<<<<<< HEAD
                        backgroundColor: Color(0xFF4F8DFF),
=======
                        backgroundColor: Color(0xFFFF8A80),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
<<<<<<< HEAD
                      child: _loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Verify OTP'),
=======
                      child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Verify OTP'),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
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
<<<<<<< HEAD
}
=======
} 
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
