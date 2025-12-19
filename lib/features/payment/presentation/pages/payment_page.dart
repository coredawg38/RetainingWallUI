/// Payment Page
///
/// Standalone payment processing page with Stripe integration.
/// Uses the shared PaymentFormWidget for payment processing.
///
/// Usage:
/// ```dart
/// // Navigate to this page
/// context.go('/payment');
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/payment_form_widget.dart';
import '../../../wall_input/data/models/retaining_wall_input.dart';
import '../../../wall_input/providers/wall_input_provider.dart';
import '../../providers/payment_provider.dart';

/// Standalone payment page.
class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                PaymentFormWidget(
                  price: wallState.price,
                  email: wallState.input.customerInfo.email,
                  customerName: wallState.input.customerInfo.name,
                  metadata: {
                    'wall_height': wallState.input.height.toString(),
                    'material': wallState.input.materialLabel,
                  },
                  onPaymentSuccess: () async {
                    await _submitDesignAndNavigate(context, ref);
                  },
                  showMethodToggle: true,
                  showDemoButton: true,
                  showSecurityInfo: true,
                  expanded: true, // Show payment method chips
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
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
