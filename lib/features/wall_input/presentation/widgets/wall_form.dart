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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../data/models/retaining_wall_input.dart';

/// Placeholder descriptions for the wall parameter fields.
///
/// Replace this copy with the final field explanations.
abstract final class _ParameterHelp {
  static const height =
      'The exposed height of the retaining wall, measured in inches (24–144).';

  static const material = 'The material used to build the wall.';

  static const hasSlab = 'Whether a concrete slab is built at the top of the wall.';

  static const surcharge =
      'The slope or extra load on the ground above the wall.';

  static const soilStiffness = 'How stiff the soil is at the site.';

  static const topping =
      'The depth of topsoil placed above the wall, in inches.';

  static const optimization = 'Which part of the design the wall should minimize.';
}

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
    const gap = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeightInput(
          value: input.height,
          onChanged: enabled ? onHeightChanged : null,
        ),
        const SizedBox(height: gap),
        _MaterialDropdown(
          value: input.material,
          onChanged: enabled ? onMaterialChanged : null,
        ),
        const SizedBox(height: gap),
        _SlabSwitch(
          value: input.hasSlab,
          onChanged: enabled ? onHasSlabChanged : null,
        ),
        const SizedBox(height: gap),
        _SurchargeDropdown(
          value: input.surcharge,
          onChanged: enabled ? onSurchargeChanged : null,
        ),
        const SizedBox(height: gap),
        _SoilStiffnessDropdown(
          value: input.soilStiffness,
          onChanged: enabled ? onSoilStiffnessChanged : null,
        ),
        const SizedBox(height: gap),
        _ToppingInput(
          value: input.topping,
          onChanged: enabled ? onToppingChanged : null,
        ),
        const SizedBox(height: gap),
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
  late FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _popupController = OverlayPortalController();
  Timer? _popupTimer;

  static String get _boundsMessage =>
      'Height must be between ${WallConstraints.minHeight.toInt()} and ${WallConstraints.maxHeight.toInt()} inches.';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(0));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_HeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      final newText = widget.value.toStringAsFixed(0);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _clampAndCommit();
    }
  }

  double _clampHeight(double value) {
    return value.clamp(WallConstraints.minHeight, WallConstraints.maxHeight);
  }

  void _showBoundsPopup() {
    _popupTimer?.cancel();
    _popupController.show();
    _popupTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _popupController.hide();
      }
    });
  }

  void _clampAndCommit() {
    final parsed = double.tryParse(_controller.text);
    final clamped = _clampHeight(parsed ?? WallConstraints.minHeight);
    final text = clamped.toStringAsFixed(0);
    final wasOutOfRange =
        parsed == null || parsed < WallConstraints.minHeight || parsed > WallConstraints.maxHeight;
    if (_controller.text != text) {
      _controller.text = text;
    }
    if (wasOutOfRange) {
      _showBoundsPopup();
    }
    widget.onChanged?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OverlayPortal(
      controller: _popupController,
      overlayChildBuilder: (context) {
        return UnconstrainedBox(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 6),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.inverseSurface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    _boundsMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onInverseSurface,
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Focus(
          focusNode: _focusNode,
          child: LabeledTextField(
            label: 'Height (${WallConstraints.minHeight.toInt()}-${WallConstraints.maxHeight.toInt()} in)',
            controller: _controller,
            keyboardType: TextInputType.number,
            dense: true,
            infoText: _ParameterHelp.height,
            prefixIcon: Icons.height,
            onChanged: (value) {
              final doubleValue = double.tryParse(value);
              if (doubleValue == null || widget.onChanged == null) return;
              // Only push in-range values while typing; clamp on blur for lows.
              if (doubleValue >= WallConstraints.minHeight &&
                  doubleValue <= WallConstraints.maxHeight) {
                widget.onChanged!(doubleValue);
              }
            },
            onSubmitted: (_) => _clampAndCommit(),
            inputFormatters: [
              _HeightRangeFormatter(onRejected: _showBoundsPopup),
            ],
          ),
        ),
      ),
    );
  }
}

/// Digits-only formatter that rejects values above [WallConstraints.maxHeight].
///
/// Values below the minimum are allowed while typing (e.g. "2" then "4" for 24)
/// and are clamped when the field loses focus.
class _HeightRangeFormatter extends TextInputFormatter {
  const _HeightRangeFormatter({this.onRejected});

  final VoidCallback? onRejected;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (!RegExp(r'^\d+$').hasMatch(newValue.text)) {
      return oldValue;
    }
    final value = int.parse(newValue.text);
    if (value > WallConstraints.maxHeight) {
      onRejected?.call();
      return oldValue;
    }
    return newValue;
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
      infoText: _ParameterHelp.material,
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
          const FieldInfoIcon(description: _ParameterHelp.hasSlab),
          const SizedBox(width: 4),
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
      infoText: _ParameterHelp.surcharge,
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
      infoText: _ParameterHelp.soilStiffness,
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
      infoText: _ParameterHelp.topping,
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
      infoText: _ParameterHelp.optimization,
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
