/// Delivery Page
///
/// Document delivery page for downloading PDF drawings and sending via email.
///
/// Usage:
/// ```dart
/// // Navigate to this page
/// context.go('/delivery/request-123');
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../wall_input/providers/wall_input_provider.dart';
import '../../providers/delivery_provider.dart';

/// Document delivery page.
class DeliveryPage extends ConsumerStatefulWidget {
  /// Request ID for the design.
  final String requestId;

  const DeliveryPage({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends ConsumerState<DeliveryPage> {
  @override
  void initState() {
    super.initState();
    // Initialize delivery state with request ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deliveryProvider.notifier).setRequestId(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);
    final wallState = ref.watch(wallInputProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Documents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goToHome(),
          tooltip: 'Back to Home',
        ),
      ),
      body: LoadingOverlay(
        isLoading: deliveryState.status == DeliveryStatus.downloading ||
            deliveryState.status == DeliveryStatus.sendingEmail,
        message: deliveryState.status == DeliveryStatus.downloading
            ? 'Downloading...'
            : 'Sending email...',
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            maxWidth: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _SuccessHeader(requestId: widget.requestId),
                const SizedBox(height: 24),
                _DocumentsSection(
                  deliveryState: deliveryState,
                  requestId: widget.requestId,
                ),
                const SizedBox(height: 24),
                _EmailSection(
                  deliveryState: deliveryState,
                  customerEmail: wallState.input.customerInfo.email,
                ),
                const SizedBox(height: 24),
                _WhatNextSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Success header with celebration.
class _SuccessHeader extends StatelessWidget {
  final String requestId;

  const _SuccessHeader({required this.requestId});

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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
              child: Icon(
                Icons.celebration,
                size: 48,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Design is Ready!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for your order. Your engineering drawings are ready for download.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Order ID: $requestId',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
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

/// Documents download section.
class _DocumentsSection extends ConsumerWidget {
  final DeliveryState deliveryState;
  final String requestId;

  const _DocumentsSection({
    required this.deliveryState,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.read(apiClientProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_open,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Documents',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DocumentCard(
              icon: Icons.visibility,
              title: 'Preview Drawing',
              description: 'Quick overview of your wall design with key dimensions',
              fileSize: '~500 KB',
              isDownloaded: deliveryState.previewDownloaded,
              onDownload: () => _downloadFile(
                context,
                ref,
                apiClient.getFileUrl(requestId, 'PreviewDrawing.pdf'),
                'PreviewDrawing.pdf',
                isPreview: true,
              ),
            ),
            const SizedBox(height: 12),
            _DocumentCard(
              icon: Icons.article,
              title: 'Detailed Construction Drawing',
              description: 'Complete specifications, calculations, and construction details',
              fileSize: '~1.5 MB',
              isDownloaded: deliveryState.detailedDownloaded,
              onDownload: () => _downloadFile(
                context,
                ref,
                apiClient.getFileUrl(requestId, 'DetailedDrawing.pdf'),
                'DetailedDrawing.pdf',
                isPreview: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(
    BuildContext context,
    WidgetRef ref,
    String url,
    String filename, {
    required bool isPreview,
  }) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Mark as downloaded
        final notifier = ref.read(deliveryProvider.notifier);
        if (isPreview) {
          notifier.markPreviewDownloaded();
        } else {
          notifier.markDetailedDownloaded();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open download link for $filename'),
              action: SnackBarAction(
                label: 'Copy Link',
                onPressed: () {
                  // Copy link to clipboard functionality would go here
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }
}

/// Individual document card.
class _DocumentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String fileSize;
  final bool isDownloaded;
  final VoidCallback onDownload;

  const _DocumentCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.fileSize,
    required this.isDownloaded,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDownload,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDownloaded
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDownloaded ? Icons.check_circle : icon,
                    color: isDownloaded
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (isDownloaded)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Downloaded',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PDF - $fileSize',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onDownload,
                  icon: Icon(isDownloaded ? Icons.download_done : Icons.download),
                  label: Text(isDownloaded ? 'Open' : 'Download'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Email delivery section.
class _EmailSection extends ConsumerStatefulWidget {
  final DeliveryState deliveryState;
  final String customerEmail;

  const _EmailSection({
    required this.deliveryState,
    required this.customerEmail,
  });

  @override
  ConsumerState<_EmailSection> createState() => _EmailSectionState();
}

class _EmailSectionState extends ConsumerState<_EmailSection> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.customerEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
                Icon(Icons.email, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Email Delivery',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Have your documents sent directly to your email',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            if (widget.deliveryState.emailSent) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Sent Successfully',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Documents sent to ${widget.deliveryState.emailAddress}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'john@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _sendEmail(context),
                  icon: const Icon(Icons.send),
                  label: const Text('Send to Email'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    final success = await ref.read(deliveryProvider.notifier).sendEmail(email);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send email. Please try again.')),
        );
      }
    }
  }
}

/// What's next section with helpful information.
class _WhatNextSection extends StatelessWidget {
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
                Icon(Icons.lightbulb, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'What\'s Next?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _NextStepItem(
              number: 1,
              title: 'Review Your Drawings',
              description: 'Check all dimensions and specifications match your requirements.',
            ),
            _NextStepItem(
              number: 2,
              title: 'Consult a Professional',
              description: 'Have a licensed engineer or contractor review the plans.',
            ),
            _NextStepItem(
              number: 3,
              title: 'Obtain Permits',
              description: 'Submit drawings to your local building department for permits.',
            ),
            _NextStepItem(
              number: 4,
              title: 'Begin Construction',
              description: 'Work with qualified contractors to build your retaining wall.',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual next step item.
class _NextStepItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final bool isLast;

  const _NextStepItem({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
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
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
