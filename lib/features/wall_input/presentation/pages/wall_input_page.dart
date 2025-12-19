/// Wall Input Page
///
/// Main design page with split layout:
/// - Left side: Real-time wall preview
/// - Right side: Wizard steps for input
///
/// Usage:
/// ```dart
/// // Navigate to this page
/// context.go('/design');
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/payment_form_widget.dart';
import '../../data/models/retaining_wall_input.dart';
import '../../providers/wall_input_provider.dart';
import '../widgets/address_form.dart';
import '../widgets/customer_form.dart';
import '../widgets/wall_form.dart';
import '../widgets/wall_preview.dart';

/// Main wall design input page with split layout.
class WallInputPage extends ConsumerWidget {
  const WallInputPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wallInputProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Your Wall'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goToHome(),
          tooltip: 'Back to Home',
        ),
      ),
      body: LoadingOverlay(
        isLoading: state.isSubmitting,
        message: 'Processing your design...',
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout - stack on narrow screens
            if (constraints.maxWidth < 900) {
              return _MobileLayout(state: state);
            }
            return _DesktopLayout(state: state);
          },
        ),
      ),
    );
  }
}

/// Desktop layout with side-by-side preview and wizard.
class _DesktopLayout extends ConsumerWidget {
  final WallInputState state;

  const _DesktopLayout({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left side - Preview
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: WallPreview(
              input: state.input,
              error: state.errorMessage,
            ),
          ),
        ),
        // Divider
        const VerticalDivider(width: 1),
        // Right side - Wizard
        Expanded(
          flex: 4,
          child: _WizardPanel(state: state),
        ),
      ],
    );
  }
}

/// Mobile layout with tabbed preview and wizard.
class _MobileLayout extends ConsumerWidget {
  final WallInputState state;

  const _MobileLayout({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Design', icon: Icon(Icons.edit)),
              Tab(text: 'Preview', icon: Icon(Icons.preview)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _WizardPanel(state: state),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: WallPreview(
                    input: state.input,
                    error: state.errorMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wizard panel with step navigation.
class _WizardPanel extends ConsumerWidget {
  final WallInputState state;

  const _WizardPanel({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: WizardProgressIndicator(
            totalSteps: WizardStep.values.length,
            currentStep: state.currentStep.index,
            stepLabels: WizardStep.values.map((s) => s.displayName).toList(),
            onStepTapped: (index) {
              // Only allow going back to previous steps
              if (index <= state.currentStep.index) {
                ref.read(wallInputProvider.notifier).goToStep(
                      WizardStep.values[index],
                    );
              }
            },
          ),
        ),
        const Divider(height: 1),
        // Step content
        Expanded(
          child: _StepContent(state: state),
        ),
        // Navigation buttons
        const Divider(height: 1),
        _NavigationButtons(state: state),
      ],
    );
  }
}

/// Content for each wizard step.
class _StepContent extends ConsumerWidget {
  final WallInputState state;

  const _StepContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(wallInputProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.errorMessage != null) ...[
            ErrorCard(
              message: state.errorMessage!,
              onDismiss: notifier.clearError,
            ),
            const SizedBox(height: 16),
          ],
          _buildStepContent(context, ref),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(wallInputProvider.notifier);

    switch (state.currentStep) {
      case WizardStep.parameters:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WallForm(
              input: state.input,
              onHeightChanged: notifier.updateHeight,
              onMaterialChanged: notifier.updateMaterial,
              onSurchargeChanged: notifier.updateSurcharge,
              onOptimizationChanged: notifier.updateOptimizationParameter,
              onSoilStiffnessChanged: notifier.updateSoilStiffness,
              onToppingChanged: notifier.updateTopping,
              onHasSlabChanged: notifier.updateHasSlab,
              onToeChanged: notifier.updateToe,
            ),
            const SizedBox(height: 24),
            AddressForm(
              title: 'Site Address',
              subtitle: 'Where the wall will be built',
              address: state.input.siteAddress,
              onStreetChanged: notifier.updateSiteStreet,
              onCityChanged: notifier.updateSiteCity,
              onStateChanged: notifier.updateSiteState,
              onZipCodeChanged: notifier.updateSiteZipCode,
            ),
          ],
        );

      case WizardStep.customerInfo:
        return CustomerForm(
          customerInfo: state.input.customerInfo,
          siteAddress: state.input.siteAddress,
          onNameChanged: notifier.updateCustomerName,
          onEmailChanged: notifier.updateCustomerEmail,
          onPhoneChanged: notifier.updateCustomerPhone,
        );

      case WizardStep.payment:
        return _PaymentStepContent(state: state);

      case WizardStep.delivery:
        return _DeliveryStepContent(state: state);
    }
  }
}

