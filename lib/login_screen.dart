import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_verification_screen.dart';
import 'services/supabase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final name = _nameController.text.trim();
    final mobile = _phoneController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!SupabaseAuthService.isValidMobile(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phone number. Must be 10 digits starting with 6-9.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send actual OTP via Supabase
      final result = await SupabaseAuthService.sendOTP(mobile);
      final success = result.success;
      
      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'OTP sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Navigate to OTP verification screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                userName: name,
                phoneNumber: mobile,
                verificationId: '', // Not needed for Supabase
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to send OTP. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Image - Flexible height that prevents overflow
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.25,
                  constraints: const BoxConstraints(
                    minHeight: 120,
                    maxHeight: 200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuCjOOYYs7u3YnpnxyMpfpwl7pQp4JUr9f-NPPWp3CLAu3Yj8_79ZnUoaCpUxRZUYyXkP3e5A-w3Q1AuWF4KEMiUWHMb_4qPy4q66QOYzcw_xF3xTpanhwBvWaHsb0etrIW5T_DdddRO_UqWmUhLDpLuU5N5s67YF9v-Zd0Dpmmtm84mPTUFeYgF5nQvAIhBL7M_u_qyj5Yp61fweSzEXyJK9xvpG3nElYOL9DaSqctCc05Yi1pJBhfR4tLI9UWDnMcUoRMdlPfkuVI",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F1F4),
                          child: const Icon(Icons.error, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Welcome Back Title
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF111317),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Enter your details to log in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF111317),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                
                const SizedBox(height: 32),

                // Name Input Field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: const TextStyle(fontFamily: 'Manrope', color: Color(0xFF646D87)),
                    filled: true,
                    fillColor: const Color(0xFFF0F1F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF111317),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 16),

                // Mobile Number Input Field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    hintStyle: const TextStyle(fontFamily: 'Manrope', color: Color(0xFF646D87)),
                    filled: true,
                    fillColor: const Color(0xFFF0F1F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    counterText: '', // Hide character counter
                  ),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF111317),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F68E4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),

                // Bottom padding to handle keyboard and prevent overflow
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
