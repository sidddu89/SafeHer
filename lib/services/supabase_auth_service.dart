import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

// Simple result type to avoid record accessor issues across SDKs
class OtpSendResult {
  final bool success;
  final String? message;
  const OtpSendResult({required this.success, this.message});
}

class SupabaseAuthService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Send OTP to phone number via SMS
  static Future<OtpSendResult> sendOTP(String phoneNumber) async {
    Future<OtpSendResult> _attempt() async {
      try {
        // Format phone number with country code
        final formattedPhone = phoneNumber.startsWith('+')
            ? phoneNumber
            : '+91$phoneNumber';

        await _client.auth.signInWithOtp(
          phone: formattedPhone,
          channel: OtpChannel.sms,
          shouldCreateUser: true,
        );

        return OtpSendResult(success: true, message: 'OTP sent to $formattedPhone');
      } on AuthException catch (e) {
        debugPrint('AuthException sending OTP: ${e.message}');
        return OtpSendResult(success: false, message: e.message);
      } catch (e) {
        debugPrint('Error sending OTP: $e');
        return const OtpSendResult(success: false, message: 'Failed to send OTP.');
      }
    }

    // First attempt
    final first = await _attempt();
    // If on web and first failure looks like a transient fetch/CORS warm-up, retry once after a short delay.
    if (!first.success && kIsWeb && (first.message?.toLowerCase().contains('failed to fetch') ?? false)) {
      await Future.delayed(const Duration(milliseconds: 400));
      final second = await _attempt();
      if (!second.success && (second.message == null || second.message!.isEmpty)) {
        return const OtpSendResult(success: false, message: 'Network issue. Please try again.');
      }
      return second;
    }
    return first;
  }

  // Verify OTP
  static Future<AuthResponse?> verifyOTP(String phoneNumber, String otp) async {
    try {
      // Format phone number with country code
      final formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+91$phoneNumber';

      final response = await _client.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      return response;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return null;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return _client.auth.currentUser != null;
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  // Validate Indian mobile number
  static bool isValidMobile(String mobile) {
    if (mobile.length != 10) return false;
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) return false;
    return true;
  }

  // Sign out and clear session (with safe error handling)
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error during signOut: $e');
    }
  }
}
