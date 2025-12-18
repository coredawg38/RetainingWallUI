/// Information/Landing Page
///
/// The home page that introduces the retaining wall design service.
/// Provides overview of the service, pricing tiers, and navigation to design.
///
/// Usage:
/// ```dart
/// // Navigate to this page
/// context.go('/');
/// ```
library;

import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/common_widgets.dart';

/// Information/Landing page for the Retaining Wall Design service.
class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retaining Wall Designer'),
        actions: [
          FilledButton.icon(
            onPressed: () => context.goToDesign(),
            icon: const Icon(Icons.architecture),
            label: const Text('Start Design'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HeroSection(),
              const SizedBox(height: 48),
              const _FeaturesSection(),
              const SizedBox(height: 48),
              const _PricingSection(),
              const SizedBox(height: 48),
              const _HowItWorksSection(),
              const SizedBox(height: 48),
              _CallToActionSection(
                onGetStarted: () => context.goToDesign(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero section with main headline and value proposition.
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.foundation,
              size: 80,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Professional Retaining Wall Designs',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Get professional engineering drawings for your retaining wall project. '
              'Specify your wall parameters, and we will generate detailed PDF drawings '
              'ready for construction.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.goToDesign(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Start Your Design'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Features section highlighting key benefits.
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Why Choose Our Service',
          subtitle: 'Professional designs delivered quickly',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final features = [
              _FeatureItem(
                icon: Icons.engineering,
                title: 'Engineering Drawings',
                description:
                    'Receive detailed PDF drawings with dimensions, rebar placement, and structural specifications.',
              ),
              _FeatureItem(
                icon: Icons.speed,
                title: 'Fast Turnaround',
                description:
                    'Get your designs within minutes. Our automated system generates drawings instantly.',
              ),
              _FeatureItem(
                icon: Icons.tune,
                title: 'Customizable Parameters',
                description:
                    'Specify height, materials, soil conditions, and optimization preferences for your project.',
              ),
              _FeatureItem(
                icon: Icons.attach_money,
                title: 'Transparent Pricing',
                description:
                    'Simple pricing based on wall height. No hidden fees or surprises.',
              ),
            ];

            if (isWide) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: features,
              );
            } else {
              return Column(
                children: features
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: f,
                        ))
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Individual feature item card.
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

/// Pricing section showing different tiers.
class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Simple Pricing',
          subtitle: 'Choose the tier that matches your wall height',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final cards = [
              _PricingTierCard(
                tier: 'Small Wall',
                price: PricingTiers.smallWallPrice,
                heightRange: 'Up to ${PricingTiers.smallWallMaxFeet.toInt()} feet',
                features: const [
                  'Preview drawing',
                  'Detailed construction drawing',
                  'PDF download',
                  'Email delivery',
                ],
              ),
              _PricingTierCard(
                tier: 'Medium Wall',
                price: PricingTiers.mediumWallPrice,
                heightRange:
                    '${PricingTiers.smallWallMaxFeet.toInt()}-${PricingTiers.mediumWallMaxFeet.toInt()} feet',
                features: const [
                  'Preview drawing',
                  'Detailed construction drawing',
                  'Multi-section design',
                  'PDF download',
                  'Email delivery',
                ],
                isPopular: true,
              ),
              _PricingTierCard(
                tier: 'Large Wall',
                price: PricingTiers.largeWallPrice,
                heightRange: 'Over ${PricingTiers.mediumWallMaxFeet.toInt()} feet',
                features: const [
                  'Preview drawing',
                  'Detailed construction drawing',
                  'Multi-section design',
                  'Structural calculations',
                  'PDF download',
                  'Email delivery',
                ],
              ),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards
                    .map((card) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: card,
                          ),
                        ))
                    .toList(),
              );
            } else {
              return Column(
                children: cards
                    .map((card) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: card,
                        ))
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Individual pricing tier card.
class _PricingTierCard extends StatelessWidget {
  final String tier;
  final double price;
  final String heightRange;
  final List<String> features;
  final bool isPopular;

  const _PricingTierCard({
    required this.tier,
    required this.price,
    required this.heightRange,
    required this.features,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: colorScheme.primary,
              child: Text(
                'Most Popular',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  heightRange,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                    Text(
                      price.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    Text(
                      '.${(price % 1 * 100).toInt().toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature)),
                      ],
                    ),
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

/// How it works section explaining the process.
class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'How It Works',
          subtitle: 'Get your designs in four simple steps',
        ),
        const SizedBox(height: 16),
        const _StepItem(
          stepNumber: 1,
          title: 'Enter Wall Parameters',
          description:
              'Specify your wall height, material (concrete or CMU), soil conditions, and other parameters.',
        ),
        const _StepItem(
          stepNumber: 2,
          title: 'Add Your Information',
          description:
              'Enter site address and contact information for document delivery.',
        ),
        const _StepItem(
          stepNumber: 3,
          title: 'Complete Payment',
          description:
              'Review your design and complete secure payment via Stripe.',
        ),
        const _StepItem(
          stepNumber: 4,
          title: 'Download Your Designs',
          description:
              'Download your PDF drawings instantly or have them sent to your email.',
          isLast: true,
        ),
      ],
    );
  }
}

/// Individual step item in the how it works section.
class _StepItem extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isLast;

  const _StepItem({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Call to action section at the bottom.
class _CallToActionSection extends StatelessWidget {
  final VoidCallback onGetStarted;

  const _CallToActionSection({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              'Ready to Get Started?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start designing your retaining wall today. '
              'Get professional engineering drawings in minutes.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onGetStarted,
              icon: const Icon(Icons.architecture),
              label: const Text('Start Your Design'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.onPrimaryContainer,
                foregroundColor: colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
