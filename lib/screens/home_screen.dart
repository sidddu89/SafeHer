import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF8A80),
                ),
                padding: const EdgeInsets.all(36),
                child: Text('HELP', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(Icons.contacts, color: Color(0xFFFF8A80)),
                  title: Text('Emergency Contacts'),
                  onTap: () => Navigator.pushNamed(context, '/contacts'),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(Icons.settings, color: Color(0xFFFF8A80)),
                  title: Text('Settings'),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 