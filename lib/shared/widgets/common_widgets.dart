/// Common Widgets
///
/// Shared UI components used across the application.
/// Includes loading indicators, error displays, and form components.
///
/// Usage:
/// ```dart
/// // Loading indicator
/// LoadingOverlay(isLoading: true, child: content);
///
/// // Error card
/// ErrorCard(message: 'Something went wrong', onRetry: retryAction);
///
/// // Section header
/// SectionHeader(title: 'Wall Parameters');
/// ```
library;

import 'package:flutter/material.dart';

/// A loading overlay that displays a spinner over content.
class LoadingOverlay extends StatelessWidget {
  /// Whether to show the loading overlay.
  final bool isLoading;

  /// The child widget to display.
  final Widget child;

  /// Optional loading message.
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Text(message!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A card that displays an error message with optional retry action.
class ErrorCard extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Optional retry callback.
  final VoidCallback? onRetry;

  /// Optional dismiss callback.
  final VoidCallback? onDismiss;

  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            if (onDismiss != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onErrorContainer,
                ),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}

/// A section header with optional subtitle.
class SectionHeader extends StatelessWidget {
  /// The section title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Optional trailing widget.
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A labeled form field with optional validation.
class LabeledTextField extends StatelessWidget {
  /// The field label.
  final String label;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Initial value if no controller provided.
  final String? initialValue;

  /// Hint text for the field.
  final String? hint;

  /// Helper text below the field.
  final String? helperText;

  /// Error text to display.
  final String? errorText;

  /// Whether the field is required.
  final bool required;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// Keyboard type for the field.
  final TextInputType? keyboardType;

  /// Maximum number of lines.
  final int maxLines;

  /// Called when the field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Input formatters.
  final List<dynamic>? inputFormatters;

  /// Prefix icon.
  final IconData? prefixIcon;

  /// Suffix widget.
  final Widget? suffix;

  const LabeledTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.helperText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.prefixIcon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (required)
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
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffix: suffix,
          ),
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

/// A labeled dropdown field.
class LabeledDropdown<T> extends StatelessWidget {
  /// The field label.
  final String label;

  /// Current selected value.
  final T? value;

  /// Available options.
  final List<DropdownMenuItem<T>> items;

  /// Called when selection changes.
  final ValueChanged<T?>? onChanged;

  /// Whether the field is required.
  final bool required;

  /// Whether the field is enabled.
  final bool enabled;

  /// Hint text when no selection.
  final String? hint;

  /// Helper text below the field.
  final String? helperText;

  /// Error text to display.
  final String? errorText;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.required = false,
    this.enabled = true,
    this.hint,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (required)
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
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

/// A stepper-style progress indicator for wizard steps.
class WizardProgressIndicator extends StatelessWidget {
  /// Total number of steps.
  final int totalSteps;

  /// Current step (0-indexed).
  final int currentStep;

  /// Labels for each step.
  final List<String>? stepLabels;

  /// Called when a step is tapped.
  final ValueChanged<int>? onStepTapped;

  const WizardProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.stepLabels,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          );
        } else {
          // Step indicator
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          return GestureDetector(
            onTap: onStepTapped != null && stepIndex <= currentStep
                ? () => onStepTapped!(stepIndex)
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    border: isCurrent
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: colorScheme.onPrimary,
                          )
                        : Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color: isCurrent
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (stepLabels != null && stepIndex < stepLabels!.length) ...[
                  const SizedBox(height: 4),
                  Text(
                    stepLabels![stepIndex],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isCurrent
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          );
        }
      }),
    );
  }
}

/// A price display card.
class PriceCard extends StatelessWidget {
  /// The price amount.
  final double price;

  /// Description of what the price includes.
  final String description;

  /// Optional tier label.
  final String? tierLabel;

  const PriceCard({
    super.key,
    required this.price,
    required this.description,
    this.tierLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tierLabel != null)
                  Text(
                    tierLabel!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A responsive container that adjusts its max width based on screen size.
class ResponsiveContainer extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// Maximum width on large screens.
  final double maxWidth;

  /// Padding around the container.
  final EdgeInsets padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A confirmation dialog widget.
class ConfirmationDialog extends StatelessWidget {
  /// Dialog title.
  final String title;

  /// Dialog message.
  final String message;

  /// Confirm button text.
  final String confirmText;

  /// Cancel button text.
  final String cancelText;

  /// Whether the action is destructive.
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  /// Shows the confirmation dialog and returns true if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// An empty state placeholder widget.
class EmptyState extends StatelessWidget {
  /// Icon to display.
  final IconData icon;

  /// Title text.
  final String title;

  /// Description text.
  final String? description;

  /// Optional action button.
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
