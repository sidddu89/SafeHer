import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'manage_contacts_screen.dart';
import 'user_session.dart';
import 'supabase_config.dart';

class SafeHerWelcomeScreen extends StatefulWidget {
  const SafeHerWelcomeScreen({Key? key}) : super(key: key);

  @override
  State<SafeHerWelcomeScreen> createState() => _SafeHerWelcomeScreenState();
}

class _SafeHerWelcomeScreenState extends State<SafeHerWelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    // Wait a moment to show the welcome screen (so user always sees it first)
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;

    // First check Supabase session
    final session = SupabaseConfig.client.auth.currentSession;
    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManageContactsScreen()),
      );
      return;
    }

    // Then check persistent login state
    final hasPersistedLogin = await UserSession.restoreLoginState();
    if (hasPersistedLogin && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManageContactsScreen()),
      );
    }
    // If not logged in, stay on welcome screen - user can tap login button
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Method 3: SafeArea for Notches/Status Bars
      body: SafeArea(
        // Method 1: Use SingleChildScrollView
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            // Method 4: MediaQuery for Responsive Sizing
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              // Method 4: Use percentages instead of fixed pixels
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Method 4: MediaQuery for responsive sizing - Image Section
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                    constraints: const BoxConstraints(
                      maxHeight: 250,
                      minHeight: 150,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuDadeICSc2Z9t9Ms6m8YZJ_wS92KzdHGnU3yruj0xltWpfTZxxKDHJf-Ny3WeLfuxjWEVvvsTFq1MXuzPxmJb9RbWbsjx4P5G4UnvqBnO-Au-Y4iOQs1GuuSPfBDMynbDlqdcFeUBWmDDJrm8OKduhb1tFybb_hZDjbx3Tho-RgflTTBgMbHQmNqEP9YpHFA9KLskIjw4eQr0W8nRntLSjaJT5fdSc1MpCPcTpVMHUNLaODGyJlt_wvyRIpORB-cwxrgORGplcem48"
                        ),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Method 4: MediaQuery for responsive font sizing - Title
                  Text(
                    'Welcome to SafeHer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF111317),
                      fontSize: MediaQuery.of(context).size.width * 0.07, // 7% of screen width
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Method 4: MediaQuery for responsive font sizing - Subtitle
                  Text(
                    'Your personal safety companion, always by your side.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF111317),
                      fontSize: MediaQuery.of(context).size.width * 0.04, // 4% of screen width
                      fontWeight: FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Method 2: Use Flexible Layouts - Buttons Section
                  Column(
                    children: [
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );  
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F68E4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.015,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle login
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0F1F4),
                            foregroundColor: const Color(0xFF111317),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.015,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Method 4: Dynamic bottom spacing to handle keyboard and prevent overflow
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
