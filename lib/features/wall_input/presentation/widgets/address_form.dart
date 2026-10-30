/// Address Form Widget
///
/// Reusable form component for entering address information.
/// Used for both site address and mailing address.
///
/// Usage:
/// ```dart
/// AddressForm(
///   title: 'Site Address',
///   address: currentAddress,
///   onChanged: (address) => notifier.updateSiteAddress(address),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/common_widgets.dart';
import '../../data/models/retaining_wall_input.dart';

/// Allowed site address state abbreviations for dropdown.
const List<String> _usStates = [
  'AZ', 'CA', 'ID', 'MI', 'MT', 'NV', 'OR', 'TX', 'UT', 'WA',
];

/// Form for entering address information.
class AddressForm extends StatefulWidget {
  /// Title for the address section.
  final String title;

  /// Optional subtitle/description.
  final String? subtitle;

  /// Current address values.
  final Address address;

  /// Callback when street changes.
  final ValueChanged<String>? onStreetChanged;

  /// Callback when city changes.
  final ValueChanged<String>? onCityChanged;

  /// Callback when state changes.
  final ValueChanged<String>? onStateChanged;

  /// Callback when ZIP code changes.
  final ValueChanged<int>? onZipCodeChanged;

  /// Whether the form is enabled.
  final bool enabled;

  /// Whether fields are required.
  final bool required;

  const AddressForm({
    super.key,
    required this.title,
    this.subtitle,
    required this.address,
    this.onStreetChanged,
    this.onCityChanged,
    this.onStateChanged,
    this.onZipCodeChanged,
    this.enabled = true,
    this.required = true,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.address.street);
    _cityController = TextEditingController(text: widget.address.city);
    _zipController = TextEditingController(
      text: widget.address.zipCode > 0 ? widget.address.zipCode.toString() : '',
    );
  }

  @override
  void didUpdateWidget(AddressForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      if (_streetController.text != widget.address.street) {
        _streetController.text = widget.address.street;
      }
      if (_cityController.text != widget.address.city) {
        _cityController.text = widget.address.city;
      }
      final zipText = widget.address.zipCode > 0
          ? widget.address.zipCode.toString()
          : '';
      if (_zipController.text != zipText) {
        _zipController.text = zipText;
      }
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(height: 6),
        LabeledTextField(
          label: 'Street Address',
          controller: _streetController,
          hint: '123 Main Street',
          required: widget.required,
          enabled: widget.enabled,
          dense: true,
          onChanged: widget.onStreetChanged,
        ),
        const SizedBox(height: 6),
        LabeledTextField(
          label: 'City',
          controller: _cityController,
          hint: 'City',
          required: widget.required,
          enabled: widget.enabled,
          dense: true,
          onChanged: widget.onCityChanged,
        ),
        const SizedBox(height: 6),
        LabeledDropdown<String>(
          label: 'State',
          value: widget.address.state.isNotEmpty &&
                  _usStates.contains(widget.address.state)
              ? widget.address.state
              : null,
          required: widget.required,
          enabled: widget.enabled,
          dense: true,
          hint: 'Select',
          onChanged: widget.enabled && widget.onStateChanged != null
              ? (newValue) {
                  if (newValue != null) {
                    widget.onStateChanged!(newValue);
                  }
                }
              : null,
          items: _usStates
              .map((state) => DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        LabeledTextField(
          label: 'ZIP Code',
          controller: _zipController,
          hint: '12345',
          required: widget.required,
          enabled: widget.enabled,
          dense: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(5),
          ],
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null && widget.onZipCodeChanged != null) {
              widget.onZipCodeChanged!(intValue);
            }
          },
        ),
      ],
    );
  }
}

/// Compact address display for review purposes.
class AddressDisplay extends StatelessWidget {
  /// The address to display.
  final Address address;

  /// Optional label/title.
  final String? label;

  const AddressDisplay({
    super.key,
    required this.address,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          address.street,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '${address.city}, ${address.state} ${address.zipCode}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Returns true if the address has all required fields.
  static bool isComplete(Address address) {
    return address.street.isNotEmpty &&
        address.city.isNotEmpty &&
        address.state.isNotEmpty &&
        address.zipCode > 0;
  }
}
