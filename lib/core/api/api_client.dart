/// API Client for rwcpp Server
///
/// Provides HTTP client functionality for communicating with the
/// retaining wall calculation server.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final response = await client.submitDesign(wallInput);
/// ```
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// Response from the design submission endpoint.
class DesignResponse {
  /// Whether the design was successfully submitted.
  final bool success;

  /// Unique identifier for the design request.
  final String requestId;

  /// Wall specifications returned by the server.
  final Map<String, dynamic>? wallSpecifications;

  /// Available files for download.
  final DesignFiles? files;

  /// Error message if the request failed.
  final String? errorMessage;

  const DesignResponse({
    required this.success,
    required this.requestId,
    this.wallSpecifications,
    this.files,
    this.errorMessage,
  });

  factory DesignResponse.fromJson(Map<String, dynamic> json) {
    return DesignResponse(
      success: json['success'] as bool? ?? false,
      requestId: json['request_id'] as String? ?? '',
      wallSpecifications: json['wall_specifications'] as Map<String, dynamic>?,
      files: json['files'] != null
          ? DesignFiles.fromJson(json['files'] as Map<String, dynamic>)
          : null,
      errorMessage: json['error'] as String?,
    );
  }

  factory DesignResponse.error(String message) {
    return DesignResponse(
      success: false,
      requestId: '',
      errorMessage: message,
    );
  }
}

/// File URLs returned from design submission.
class DesignFiles {
  /// URL to download the preview PDF.
  final String? previewPdf;

  /// URL to download the detailed PDF.
  final String? detailedPdf;

  const DesignFiles({
    this.previewPdf,
    this.detailedPdf,
  });

  factory DesignFiles.fromJson(Map<String, dynamic> json) {
    return DesignFiles(
      previewPdf: json['preview_pdf'] as String?,
      detailedPdf: json['detailed_pdf'] as String?,
    );
  }
}

/// Status of a design request.
class DesignStatus {
  /// Current status of the request.
  final String status;

  /// Progress percentage (0-100).
  final int? progress;

  /// Error message if the request failed.
  final String? errorMessage;

  /// Available files when complete.
  final DesignFiles? files;

  const DesignStatus({
    required this.status,
    this.progress,
    this.errorMessage,
    this.files,
  });

  factory DesignStatus.fromJson(Map<String, dynamic> json) {
    return DesignStatus(
      status: json['status'] as String? ?? 'unknown',
      progress: json['progress'] as int?,
      errorMessage: json['error'] as String?,
      files: json['files'] != null
          ? DesignFiles.fromJson(json['files'] as Map<String, dynamic>)
          : null,
    );
  }

  factory DesignStatus.error(String message) {
    return DesignStatus(
      status: 'error',
      errorMessage: message,
    );
  }

  /// Whether the design is complete.
  bool get isComplete => status == 'complete' || status == 'completed';

  /// Whether the design is still processing.
  bool get isProcessing => status == 'processing' || status == 'pending';

  /// Whether the design failed.
  bool get isFailed => status == 'error' || status == 'failed';
}

/// HTTP client for communicating with the rwcpp server.
///
/// Handles all API calls including design submission, status checks,
/// and file downloads.
class ApiClient {
  /// HTTP client instance.
  final http.Client _client;

  /// Base URL for the API.
  final String baseUrl;

  /// Creates an API client with optional custom HTTP client and base URL.
  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// Submits a wall design to the server for processing.
  ///
  /// [wallInput] should be a JSON-serializable map matching the
  /// RetainingWallInput schema.
  ///
  /// Returns a [DesignResponse] with the request ID and initial status.
  Future<DesignResponse> submitDesign(Map<String, dynamic> wallInput) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.designEndpoint}');
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(wallInput),
          )
          .timeout(Duration(seconds: ApiConstants.timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return DesignResponse.fromJson(json);
      } else {
        return DesignResponse.error(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return DesignResponse.error('Failed to submit design: $e');
    }
  }

  /// Checks the status of a design request.
  ///
  /// [requestId] is the unique identifier returned from [submitDesign].
  Future<DesignStatus> checkStatus(String requestId) async {
    try {
      final uri = Uri.parse(
        '$baseUrl${ApiConstants.statusEndpoint}/$requestId',
      );
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: ApiConstants.timeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return DesignStatus.fromJson(json);
      } else {
        return DesignStatus.error(
          'Server returned status ${response.statusCode}',
        );
      }
    } catch (e) {
      return DesignStatus.error('Failed to check status: $e');
    }
  }

  /// Gets the full URL for downloading a file.
  ///
  /// [requestId] is the unique identifier for the design request.
  /// [filename] is the name of the file to download.
  String getFileUrl(String requestId, String filename) {
    return '$baseUrl${ApiConstants.filesEndpoint}/$requestId/$filename';
  }

  /// Checks if the API server is healthy.
  ///
  /// Returns true if the server responds with a 200 status.
  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.healthEndpoint}');
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Downloads a file from the server.
  ///
  /// Returns the raw bytes of the file, or null if the download failed.
  Future<List<int>?> downloadFile(String requestId, String filename) async {
    try {
      final uri = Uri.parse(getFileUrl(requestId, filename));
      final response = await _client.get(uri).timeout(
            Duration(seconds: ApiConstants.timeoutSeconds * 2),
          );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Closes the HTTP client and releases resources.
  void dispose() {
    _client.close();
  }
}