/// Payment step content.
class _PaymentStepContent extends ConsumerWidget {
  final WallInputState state;

  const _PaymentStepContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Order Summary',
          subtitle: 'Review your design details',
        ),
        const SizedBox(height: 16),
        _OrderSummaryCard(state: state),
        const SizedBox(height: 24),
        PriceCard(
          price: state.price,
          description: 'Professional engineering drawings with detailed specifications',
          tierLabel: state.priceTierDescription,
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Payment',
          subtitle: 'Secure payment via Stripe',
        ),
        const SizedBox(height: 16),
        PaymentFormWidget(
          price: state.price,
          email: state.input.customerInfo.email,
          customerName: state.input.customerInfo.name,
          metadata: {
            'wall_height': state.input.height.toString(),
            'material': state.input.materialLabel,
          },
          onPaymentSuccess: () async {
            // Submit design after successful payment
            final designSuccess =
                await ref.read(wallInputProvider.notifier).submitDesign();
            if (designSuccess) {
              ref.read(wallInputProvider.notifier).nextStep();
            }
          },
          showMethodToggle: true,
          showSecurityInfo: false, // Compact view in wizard
        ),
      ],
    );
  }
}

/// Order summary card.
class _OrderSummaryCard extends StatelessWidget {
  final WallInputState state;

  const _OrderSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(
              label: 'Wall Height',
              value: '${state.input.height.toStringAsFixed(0)}" (${state.input.heightInFeet.toStringAsFixed(1)} ft)',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Material',
              value: state.input.materialLabel,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Site Conditions',
              value: '${state.input.surchargeLabel}, ${state.input.soilStiffnessLabel}',
            ),
            const Divider(height: 24),
            Text(
              'Site Address',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            AddressDisplay(address: state.input.siteAddress),
            const Divider(height: 24),
            Text(
              'Customer',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(state.input.customerInfo.name),
            Text(state.input.customerInfo.email),
          ],
        ),
      ),
    );
  }
}

/// Summary row with label and value.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

/// Delivery step content.
class _DeliveryStepContent extends ConsumerWidget {
  final WallInputState state;

  const _DeliveryStepContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final response = state.lastResponse;
    final colorScheme = Theme.of(context).colorScheme;

    if (response == null || !response.success) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Design Not Ready',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              response?.errorMessage ?? 'Please complete payment first',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Design is Ready!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Request ID: ${response.requestId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Download Documents',
          subtitle: 'Click to download your engineering drawings',
        ),
        const SizedBox(height: 16),
        _DownloadButton(
          icon: Icons.visibility,
          title: 'Preview Drawing',
          description: 'Quick overview of your wall design',
          onPressed: () {
            // Navigate to delivery page for downloads
            context.goToDelivery(response.requestId);
          },
        ),
        const SizedBox(height: 12),
        _DownloadButton(
          icon: Icons.article,
          title: 'Detailed Drawing',
          description: 'Full construction specifications and calculations',
          onPressed: () {
            context.goToDelivery(response.requestId);
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => context.goToDelivery(response.requestId),
          icon: const Icon(Icons.download),
          label: const Text('Go to Downloads'),
        ),
      ],
    );
  }
}

/// Download button card.
class _DownloadButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  const _DownloadButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation buttons at the bottom of the wizard.
class _NavigationButtons extends ConsumerWidget {
  final WallInputState state;

  const _NavigationButtons({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(wallInputProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (state.canGoBack)
            OutlinedButton.icon(
              onPressed: notifier.previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          const Spacer(),
          if (state.currentStep != WizardStep.delivery &&
              state.currentStep != WizardStep.payment)
            FilledButton.icon(
              onPressed: state.canProceed ? notifier.nextStep : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                state.currentStep == WizardStep.customerInfo
                    ? 'Proceed to Payment'
                    : 'Continue',
              ),
            ),
          if (state.currentStep == WizardStep.delivery)
            FilledButton.icon(
              onPressed: () => context.goToHome(),
              icon: const Icon(Icons.check),
              label: const Text('Done'),
            ),
        ],
      ),
    );
  }
}
