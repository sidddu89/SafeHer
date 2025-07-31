import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/registration_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBuvd8CtR5InN6r01NKqxoqXBmzUIq2v-Q",
        authDomain: "safeher-cb626.firebaseapp.com",
        projectId: "safeher-cb626",
        storageBucket: "safeher-cb626.appspot.com",
        messagingSenderId: "174168027843",
        appId: "1:174168027843:web:1d9dec2a3cea7df4dce876",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeHer',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Color(0xFFFFF8F6),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFF8A80),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF8A80),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFFF8A80), width: 2),
          ),
        ),
      ),
      initialRoute: '/register',
      routes: {
        '/register': (context) => RegistrationScreen(),
        '/otp': (context) => OtpVerificationScreen(),
        '/home': (context) => HomeScreen(),
        '/contacts': (context) => EmergencyContactsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// (Optional) Remove the MyHomePage and _MyHomePageState classes if not used in your app.
