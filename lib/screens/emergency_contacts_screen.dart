import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, String>> contacts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user!.getIdToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          contacts = List<Map<String, String>>.from(
            (data['emergencyContacts'] as List).map((c) => {
              'name': c['name'] ?? '',
              'phone': c['phone'] ?? '',
            }),
          );
        });
      }
    } catch (e) {
      // Handle error
    }
    setState(() => _loading = false);
  }

  Future<void> _syncContacts() async {
    if (contacts.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must have exactly 5 contacts to save.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not authenticated. Please log in again.')),
        );
        setState(() => _loading = false);
        return;
      }
      final idToken = await user.getIdToken();
      final name = user.displayName ?? '';
      final phone = user.phoneNumber ?? '';
      if (name.isEmpty || phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User name or phone number missing. Please complete your profile.')),
        );
        setState(() => _loading = false);
        return;
      }
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'emergencyContacts': contacts,
        }),
      );
      if (response.statusCode != 200) {
        final msg = jsonDecode(response.body)['message'] ?? 'Failed to save contacts.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing contacts: ' + e.toString())),
      );
    }
    setState(() => _loading = false);
  }

  void _addContact() {
    if (contacts.length >= 5 || _loading) return;
    setState(() {
      contacts.add({'name': '', 'phone': ''});
    });
    if (contacts.length == 5) _syncContacts();
  }

  void _removeContact(int index) {
    if (_loading) return;
    setState(() {
      contacts.removeAt(index);
    });
    if (contacts.length == 5) _syncContacts();
  }

  void _updateContact(int index, String key, String value) {
    if (_loading) return;
    setState(() {
      contacts[index][key] = value;
    });
    if (contacts.length == 5) _syncContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Color(0xFFFF8A80),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...contacts.asMap().entries.map((entry) {
                    int i = entry.key;
                    var contact = entry.value;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: TextField(
                          decoration: InputDecoration(labelText: 'Name'),
                          controller: TextEditingController(text: contact['name'])
                            ..selection = TextSelection.collapsed(offset: contact['name']?.length ?? 0),
                          onChanged: (val) => _updateContact(i, 'name', val),
                          enabled: !_loading,
                        ),
                        subtitle: TextField(
                          decoration: InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
                          controller: TextEditingController(text: contact['phone'])
                            ..selection = TextSelection.collapsed(offset: contact['phone']?.length ?? 0),
                          onChanged: (val) => _updateContact(i, 'phone', val),
                          enabled: !_loading,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Color(0xFFFF8A80)),
                          onPressed: _loading ? null : () => _removeContact(i),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.add, color: Color(0xFFFF8A80)),
                      label: Text('Add Contact', style: TextStyle(color: Color(0xFFFF8A80))),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFFFF8A80)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: contacts.length >= 5 || _loading ? null : _addContact,
                    ),
                  ),
                  if (contacts.length < 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Please add ${5 - contacts.length} more contact(s).',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
} 