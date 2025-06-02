import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safenest/config/theme.dart';
import 'package:safenest/models/emergency_contact.dart';
import 'package:safenest/services/auth_service.dart';
import 'package:safenest/widgets/custom_button.dart';
import 'package:safenest/widgets/custom_text_field.dart';

class SafeCircleScreen extends ConsumerStatefulWidget {
  const SafeCircleScreen({super.key});

  @override
  ConsumerState<SafeCircleScreen> createState() => _SafeCircleScreenState();
}

class _SafeCircleScreenState extends ConsumerState<SafeCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      if (user != null) {
        setState(() {
          _contacts = user.emergencyContacts
              .map((phone) => EmergencyContact(
                    name: 'Contact', // TODO: Get name from contacts
                    phone: phone,
                    relationship: 'Emergency Contact',
                  ))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: ${e.toString()}')),
      );
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Trusted Contact'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Name',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _relationshipController,
                label: 'Relationship',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter relationship';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            onPressed: _addContact,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addContact() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final contact = EmergencyContact(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
      );

      final user = await ref.read(authServiceProvider).getCurrentUser();
      if (user != null) {
        final updatedUser = user.copyWith(
          emergencyContacts: [...user.emergencyContacts, contact.phone],
        );
        await ref.read(authServiceProvider).updateProfile(updatedUser);

        setState(() {
          _contacts.add(contact);
        });

        if (!mounted) return;
        Navigator.pop(context);
        _nameController.clear();
        _phoneController.clear();
        _relationshipController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact added successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding contact: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeContact(EmergencyContact contact) async {
    try {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      if (user != null) {
        final updatedUser = user.copyWith(
          emergencyContacts: user.emergencyContacts
              .where((phone) => phone != contact.phone)
              .toList(),
        );
        await ref.read(authServiceProvider).updateProfile(updatedUser);

        setState(() {
          _contacts.removeWhere((c) => c.phone == contact.phone);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact removed successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing contact: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Circle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _contacts.isEmpty
                      ? const Center(
                          child: Text(
                            'No trusted contacts added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    contact.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                title: Text(contact.name),
                                subtitle: Text(
                                  '${contact.phone}\n${contact.relationship}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeContact(contact),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    onPressed: _showAddContactDialog,
                    child: const Text('Add Trusted Contact'),
                  ),
                ),
              ],
            ),
    );
  }
} 