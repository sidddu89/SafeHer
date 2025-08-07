import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/otp_verification_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/registration_screen.dart';
import 'firebase_options.dart';

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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing app: \${snapshot.error}'),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          // User not logged in
          return buildMaterialApp(initialRoute: '/register');
        }

        // User is logged in, check emergency contacts
        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('emergency_contacts')
              .doc(user.uid)
              .get(),
          builder: (context, contactSnap) {
            if (contactSnap.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (contactSnap.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Error loading contacts: \${contactSnap.error}'),
                  ),
                ),
              );
            }
            final contacts = contactSnap.data?.data() as Map<String, dynamic>?;
            final hasContacts = contacts != null &&
                (contacts['contacts'] as List?)?.length == 5;

            return buildMaterialApp(
              initialRoute: hasContacts ? '/home' : '/contacts',
            );
          },
        );
      },
    );
  }

  MaterialApp buildMaterialApp({required String initialRoute}) {
    return MaterialApp(
      title: 'SafeHer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/contacts': (context) => EmergencyContactsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final args = settings.arguments as Map<String, String>?;
          if (args != null &&
              args['name'] != null &&
              args['phone'] != null &&
              args['verificationId'] != null) {
            return MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                name: args['name']!,
                phone: args['phone']!,
                verificationId: args['verificationId']!,
              ),
            );
          }
          // If arguments are missing, show an error and option to restart
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Missing registration info. Please restart onboarding.',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/register',
                          (route) => false,
                        );
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
