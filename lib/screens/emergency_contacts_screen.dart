import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  EmergencyContactsScreenState createState() => EmergencyContactsScreenState();
}

class EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
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
    }
    setState(() => _loading = false);
  }

  Future<void> _saveContacts() async {
    if (contacts.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must have exactly 5 contacts to save.')),
      );
      return;
    }
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

  void _addContact() {
    if (contacts.length >= 5 || _loading) return;
    setState(() {
      contacts.add({'name': '', 'phone': ''});
    });
  }

  void _removeContact(int index) {
    if (_loading) return;
    setState(() {
      contacts.removeAt(index);
    });
  }

  void _updateContact(int index, String key, String value) {
    if (_loading) return;
    setState(() {
      contacts[index][key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Color(0xFF4F8DFF),
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
                          onChanged: (val) => _updateContact(i, 'name', val),
                          enabled: !_loading,
                        ),
                        subtitle: TextField(
                          decoration: InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
                          controller:
                              TextEditingController(text: contact['phone'])
                                ..selection = TextSelection.collapsed(
                                  offset: contact['phone']?.length ?? 0,
                                ),
                          onChanged: (val) => _updateContact(i, 'phone', val),
                          enabled: !_loading,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Color(0xFF4F8DFF)),
                          onPressed: _loading ? null : () => _removeContact(i),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
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
