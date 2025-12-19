/// Shared Payment Form Widget
///
/// A reusable payment form that supports both Payment Sheet and manual card entry.
/// Handles Stripe initialization automatically.
///
/// Usage:
/// ```dart
/// PaymentFormWidget(
///   price: 99.99,
///   email: 'user@example.com',
///   customerName: 'John Doe',
///   onPaymentSuccess: () async {
///     // Handle success - submit design, navigate, etc.
///   },
/// )
/// ```
library;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../features/payment/providers/payment_provider.dart';

/// Enum for payment method selection.
enum PaymentMethod {
  paymentSheet,
  cardEntry,
}

/// A reusable payment form widget with Stripe integration.
///
/// Supports both Payment Sheet (recommended) and manual card entry.
/// Automatically initializes Stripe when mounted.
class PaymentFormWidget extends ConsumerStatefulWidget {
  /// The price to charge.
  final double price;

  /// Customer email address.
  final String email;

  /// Customer name (optional).
  final String? customerName;

  /// Metadata to attach to the payment (optional).
  final Map<String, String>? metadata;

  /// Callback when payment succeeds.
  final Future<void> Function() onPaymentSuccess;

  /// Whether to show the payment method toggle (default: true).
  final bool showMethodToggle;

  /// Whether to show the demo payment button (default: true in debug mode).
  final bool showDemoButton;

  /// Whether to show the security info section (default: true).
  final bool showSecurityInfo;

  /// Whether to show an expanded layout (default: false).
  /// When true, shows more details like payment method chips.
  final bool expanded;

  const PaymentFormWidget({
    super.key,
    required this.price,
    required this.email,
    this.customerName,
    this.metadata,
    required this.onPaymentSuccess,
    this.showMethodToggle = true,
    this.showDemoButton = kDebugMode,
    this.showSecurityInfo = true,
    this.expanded = false,
  });

