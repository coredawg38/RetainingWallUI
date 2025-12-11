/// Customer Information Form
///
/// Form component for entering customer contact details.
/// Delivery is via download and email only - no mailing address needed.
///
/// Usage:
/// ```dart
/// CustomerForm(
///   customerInfo: currentCustomer,
///   onNameChanged: (name) => notifier.updateCustomerName(name),
///   onEmailChanged: (email) => notifier.updateCustomerEmail(email),
///   onPhoneChanged: (phone) => notifier.updateCustomerPhone(phone),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/common_widgets.dart';
import '../../data/models/retaining_wall_input.dart';

/// Form for entering customer contact information.
class CustomerForm extends StatefulWidget {
  /// Current customer info values.
  final CustomerInfo customerInfo;

  /// Site address (kept for backwards compatibility but not used for mailing).
  final Address siteAddress;

  /// Callback when name changes.
  final ValueChanged<String>? onNameChanged;

  /// Callback when email changes.
  final ValueChanged<String>? onEmailChanged;

  /// Callback when phone changes.
  final ValueChanged<String>? onPhoneChanged;

  /// Whether the form is enabled.
  final bool enabled;

  const CustomerForm({
    super.key,
    required this.customerInfo,
    required this.siteAddress,
    this.onNameChanged,
    this.onEmailChanged,
    this.onPhoneChanged,
    this.enabled = true,
    // Legacy parameters - kept for backwards compatibility
    ValueChanged<String>? onMailingStreetChanged,
    ValueChanged<String>? onMailingCityChanged,
    ValueChanged<String>? onMailingStateChanged,
    ValueChanged<int>? onMailingZipCodeChanged,
    VoidCallback? onCopySiteAddress,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customerInfo.name);
    _emailController = TextEditingController(text: widget.customerInfo.email);
    _phoneController = TextEditingController(text: widget.customerInfo.phone);
  }

  @override
  void didUpdateWidget(CustomerForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerInfo != widget.customerInfo) {
      if (_nameController.text != widget.customerInfo.name) {
        _nameController.text = widget.customerInfo.name;
      }
      if (_emailController.text != widget.customerInfo.email) {
        _emailController.text = widget.customerInfo.email;
      }
      if (_phoneController.text != widget.customerInfo.phone) {
        _phoneController.text = widget.customerInfo.phone;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Contact Information',
          subtitle: 'Your contact details for document delivery',
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Full Name',
          controller: _nameController,
          hint: 'John Doe',
          required: true,
          enabled: widget.enabled,
          prefixIcon: Icons.person,
          onChanged: widget.onNameChanged,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Email Address',
          controller: _emailController,
          hint: 'john@example.com',
          required: true,
          enabled: widget.enabled,
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          helperText: 'Documents will be sent to this email',
          onChanged: widget.onEmailChanged,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Phone Number',
          controller: _phoneController,
          hint: '(555) 123-4567',
          required: true,
          enabled: widget.enabled,
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            _PhoneInputFormatter(),
          ],
          onChanged: widget.onPhoneChanged,
        ),
        const SizedBox(height: 24),
        // Delivery info card
        Card(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Delivery',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your engineering documents will be available for immediate download and sent to your email.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Phone number input formatter.
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Format as (XXX) XXX-XXXX
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 10; i++) {
      if (i == 0) formatted += '(';
      if (i == 3) formatted += ') ';
      if (i == 6) formatted += '-';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Compact customer info display for review purposes.
class CustomerInfoDisplay extends StatelessWidget {
  /// The customer info to display.
  final CustomerInfo customerInfo;

  const CustomerInfoDisplay({
    super.key,
    required this.customerInfo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  customerInfo.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.email,
              value: customerInfo.email,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.phone,
              value: customerInfo.phone,
            ),
          ],
        ),
      ),
    );
  }
}

/// Info row with icon and value.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
