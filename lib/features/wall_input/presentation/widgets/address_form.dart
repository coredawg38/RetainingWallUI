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

/// US State abbreviations for dropdown.
const List<String> _usStates = [
  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
  'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
  'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
  'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
  'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
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
        SectionHeader(
          title: widget.title,
          subtitle: widget.subtitle,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Street Address',
          controller: _streetController,
          hint: '123 Main Street',
          required: widget.required,
          enabled: widget.enabled,
          prefixIcon: Icons.location_on,
          onChanged: widget.onStreetChanged,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: LabeledTextField(
                label: 'City',
                controller: _cityController,
                hint: 'City',
                required: widget.required,
                enabled: widget.enabled,
                onChanged: widget.onCityChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _StateDropdown(
                value: widget.address.state.isNotEmpty
                    ? widget.address.state
                    : null,
                onChanged: widget.enabled ? widget.onStateChanged : null,
                required: widget.required,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 150,
          child: LabeledTextField(
            label: 'ZIP Code',
            controller: _zipController,
            hint: '12345',
            required: widget.required,
            enabled: widget.enabled,
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
        ),
      ],
    );
  }
}

/// State dropdown selector with keyboard filtering support.
class _StateDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool required;

  const _StateDropdown({
    this.value,
    this.onChanged,
    this.required = true,
  });

  @override
  State<_StateDropdown> createState() => _StateDropdownState();
}

class _StateDropdownState extends State<_StateDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final MenuController _menuController = MenuController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value ?? '';
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(_StateDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // Close the dropdown menu when focus is lost
      _menuController.close();

      // Validate the typed text on focus out
      final typedText = _controller.text.toUpperCase().trim();
      if (_usStates.contains(typedText)) {
        if (typedText != widget.value && widget.onChanged != null) {
          widget.onChanged!(typedText);
        }
        _controller.text = typedText;
      } else if (widget.value != null && widget.value!.isNotEmpty) {
        // Revert to valid value if typed text is invalid
        _controller.text = widget.value!;
      } else {
        // Clear invalid input
        _controller.text = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'State',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (widget.required)
              Text(
                ' *',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownMenu<String>(
          controller: _controller,
          focusNode: _focusNode,
          menuController: _menuController,
          initialSelection: widget.value != null && _usStates.contains(widget.value) ? widget.value : null,
          enableFilter: true,
          enableSearch: true,
          requestFocusOnTap: true,
          hintText: 'Select',
          expandedInsets: EdgeInsets.zero,
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          dropdownMenuEntries: _usStates
              .map((state) => DropdownMenuEntry<String>(
                    value: state,
                    label: state,
                  ))
              .toList(),
          onSelected: widget.onChanged != null
              ? (newValue) {
                  if (newValue != null) {
                    widget.onChanged!(newValue);
                  }
                }
              : null,
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