  @override
  ConsumerState<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends ConsumerState<PaymentFormWidget> {
  PaymentMethod _selectedMethod = PaymentMethod.paymentSheet;
  bool _stripeInitialized = false;

  // For CardField on web
  CardFieldInputDetails? _cardDetails;
  final CardEditController _cardController = CardEditController();

  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _initializeStripe() async {
    await ref.read(paymentProvider.notifier).initializeStripe();
    if (mounted) {
      setState(() => _stripeInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);

    if (paymentState.isComplete) {
      return _PaymentSuccessCard(
        transactionId: paymentState.transactionId,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showMethodToggle) ...[
          _PaymentMethodToggle(
            selectedMethod: _selectedMethod,
            onChanged: (method) => setState(() => _selectedMethod = method),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectedMethod == PaymentMethod.paymentSheet)
                  _PaymentSheetContent(
                    expanded: widget.expanded,
                  )
                else
                  _CardEntryContent(
                    cardDetails: _cardDetails,
                    cardController: _cardController,
                    onCardChanged: (details) {
                      setState(() => _cardDetails = details);
                    },
                  ),
                if (paymentState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorMessage(message: paymentState.errorMessage!),
                ],
                const SizedBox(height: 16),
                _PayButton(
                  price: widget.price,
                  isProcessing: paymentState.isProcessing,
                  canPay: _canPay(paymentState),
                  onPressed: () => _processPayment(context),
                ),
                if (widget.showDemoButton) ...[
                  const SizedBox(height: 8),
                  _DemoPaymentButton(
                    isProcessing: paymentState.isProcessing,
                    onPressed: () => _processDemoPayment(context),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.showSecurityInfo) ...[
          const SizedBox(height: 16),
          _SecurityInfoCard(),
        ],
      ],
    );
  }

  bool _canPay(PaymentState state) {
    if (state.isProcessing) return false;
    if (!_stripeInitialized) return false;

    if (_selectedMethod == PaymentMethod.cardEntry && kIsWeb) {
      return _cardDetails?.complete ?? false;
    }

    return true;
  }

  Future<void> _processPayment(BuildContext context) async {
    final success = await ref.read(paymentProvider.notifier).processPayment(
          amount: widget.price,
          email: widget.email,
          customerName: widget.customerName,
          metadata: widget.metadata,
        );

    if (success && context.mounted) {
      await widget.onPaymentSuccess();
    }
  }

  Future<void> _processDemoPayment(BuildContext context) async {
    final success = await ref
        .read(paymentProvider.notifier)
        .simulateSuccessfulPayment(widget.price);

    if (success && context.mounted) {
      await widget.onPaymentSuccess();
    }
  }
}

/// Toggle between Payment Sheet and Card Entry methods.
class _PaymentMethodToggle extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;

  const _PaymentMethodToggle({
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _MethodOption(
                title: 'Quick Pay',
                subtitle: 'Stripe Payment Sheet',
                icon: Icons.flash_on,
                isSelected: selectedMethod == PaymentMethod.paymentSheet,
                onTap: () => onChanged(PaymentMethod.paymentSheet),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MethodOption(
                title: 'Card Entry',
                subtitle: 'Enter card manually',
                icon: Icons.credit_card,
                isSelected: selectedMethod == PaymentMethod.cardEntry,
                onTap: () => onChanged(PaymentMethod.cardEntry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual method option in the toggle.
class _MethodOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.primary : null,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Content for Payment Sheet method.
class _PaymentSheetContent extends StatelessWidget {
  final bool expanded;

  const _PaymentSheetContent({this.expanded = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Quick Pay with Stripe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Click Pay to open Stripe\'s secure payment form. '
          'Supports credit cards, Apple Pay, and Google Pay.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        if (expanded) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _PaymentMethodChip(icon: Icons.credit_card, label: 'Visa'),
              _PaymentMethodChip(icon: Icons.credit_card, label: 'Mastercard'),
              _PaymentMethodChip(icon: Icons.credit_card, label: 'Amex'),
              _PaymentMethodChip(icon: Icons.apple, label: 'Apple Pay'),
              _PaymentMethodChip(icon: Icons.g_mobiledata, label: 'Google Pay'),
            ],
          ),
        ],
      ],
    );
  }
}

/// Payment method chip for displaying accepted methods.
class _PaymentMethodChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PaymentMethodChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Content for Card Entry method (web: CardField, mobile: info).
class _CardEntryContent extends StatelessWidget {
  final CardFieldInputDetails? cardDetails;
  final CardEditController cardController;
  final ValueChanged<CardFieldInputDetails?> onCardChanged;

  const _CardEntryContent({
    required this.cardDetails,
    required this.cardController,
    required this.onCardChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.credit_card, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Enter Card Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (kIsWeb) ...[
          // CardField for web
          SizedBox(
            height: 50,
            child: CardField(
              controller: cardController,
              onCardChanged: onCardChanged,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              cursorColor: colorScheme.primary,
              enablePostalCode: false,
              numberHintText: '4242 4242 4242 4242',
              expirationHintText: 'MM/YY',
              cvcHintText: 'CVC',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Test card: 4242 4242 4242 4242, any future date, any CVC',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ] else ...[
          // Mobile: Info that card entry will use Payment Sheet anyway
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'On mobile, a secure payment form will open when you tap Pay.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Main pay button.
class _PayButton extends StatelessWidget {
  final double price;
  final bool isProcessing;
  final bool canPay;
  final VoidCallback onPressed;

  const _PayButton({
    required this.price,
    required this.isProcessing,
    required this.canPay,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: canPay ? onPressed : null,
      icon: isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.lock),
      label: Text(
        isProcessing ? 'Processing...' : 'Pay \$${price.toStringAsFixed(2)}',
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

/// Demo payment button for testing.
class _DemoPaymentButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onPressed;

  const _DemoPaymentButton({
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isProcessing ? null : onPressed,
      icon: const Icon(Icons.science),
      label: const Text('Demo Payment (Skip Stripe)'),
    );
  }
}

/// Error message display.
class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment success card.
class _PaymentSuccessCard extends StatelessWidget {
  final String? transactionId;

  const _PaymentSuccessCard({this.transactionId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
              child: Icon(
                Icons.check,
                size: 36,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment has been processed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            if (transactionId != null) ...[
              const SizedBox(height: 12),
              Text(
                'Transaction: $transactionId',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Security info card.
class _SecurityInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.security, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secure Payment',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Encrypted and processed securely by Stripe.',
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
    );
  }
}
