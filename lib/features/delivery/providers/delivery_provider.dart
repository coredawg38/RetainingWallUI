/// Delivery Providers
///
/// Riverpod providers for managing document delivery state,
/// including PDF downloads and email notifications.
///
/// Usage:
/// ```dart
/// // Check delivery status
/// final status = ref.watch(deliveryProvider);
///
/// // Download preview PDF
/// await ref.read(deliveryProvider.notifier).downloadPreviewPdf();
/// ```
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../wall_input/providers/wall_input_provider.dart';

/// Delivery status enumeration.
enum DeliveryStatus {
  /// Waiting for design to complete.
  pending,

  /// Design is ready for download.
  ready,

  /// Files are being downloaded.
  downloading,

  /// Email is being sent.
  sendingEmail,

  /// Delivery completed.
  completed,

  /// Delivery failed.
  failed,
}

/// State class for document delivery.
class DeliveryState {
  /// Current delivery status.
  final DeliveryStatus status;

  /// Request ID for the design.
  final String? requestId;

  /// URL for the preview PDF.
  final String? previewPdfUrl;

  /// URL for the detailed PDF.
  final String? detailedPdfUrl;

  /// Whether preview PDF has been downloaded.
  final bool previewDownloaded;

  /// Whether detailed PDF has been downloaded.
  final bool detailedDownloaded;

  /// Whether email has been sent.
  final bool emailSent;

  /// Email address for delivery.
  final String? emailAddress;

  /// Error message if delivery failed.
  final String? errorMessage;

  /// Download progress (0.0 - 1.0).
  final double downloadProgress;

  const DeliveryState({
    this.status = DeliveryStatus.pending,
    this.requestId,
    this.previewPdfUrl,
    this.detailedPdfUrl,
    this.previewDownloaded = false,
    this.detailedDownloaded = false,
    this.emailSent = false,
    this.emailAddress,
    this.errorMessage,
    this.downloadProgress = 0.0,
  });

