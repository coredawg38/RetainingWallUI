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
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= 520;
        const gap = 10.0;

        Widget pair(Widget a, Widget b) {
          if (!twoCol) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                a,
                const SizedBox(height: gap),
                b,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: gap),
              Expanded(child: b),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pair(
              _HeightInput(
                value: input.height,
                onChanged: enabled ? onHeightChanged : null,
              ),
              _MaterialDropdown(
                value: input.material,
                onChanged: enabled ? onMaterialChanged : null,
              ),
            ),
            const SizedBox(height: gap),
            _SlabSwitch(
              value: input.hasSlab,
              onChanged: enabled ? onHasSlabChanged : null,
            ),
            const SizedBox(height: gap),
            pair(
              _SurchargeDropdown(
                value: input.surcharge,
                onChanged: enabled ? onSurchargeChanged : null,
              ),
              _SoilStiffnessDropdown(
                value: input.soilStiffness,
                onChanged: enabled ? onSoilStiffnessChanged : null,
              ),
            ),
            const SizedBox(height: gap),
            pair(
              _ToppingInput(
                value: input.topping,
                onChanged: enabled ? onToppingChanged : null,
              ),
              _OptimizationDropdown(
                value: input.optimizationParameter,
                onChanged: enabled ? onOptimizationChanged : null,
              ),
            ),
          ],
        );
      },
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
      label: 'Height (${WallConstraints.minHeight.toInt()}-${WallConstraints.maxHeight.toInt()}") in)',
      controller: _controller,
      keyboardType: TextInputType.number,
      dense: true,
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
      label: 'Material',
      value: value,
      dense: true,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.layers, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Has slab at top of wall',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
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
      dense: true,
      onChanged: onChanged != null
          ? (newValue) {
              if (newValue != null) onChanged!(newValue);
            }
          : null,
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
      dense: true,
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
      label: 'Topsoil (${WallConstraints.minTopping}-${WallConstraints.maxTopping} in)',
      controller: _controller,
      keyboardType: TextInputType.number,
      dense: true,
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
      dense: true,
      onChanged: onChanged != null
          ? (newValue) {
              if (newValue != null) onChanged!(newValue);
            }
          : null,
      items: OptimizationType.labels.entries
          .map((entry) => DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
    );
  }
}
