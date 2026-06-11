import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  bool _isSaving = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final current = userProvider.user;
    _addressController.text = current != null ? (current['business_address'] ?? '') : '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updated = await _authService.updateProfile({'business_address': _addressController.text.trim()});
      // SaveUserData is called in AuthService; refresh provider
      Provider.of<UserProvider>(context, listen: false).refreshUserData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery address saved'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Address')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