  /// Creates a copy with the given fields updated.
  DeliveryState copyWith({
    DeliveryStatus? status,
    String? requestId,
    String? previewPdfUrl,
    String? detailedPdfUrl,
    bool? previewDownloaded,
    bool? detailedDownloaded,
    bool? emailSent,
    String? emailAddress,
    String? errorMessage,
    double? downloadProgress,
  }) {
    return DeliveryState(
      status: status ?? this.status,
      requestId: requestId ?? this.requestId,
      previewPdfUrl: previewPdfUrl ?? this.previewPdfUrl,
      detailedPdfUrl: detailedPdfUrl ?? this.detailedPdfUrl,
      previewDownloaded: previewDownloaded ?? this.previewDownloaded,
      detailedDownloaded: detailedDownloaded ?? this.detailedDownloaded,
      emailSent: emailSent ?? this.emailSent,
      emailAddress: emailAddress ?? this.emailAddress,
      errorMessage: errorMessage,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  /// Whether files are ready for download.
  bool get isReady =>
      status == DeliveryStatus.ready || status == DeliveryStatus.completed;

  /// Whether all files have been downloaded.
  bool get allDownloaded => previewDownloaded && detailedDownloaded;

  /// Whether delivery is complete (all files downloaded and email sent).
  bool get isComplete =>
      status == DeliveryStatus.completed ||
      (allDownloaded && emailSent);
}

/// Notifier for managing delivery state.
class DeliveryNotifier extends StateNotifier<DeliveryState> {
  final ApiClient _apiClient;

  DeliveryNotifier(this._apiClient) : super(const DeliveryState());

  /// Initializes the delivery state with request information.
  void initialize({
    required String requestId,
    String? previewPdfUrl,
    String? detailedPdfUrl,
    String? emailAddress,
  }) {
    state = DeliveryState(
      status: DeliveryStatus.ready,
      requestId: requestId,
      previewPdfUrl: previewPdfUrl,
      detailedPdfUrl: detailedPdfUrl,
      emailAddress: emailAddress,
    );
  }

  /// Sets the request ID and fetches file URLs.
  Future<void> setRequestId(String requestId) async {
    state = state.copyWith(
      requestId: requestId,
      status: DeliveryStatus.pending,
    );

    // Get file URLs
    final previewUrl = _apiClient.getFileUrl(requestId, 'PreviewDrawing.pdf');
    final detailedUrl = _apiClient.getFileUrl(requestId, 'DetailedDrawing.pdf');

    state = state.copyWith(
      previewPdfUrl: previewUrl,
      detailedPdfUrl: detailedUrl,
      status: DeliveryStatus.ready,
    );
  }

  /// Downloads the preview PDF.
  Future<List<int>?> downloadPreviewPdf() async {
    if (state.requestId == null) return null;

    state = state.copyWith(
      status: DeliveryStatus.downloading,
      downloadProgress: 0.0,
    );

    try {
      final bytes = await _apiClient.downloadFile(
        state.requestId!,
        'PreviewDrawing.pdf',
      );

      if (bytes != null) {
        state = state.copyWith(
          previewDownloaded: true,
          downloadProgress: 1.0,
          status: DeliveryStatus.ready,
        );
        return bytes;
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to download preview PDF',
          status: DeliveryStatus.ready,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Download error: $e',
        status: DeliveryStatus.failed,
      );
      return null;
    }
  }

  /// Downloads the detailed PDF.
  Future<List<int>?> downloadDetailedPdf() async {
    if (state.requestId == null) return null;

    state = state.copyWith(
      status: DeliveryStatus.downloading,
      downloadProgress: 0.0,
    );

    try {
      final bytes = await _apiClient.downloadFile(
        state.requestId!,
        'DetailedDrawing.pdf',
      );

      if (bytes != null) {
        state = state.copyWith(
          detailedDownloaded: true,
          downloadProgress: 1.0,
          status: DeliveryStatus.ready,
        );
        return bytes;
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to download detailed PDF',
          status: DeliveryStatus.ready,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Download error: $e',
        status: DeliveryStatus.failed,
      );
      return null;
    }
  }

  /// Sends the documents via email.
  ///
  /// This is a placeholder implementation. In production, this would
  /// call a backend API to send the email.
  Future<bool> sendEmail(String emailAddress) async {
    state = state.copyWith(
      status: DeliveryStatus.sendingEmail,
      emailAddress: emailAddress,
      errorMessage: null,
    );

    try {
      // Placeholder: Simulate email sending
      // In production, call backend API to send email
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        emailSent: true,
        status: DeliveryStatus.completed,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send email: $e',
        status: DeliveryStatus.failed,
      );
      return false;
    }
  }

  /// Marks preview as downloaded (for external download handling).
  void markPreviewDownloaded() {
    state = state.copyWith(previewDownloaded: true);
    _checkCompletion();
  }

  /// Marks detailed PDF as downloaded (for external download handling).
  void markDetailedDownloaded() {
    state = state.copyWith(detailedDownloaded: true);
    _checkCompletion();
  }

  /// Checks if delivery is complete and updates status.
  void _checkCompletion() {
    if (state.allDownloaded && state.emailSent) {
      state = state.copyWith(status: DeliveryStatus.completed);
    }
  }

  /// Resets the delivery state.
  void reset() {
    state = const DeliveryState();
  }

  /// Clears any error messages.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for delivery state and notifier.
final deliveryProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DeliveryNotifier(apiClient);
});

/// Provider for whether delivery is ready.
final deliveryReadyProvider = Provider<bool>((ref) {
  return ref.watch(deliveryProvider.select((state) => state.isReady));
});

/// Provider for whether all files have been downloaded.
final allFilesDownloadedProvider = Provider<bool>((ref) {
  return ref.watch(deliveryProvider.select((state) => state.allDownloaded));
});

/// Provider for delivery error message.
final deliveryErrorProvider = Provider<String?>((ref) {
  return ref.watch(deliveryProvider.select((state) => state.errorMessage));
});

/// Provider for the preview PDF URL.
final previewPdfUrlProvider = Provider<String?>((ref) {
  return ref.watch(deliveryProvider.select((state) => state.previewPdfUrl));
});

/// Provider for the detailed PDF URL.
final detailedPdfUrlProvider = Provider<String?>((ref) {
  return ref.watch(deliveryProvider.select((state) => state.detailedPdfUrl));
});
