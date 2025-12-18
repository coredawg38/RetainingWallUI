/// Payment Page
///
/// Standalone payment processing page with Stripe integration.
/// Supports both Payment Sheet (recommended) and manual card entry.
///
/// Usage:
/// ```dart
/// // Navigate to this page
/// context.go('/payment');
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../wall_input/data/models/retaining_wall_input.dart';
import '../../../wall_input/providers/wall_input_provider.dart';
import '../../providers/payment_provider.dart';

/// Logger for PaymentPage operations.
class _PageLogger {
  static const String _tag = '[PaymentPage]';

  static void info(String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('$_tag $timestamp: $message');
  }

  static void error(String message, [Object? error]) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('$_tag $timestamp ERROR: $message');
    if (error != null) {
      debugPrint('$_tag $timestamp ERROR DETAILS: $error');
    }
  }
}

/// Standalone payment page.
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  bool _usePaymentSheet = true;

  @override
  void initState() {
    super.initState();
    _PageLogger.info('PaymentPage initState');
    _PageLogger.info('Platform: kIsWeb=$kIsWeb');
    // Initialize Stripe when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _PageLogger.info('PostFrameCallback: initializing Stripe...');
      ref.read(paymentProvider.notifier).initializeStripe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallState = ref.watch(wallInputProvider);
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goToDesign(),
          tooltip: 'Back to Design',
        ),
      ),
      body: LoadingOverlay(
        isLoading: paymentState.isProcessing,
        message: 'Processing payment...',
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _OrderSummary(wallState: wallState),
                const SizedBox(height: 24),
                _PaymentMethodToggle(
                  usePaymentSheet: _usePaymentSheet,
                  onChanged: (value) => setState(() => _usePaymentSheet = value),
                ),
                const SizedBox(height: 16),
                if (_usePaymentSheet)
                  _PaymentSheetSection(
                    wallState: wallState,
                    paymentState: paymentState,
                  )
                else
                  _CardFormSection(
                    wallState: wallState,
                    paymentState: paymentState,
                  ),
                const SizedBox(height: 24),
                _SecurityInfo(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle between Payment Sheet and manual card entry.
class _PaymentMethodToggle extends StatelessWidget {
  final bool usePaymentSheet;
  final ValueChanged<bool> onChanged;

  const _PaymentMethodToggle({
    required this.usePaymentSheet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MethodOption(
                    title: 'Quick Pay',
                    subtitle: 'Stripe Payment Sheet',
                    icon: Icons.flash_on,
                    isSelected: usePaymentSheet,
                    onTap: () => onChanged(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodOption(
                    title: 'Card Entry',
                    subtitle: 'Enter card manually',
                    icon: Icons.credit_card,
                    isSelected: !usePaymentSheet,
                    onTap: () => onChanged(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment method option card.
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
              size: 28,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.primary : null,
                  ),
            ),
            const SizedBox(height: 2),
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

/// Order summary section.
class _OrderSummary extends StatelessWidget {
  final WallInputState wallState;

  const _OrderSummary({required this.wallState});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _OrderRow(
              label: 'Retaining Wall Design',
              sublabel: wallState.priceTierDescription,
            ),
            const SizedBox(height: 8),
            _OrderRow(
              label: 'Wall Height',
              value: '${wallState.input.height.toStringAsFixed(0)}" (${wallState.input.heightInFeet.toStringAsFixed(1)} ft)',
            ),
            _OrderRow(
              label: 'Material',
              value: wallState.input.materialLabel,
            ),
            const Divider(height: 24),
            _OrderRow(
              label: 'Includes:',
              sublabel: '- Preview Drawing (PDF)\n- Detailed Construction Drawing (PDF)\n- Email Delivery',
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '\$${wallState.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Order row with label and value.
class _OrderRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? sublabel;

  const _OrderRow({
    required this.label,
    this.value,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (value != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              value!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        if (sublabel != null) ...[
          const SizedBox(height: 4),
          Text(
            sublabel!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

/// Payment Sheet section - uses Stripe's built-in payment UI.
class _PaymentSheetSection extends ConsumerWidget {
  final WallInputState wallState;
  final PaymentState paymentState;

  const _PaymentSheetSection({
    required this.wallState,
    required this.paymentState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (paymentState.isComplete) {
      return _PaymentSuccess(transactionId: paymentState.transactionId);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Quick Pay with Stripe',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Click the button below to open Stripe\'s secure payment sheet. '
              'You can pay with credit card, debit card, Apple Pay, or Google Pay.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            // Accepted payment methods
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PaymentMethodChip(icon: Icons.credit_card, label: 'Visa'),
                _PaymentMethodChip(icon: Icons.credit_card, label: 'Mastercard'),
                _PaymentMethodChip(icon: Icons.credit_card, label: 'Amex'),
                _PaymentMethodChip(icon: Icons.apple, label: 'Apple Pay'),
                _PaymentMethodChip(icon: Icons.g_mobiledata, label: 'Google Pay'),
              ],
            ),
            if (paymentState.errorMessage != null) ...[
              const SizedBox(height: 16),
              _ErrorMessage(message: paymentState.errorMessage!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: paymentState.isProcessing
                    ? null
                    : () => _processPaymentSheet(context, ref),
                icon: paymentState.isProcessing
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
                  paymentState.isProcessing
                      ? 'Processing...'
                      : 'Pay \$${wallState.price.toStringAsFixed(2)}',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Demo mode button for testing
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: paymentState.isProcessing
                    ? null
                    : () => _processDemoPayment(context, ref),
                icon: const Icon(Icons.science),
                label: const Text('Demo Payment (Skip Stripe)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPaymentSheet(BuildContext context, WidgetRef ref) async {
    _PageLogger.info('_processPaymentSheet() called');
    final wallState = ref.read(wallInputProvider);
    final email = wallState.input.customerInfo.email;
    final name = wallState.input.customerInfo.name;

    _PageLogger.info('Processing payment for: $email, amount: \$${wallState.price}');
    _PageLogger.info('Wall height: ${wallState.input.height}", material: ${wallState.input.materialLabel}');

    final success = await ref.read(paymentProvider.notifier).processPayment(
      amount: wallState.price,
      email: email,
      customerName: name,
      metadata: {
        'wall_height': wallState.input.height.toString(),
        'material': wallState.input.materialLabel,
      },
    );

    _PageLogger.info('Payment result: success=$success');

    if (success && context.mounted) {
      _PageLogger.info('Payment successful, submitting design...');
      await _submitDesignAndNavigate(context, ref);
    } else if (!success) {
      _PageLogger.error('Payment failed or cancelled');
    }
  }

  Future<void> _processDemoPayment(BuildContext context, WidgetRef ref) async {
    final wallState = ref.read(wallInputProvider);
    final success = await ref.read(paymentProvider.notifier)
        .simulateSuccessfulPayment(wallState.price);

    if (success && context.mounted) {
      await _submitDesignAndNavigate(context, ref);
    }
  }

  Future<void> _submitDesignAndNavigate(BuildContext context, WidgetRef ref) async {
    final designSuccess = await ref.read(wallInputProvider.notifier).submitDesign();
    if (designSuccess && context.mounted) {
      final response = ref.read(wallInputProvider).lastResponse;
      if (response != null && response.success) {
        context.goToDelivery(response.requestId);
      }
    }
  }
}

/// Payment method chip display.
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
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

/// Manual card form section.
class _CardFormSection extends ConsumerStatefulWidget {
  final WallInputState wallState;
  final PaymentState paymentState;

  const _CardFormSection({
    required this.wallState,
    required this.paymentState,
  });

  @override
  ConsumerState<_CardFormSection> createState() => _CardFormSectionState();
}

class _CardFormSectionState extends ConsumerState<_CardFormSection> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardForm = widget.paymentState.cardFormState;

    if (widget.paymentState.isComplete) {
      return _PaymentSuccess(transactionId: widget.paymentState.transactionId);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Card Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Card brand icons
            Row(
              children: [
                _CardBrandIcon(brand: CardBrand.visa, isActive: _getCardBrand() == CardBrand.visa),
                const SizedBox(width: 8),
                _CardBrandIcon(brand: CardBrand.mastercard, isActive: _getCardBrand() == CardBrand.mastercard),
                const SizedBox(width: 8),
                _CardBrandIcon(brand: CardBrand.amex, isActive: _getCardBrand() == CardBrand.amex),
                const SizedBox(width: 8),
                _CardBrandIcon(brand: CardBrand.discover, isActive: _getCardBrand() == CardBrand.discover),
              ],
            ),
            const SizedBox(height: 20),
            // Card Number
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '4242 4242 4242 4242',
                prefixIcon: const Icon(Icons.credit_card),
                errorText: cardForm?.cardNumberError,
                suffixIcon: _getCardBrand() != CardBrand.unknown
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: _getCardBrandIcon(_getCardBrand()),
                      )
                    : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                _CardNumberFormatter(),
              ],
              onChanged: (value) {
                ref.read(paymentProvider.notifier).updateCardField(
                  cardNumber: value,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: 'Expiry',
                      hintText: 'MM/YY',
                      errorText: cardForm?.expiryError,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateFormatter(),
                    ],
                    onChanged: (value) {
                      ref.read(paymentProvider.notifier).updateCardField(
                        expiryDate: value,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvcController,
                    decoration: InputDecoration(
                      labelText: 'CVC',
                      hintText: '123',
                      errorText: cardForm?.cvcError,
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (value) {
                      ref.read(paymentProvider.notifier).updateCardField(
                        cvc: value,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'John Doe',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                ref.read(paymentProvider.notifier).updateCardField(
                  cardholderName: value,
                );
              },
            ),
            if (widget.paymentState.errorMessage != null) ...[
              const SizedBox(height: 16),
              _ErrorMessage(message: widget.paymentState.errorMessage!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.paymentState.isProcessing ||
                        !(cardForm?.isValid ?? false)
                    ? null
                    : () => _processCardPayment(context),
                icon: widget.paymentState.isProcessing
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
                  widget.paymentState.isProcessing
                      ? 'Processing...'
                      : 'Pay \$${widget.wallState.price.toStringAsFixed(2)}',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CardBrand _getCardBrand() {
    return _cardNumberController.text.cardBrand;
  }

  Widget _getCardBrandIcon(CardBrand brand) {
    switch (brand) {
      case CardBrand.visa:
        return const Text('VISA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue));
      case CardBrand.mastercard:
        return const Text('MC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange));
      case CardBrand.amex:
        return const Text('AMEX', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue));
      case CardBrand.discover:
        return const Text('DISC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange));
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _processCardPayment(BuildContext context) async {
    final wallState = ref.read(wallInputProvider);
    final email = wallState.input.customerInfo.email;

    final success = await ref.read(paymentProvider.notifier).processPaymentWithCard(
      amount: wallState.price,
      email: email,
      metadata: {
        'wall_height': wallState.input.height.toString(),
        'material': wallState.input.materialLabel,
      },
    );

    if (success && context.mounted) {
      final designSuccess = await ref.read(wallInputProvider.notifier).submitDesign();
      if (designSuccess && context.mounted) {
        final response = ref.read(wallInputProvider).lastResponse;
        if (response != null && response.success) {
          context.goToDelivery(response.requestId);
        }
      }
    }
  }
}

/// Card brand icon with active state.
class _CardBrandIcon extends StatelessWidget {
  final CardBrand brand;
  final bool isActive;

  const _CardBrandIcon({
    required this.brand,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String label;
    Color color;

    switch (brand) {
      case CardBrand.visa:
        label = 'VISA';
        color = Colors.blue;
      case CardBrand.mastercard:
        label = 'MC';
        color = Colors.orange;
      case CardBrand.amex:
        label = 'AMEX';
        color = Colors.blue.shade800;
      case CardBrand.discover:
        label = 'DISC';
        color = Colors.orange.shade700;
      default:
        label = '';
        color = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? color : colorScheme.outlineVariant,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? color : colorScheme.onSurfaceVariant,
        ),
      ),
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

/// Payment success display.
class _PaymentSuccess extends StatelessWidget {
  final String? transactionId;

  const _PaymentSuccess({this.transactionId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
              child: Icon(
                Icons.check,
                size: 48,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment has been processed successfully.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
            if (transactionId != null) ...[
              const SizedBox(height: 16),
              Text(
                'Transaction ID: $transactionId',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Security information section.
class _SecurityInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.security,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secure Payment',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your payment is processed securely by Stripe. We never store your card details. All transactions are encrypted with SSL.',
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

/// Input formatter for card numbers (adds spaces every 4 digits).
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Input formatter for expiry dates (adds slash after MM).
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length >= 2) {
      final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}
