import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  void _continue() {
    // Validate and navigate to OTP screen
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name and phone number.')),
      );
      return;
    }
    Navigator.pushNamed(context, '/otp', arguments: {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                    ),
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
                      child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color(0xFFFF8A80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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