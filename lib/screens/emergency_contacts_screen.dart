import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
=======
import 'package:http/http.dart' as http;
import 'dart:convert';
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
<<<<<<< HEAD
  EmergencyContactsScreenState createState() => EmergencyContactsScreenState();
}

class EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
=======
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
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
<<<<<<< HEAD
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('emergency_contacts')
            .doc(user.uid)
            .get();
        final data = doc.data();
        if (data != null &&
            data['contacts'] != null &&
            (data['contacts'] as List).length == 5) {
          setState(() {
            contacts = List<Map<String, String>>.from(
              data['contacts'].map((c) => Map<String, String>.from(c)),
            );
            _loading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts. Please restart the app.'),
          ),
        );
      }
=======
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
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
    }
    setState(() => _loading = false);
  }

<<<<<<< HEAD
  Future<void> _saveContacts() async {
=======
  Future<void> _syncContacts() async {
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
    if (contacts.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must have exactly 5 contacts to save.')),
      );
      return;
    }
<<<<<<< HEAD
    setState(() {
      _loading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not logged in.')));
      setState(() {
        _loading = false;
      });
      return;
    }
    await FirebaseFirestore.instance
        .collection('emergency_contacts')
        .doc(user.uid)
        .set({'contacts': contacts});
    setState(() {
      _loading = false;
    });
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Remove all duplicate top-level code blocks below this line. Only keep methods inside the class.

=======
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
        SnackBar(content: Text('Error syncing contacts: $e')),
      );
    }
    setState(() => _loading = false);
  }

>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
  void _addContact() {
    if (contacts.length >= 5 || _loading) return;
    setState(() {
      contacts.add({'name': '', 'phone': ''});
    });
<<<<<<< HEAD
=======
    if (contacts.length == 5) _syncContacts();
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
  }

  void _removeContact(int index) {
    if (_loading) return;
    setState(() {
      contacts.removeAt(index);
    });
<<<<<<< HEAD
=======
    if (contacts.length == 5) _syncContacts();
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
  }

  void _updateContact(int index, String key, String value) {
    if (_loading) return;
    setState(() {
      contacts[index][key] = value;
    });
<<<<<<< HEAD
=======
    if (contacts.length == 5) _syncContacts();
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
<<<<<<< HEAD
        backgroundColor: Color(0xFF4F8DFF),
=======
        backgroundColor: Color(0xFFFF8A80),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
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
<<<<<<< HEAD
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: TextField(
                          decoration: InputDecoration(labelText: 'Name'),
                          controller:
                              TextEditingController(text: contact['name'])
                                ..selection = TextSelection.collapsed(
                                  offset: contact['name']?.length ?? 0,
                                ),
=======
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: TextField(
                          decoration: InputDecoration(labelText: 'Name'),
                          controller: TextEditingController(text: contact['name'])
                            ..selection = TextSelection.collapsed(offset: contact['name']?.length ?? 0),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                          onChanged: (val) => _updateContact(i, 'name', val),
                          enabled: !_loading,
                        ),
                        subtitle: TextField(
                          decoration: InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
<<<<<<< HEAD
                          controller:
                              TextEditingController(text: contact['phone'])
                                ..selection = TextSelection.collapsed(
                                  offset: contact['phone']?.length ?? 0,
                                ),
=======
                          controller: TextEditingController(text: contact['phone'])
                            ..selection = TextSelection.collapsed(offset: contact['phone']?.length ?? 0),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                          onChanged: (val) => _updateContact(i, 'phone', val),
                          enabled: !_loading,
                        ),
                        trailing: IconButton(
<<<<<<< HEAD
                          icon: Icon(Icons.delete, color: Color(0xFF4F8DFF)),
=======
                          icon: Icon(Icons.delete, color: Color(0xFFFF8A80)),
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
                          onPressed: _loading ? null : () => _removeContact(i),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
<<<<<<< HEAD
                      icon: Icon(Icons.add, color: Color(0xFF4F8DFF)),
                      label: Text(
                        'Add Contact',
                        style: TextStyle(color: Color(0xFF4F8DFF)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF4F8DFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: contacts.length >= 5 || _loading
                          ? null
                          : _addContact,
                    ),
                  ),
                  if (contacts.length == 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _saveContacts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4F8DFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Save Contacts'),
                        ),
                      ),
                    ),
=======
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
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
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
<<<<<<< HEAD
}
=======
} 
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
