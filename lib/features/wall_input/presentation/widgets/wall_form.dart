/// Wall Parameters Form
///
/// Form widget for entering retaining wall design parameters.
/// Includes height, material, and other configuration options.
///
/// Usage:
/// ```dart
/// WallForm(
///   input: currentInput,
///   onChanged: (updated) => notifier.updateInput(updated),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../data/models/retaining_wall_input.dart';

/// Form for entering wall parameters.
class WallForm extends StatelessWidget {
  /// Current input values.
  final RetainingWallInput input;

  /// Callback for height changes.
  final ValueChanged<double>? onHeightChanged;

  /// Callback for material changes.
  final ValueChanged<int>? onMaterialChanged;

  /// Callback for surcharge changes.
  final ValueChanged<int>? onSurchargeChanged;

  /// Callback for optimization parameter changes.
  final ValueChanged<int>? onOptimizationChanged;

  /// Callback for soil stiffness changes.
  final ValueChanged<int>? onSoilStiffnessChanged;

  /// Callback for topping changes.
  final ValueChanged<int>? onToppingChanged;

  /// Callback for has slab changes.
  final ValueChanged<bool>? onHasSlabChanged;

  /// Whether the form is enabled.
  final bool enabled;

  const WallForm({
    super.key,
    required this.input,
    this.onHeightChanged,
    this.onMaterialChanged,
    this.onSurchargeChanged,
    this.onOptimizationChanged,
    this.onSoilStiffnessChanged,
    this.onToppingChanged,
    this.onHasSlabChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeightInput(
          value: input.height,
          onChanged: enabled ? onHeightChanged : null,
        ),
        const SizedBox(height: 16),
        _MaterialDropdown(
          value: input.material,
          onChanged: enabled ? onMaterialChanged : null,
        ),
        const SizedBox(height: 16),
        _SlabSwitch(
          value: input.hasSlab,
          onChanged: enabled ? onHasSlabChanged : null,
        ),
        const SizedBox(height: 16),
        _SurchargeDropdown(
          value: input.surcharge,
          onChanged: enabled ? onSurchargeChanged : null,
        ),
        const SizedBox(height: 16),
        _SoilStiffnessDropdown(
          value: input.soilStiffness,
          onChanged: enabled ? onSoilStiffnessChanged : null,
        ),
        const SizedBox(height: 16),
        _ToppingInput(
          value: input.topping,
          onChanged: enabled ? onToppingChanged : null,
        ),
        const SizedBox(height: 16),
        _OptimizationDropdown(
          value: input.optimizationParameter,
          onChanged: enabled ? onOptimizationChanged : null,
        ),
      ],
    );
  }
}

/// Wall height input field.
class _HeightInput extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;

  const _HeightInput({
    required this.value,
    this.onChanged,
  });

  @override
  State<_HeightInput> createState() => _HeightInputState();
}

class _HeightInputState extends State<_HeightInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(_HeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final newText = widget.value.toStringAsFixed(0);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: 'Wall Height (inches)',
      controller: _controller,
      keyboardType: TextInputType.number,
      helperText:
          '${WallConstraints.minHeight.toInt()}-${WallConstraints.maxHeight.toInt()} inches',
      prefixIcon: Icons.height,
      onChanged: (value) {
        final doubleValue = double.tryParse(value);
        if (doubleValue != null && widget.onChanged != null) {
          widget.onChanged!(doubleValue);
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

/// Material type dropdown.
class _MaterialDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _MaterialDropdown({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledDropdown<int>(
      label: 'Wall Material',
      value: value,
      onChanged: onChanged != null
          ? (newValue) {
              if (newValue != null) onChanged!(newValue);
            }
          : null,
      items: WallMaterialType.labels.entries
          .map((entry) => DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
    );
  }
}

/// Has slab switch.
class _SlabSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SlabSwitch({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: const Text('Has Slab'),
        subtitle: const Text('Include a slab at the top of the wall'),
        value: value,
        onChanged: onChanged,
        secondary: const Icon(Icons.layers),
      ),
    );
  }
}

/// Surcharge type dropdown.
class _SurchargeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _SurchargeDropdown({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledDropdown<int>(
      label: 'Surcharge / Slope',
      value: value,
      onChanged: onChanged != null
          ? (newValue) {
              if (newValue != null) onChanged!(newValue);
            }
          : null,
      helperText: 'Slope condition above the wall',
      items: SurchargeType.labels.entries
          .map((entry) => DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
    );
  }
}

/// Soil stiffness dropdown.
class _SoilStiffnessDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _SoilStiffnessDropdown({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledDropdown<int>(
      label: 'Soil Stiffness',
      value: value,
      onChanged: onChanged != null
          ? (newValue) {
              if (newValue != null) onChanged!(newValue);
            }
          : null,
      items: SoilStiffnessType.labels.entries
          .map((entry) => DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
    );
  }
}

/// Topping thickness input.
class _ToppingInput extends StatefulWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _ToppingInput({
    required this.value,
    this.onChanged,
  });

  @override
  State<_ToppingInput> createState() => _ToppingInputState();
}

class _ToppingInputState extends State<_ToppingInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_ToppingInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final newText = widget.value.toString();
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: 'Topsoil Thickness (inches)',
      controller: _controller,
      keyboardType: TextInputType.number,
      helperText: '${WallConstraints.minTopping}-${WallConstraints.maxTopping} inches',
      prefixIcon: Icons.grass,
      onChanged: (value) {
        final intValue = int.tryParse(value);
        if (intValue != null && widget.onChanged != null) {
          widget.onChanged!(intValue);
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

/// Optimization parameter dropdown.
class _OptimizationDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _OptimizationDropdown({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledDropdown<int>(
      label: 'Optimize For',
      value: value,
      onChanged: onChanged != null
          ? (newValue) {
              if (newValue != null) onChanged!(newValue);
            }
          : null,
      helperText: 'What should the design optimize?',
      items: OptimizationType.labels.entries
          .map((entry) => DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
    );
  }
}
