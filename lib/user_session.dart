// lib/user_session.dart
import 'services/supabase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? userName;
  static String? phoneNumber;

  /// Prefer Supabase Auth UID if signed in; else derive a stable id from userName.
  static String get userId {
    final user = SupabaseAuthService.getCurrentUser();
    final uid = user?.id;
    if (uid != null && uid.isNotEmpty) return uid;

    // Fallback: derived id from name (lowercase, underscores). Avoid spaces/specials.
    final name = (userName ?? '').trim().toLowerCase();
    if (name.isNotEmpty) {
      final derived = name.replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-z0-9_]+'), '');
      if (derived.isNotEmpty) return 'name_$derived';
    }

    // Last resort: phone (shouldn’t happen if your flow sets name)
    final phone = (phoneNumber ?? '').trim();
    if (phone.isNotEmpty) return 'phone_$phone';

    return ''; // not ready
  }

  static bool get isReady => userId.isNotEmpty;
  
  /// Sign out from Supabase and clear persistent login
  static Future<void> signOut() async {
    await SupabaseAuthService.signOut();
    userName = null;
    phoneNumber = null;
    
    // Clear persistent login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_phone');
    await prefs.remove('logged_in_name');
    await prefs.setBool('is_logged_in', false);
  }

  /// Restore login state from persistent storage
  static Future<bool> restoreLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (isLoggedIn) {
        final phone = prefs.getString('logged_in_phone');
        final name = prefs.getString('logged_in_name');
        
        if (phone != null && name != null) {
          phoneNumber = phone;
          userName = name;
          return true;
        }
      }
    } catch (e) {
      // If there's any error, just return false
    }
    return false;
  }
}
