import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_notifications.dart';
import '../../../services/auth_api.dart';
import 'partnership_theme.dart';

// ============================================================================
// CLIENT REGISTRATION MODAL
// ============================================================================

class ClientRegistrationDialog extends StatefulWidget {
  const ClientRegistrationDialog({super.key});

  @override
  State<ClientRegistrationDialog> createState() => _ClientRegistrationDialogState();
}

class _ClientRegistrationDialogState extends State<ClientRegistrationDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _codeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      showAppMessage('Please fill all required fields.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthApi.instance.addIbClient(
        name: name,
        email: email,
        phone: phone,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
        referralCode: _codeController.text.trim().isNotEmpty ? _codeController.text.trim() : null,
      );
      showAppMessage('Client registered successfully!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      showAppMessage('Failed to register client: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.border),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Register Direct Client',
                    style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field('Full Name *', _nameController, 'e.g. John Doe', colors),
              const SizedBox(height: 10),
              _field('Email Address *', _emailController, 'e.g. john@example.com', colors),
              const SizedBox(height: 10),
              _field('Phone Number *', _phoneController, 'e.g. +91 9876543210', colors),
              const SizedBox(height: 10),
              _field('Country', _countryController, 'e.g. India', colors),
              const SizedBox(height: 10),
              _field('Referral Code', _codeController, 'Optional referral code', colors),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.blue,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _loading ? 'Registering...' : 'Register Client',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, PartnershipColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.subCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.subBorder),
          ),
          child: TextField(
            controller: ctrl,
            style: TextStyle(color: colors.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colors.muted, fontSize: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
