import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool gestureAlert = false;
  double gestureSensitivity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFFFF8A80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gesture Alert Toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: Text('Enable Gesture Alert'),
                subtitle: Text('Toggle gesture detection on/off'),
                value: gestureAlert,
                onChanged: (val) => setState(() => gestureAlert = val),
              ),
            ),
            const SizedBox(height: 24),

            // Gesture Sensitivity Slider
            if (gestureAlert) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gesture Sensitivity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: gestureSensitivity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        activeColor: Color(0xFFFF8A80),
                        onChanged: (value) {
                          setState(() {
                            gestureSensitivity = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Low', style: TextStyle(color: Colors.grey[600])),
                          Text('High', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Change Gesture Mode
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(Icons.gesture, color: Color(0xFFFF8A80)),
                title: Text('Change Gesture Mode'),
                subtitle: Text('Configure gesture patterns'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gesture configuration coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Test Panic Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Panic button test triggered!'),
                      backgroundColor: Color(0xFFFF8A80),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF8A80),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Test Panic Button'),
              ),
            ),

            Spacer(),

            // Logout Button
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logging out...'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
