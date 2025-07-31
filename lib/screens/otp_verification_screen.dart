import 'package:flutter/material.dart';

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

  void _verifyOtp() {
    // TODO: Implement OTP verification logic
    Navigator.pushReplacementNamed(context, '/home');
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
                    'Enter the 4-digit OTP sent to your phone number.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Resend in 00:${_seconds.toString().padLeft(2, '0')}', style: TextStyle(color: Colors.black54)),
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
                      child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Verify OTP'),
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