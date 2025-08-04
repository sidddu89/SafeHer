import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top row with settings and emergency contacts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Settings button at top left
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
<<<<<<< HEAD
                    icon: Icon(
                      Icons.settings,
                      color: Color(0xFFFF8A80),
                      size: 28,
                    ),
=======
                    icon: Icon(Icons.settings, color: Color(0xFFFF8A80), size: 28),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  // Emergency contacts at top right
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/contacts'),
<<<<<<< HEAD
                    icon: Icon(
                      Icons.contacts,
                      color: Color(0xFFFF8A80),
                      size: 28,
                    ),
=======
                    icon: Icon(Icons.contacts, color: Color(0xFFFF8A80), size: 28),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
<<<<<<< HEAD

=======
              
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
              // Live location container
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
<<<<<<< HEAD
                    Icon(Icons.location_on, size: 48, color: Color(0xFFFF8A80)),
=======
                    Icon(
                      Icons.location_on,
                      size: 48,
                      color: Color(0xFFFF8A80),
                    ),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                    const SizedBox(height: 12),
                    Text(
                      'Live Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Location tracking active',
<<<<<<< HEAD
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
=======
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
<<<<<<< HEAD

=======
              
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
              // Panic button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF8A80),
                  boxShadow: [
                    BoxShadow(
<<<<<<< HEAD
                      color: Color(0xFFFF8A80).withValues(alpha: 0.3),
=======
                      color: Color(0xFFFF8A80).withOpacity(0.3),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(36),
                child: Text(
                  'HELP',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
