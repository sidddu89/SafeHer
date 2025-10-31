import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase project credentials
  static const String supabaseUrl = 'https://znslqjmezcxwauejmjwu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpuc2xxam1lemN4d2F1ZWptand1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNzg0MzIsImV4cCI6MjA3NTY1NDQzMn0.sFzj8QU94xjluAG3eMzimMM-LnxT1QoPjxWvXRFfgjw';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}
