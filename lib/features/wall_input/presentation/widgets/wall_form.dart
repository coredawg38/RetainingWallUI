/// Wall Parameters Form
///
/// Form widget for entering retaining wall design parameters.
/// Includes height slider, material dropdown, and other configuration options.
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

  /// Callback for toe changes.
  final ValueChanged<int>? onToeChanged;

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
    this.onToeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Wall Dimensions',
          subtitle: 'Set the height and toe length',
        ),
        const SizedBox(height: 8),
        _HeightSlider(
          value: input.height,
          onChanged: enabled ? onHeightChanged : null,
        ),
        const SizedBox(height: 16),
        _ToeInput(
          value: input.toe,
          onChanged: enabled ? onToeChanged : null,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Material & Construction',
          subtitle: 'Choose wall material and options',
        ),
        const SizedBox(height: 8),
        _MaterialDropdown(
          value: input.material,
          onChanged: enabled ? onMaterialChanged : null,
        ),
        const SizedBox(height: 16),
        _SlabSwitch(
          value: input.hasSlab,
          onChanged: enabled ? onHasSlabChanged : null,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Site Conditions',
          subtitle: 'Specify terrain and soil characteristics',
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Design Optimization',
          subtitle: 'Choose what to optimize for',
        ),
        const SizedBox(height: 8),
        _OptimizationDropdown(
          value: input.optimizationParameter,
          onChanged: enabled ? onOptimizationChanged : null,
        ),
      ],
    );
  }
}

/// Height slider with value display.
class _HeightSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;

  const _HeightSlider({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final heightFeet = value / 12;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wall Height',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(0)}" (${heightFeet.toStringAsFixed(1)} ft)',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: WallConstraints.minHeight,
              max: WallConstraints.maxHeight,
              divisions: ((WallConstraints.maxHeight - WallConstraints.minHeight) ~/ 6),
              label: '${value.toStringAsFixed(0)}"',
              onChanged: onChanged,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${WallConstraints.minHeight.toInt()}" (2 ft)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '${WallConstraints.maxHeight.toInt()}" (12 ft)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toe length input field.
class _ToeInput extends StatefulWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _ToeInput({
    required this.value,
    this.onChanged,
  });

  @override
  State<_ToeInput> createState() => _ToeInputState();
}

class _ToeInputState extends State<_ToeInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_ToeInput oldWidget) {
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
      label: 'Toe Length (inches)',
      controller: _controller,
      keyboardType: TextInputType.number,
      helperText: '${WallConstraints.minToe}-${WallConstraints.maxToe} inches',
      prefixIcon: Icons.straighten,
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
