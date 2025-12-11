/// Wall Repository
///
/// Repository layer for handling wall design data operations.
/// Abstracts API calls and provides caching/offline support.
///
/// Usage:
/// ```dart
/// final repository = WallRepository(apiClient);
/// final response = await repository.submitDesign(input);
/// ```
library;

import '../../../../core/api/api_client.dart';
import '../models/retaining_wall_input.dart';

/// Repository for wall design operations.
class WallRepository {
  final ApiClient _apiClient;

  /// Cache for design responses.
  final Map<String, DesignResponse> _designCache = {};

  /// Cache for design status.
  final Map<String, DesignStatus> _statusCache = {};

  WallRepository(this._apiClient);

  /// Submits a wall design for processing.
  ///
  /// Returns a [DesignResponse] with the request ID and initial status.
  Future<DesignResponse> submitDesign(RetainingWallInput input) async {
    final response = await _apiClient.submitDesign(input.toJson());

    if (response.success) {
      _designCache[response.requestId] = response;
    }

    return response;
  }

  /// Gets the status of a design request.
  ///
  /// [requestId] is the unique identifier for the design.
  /// [forceRefresh] bypasses the cache and fetches fresh data.
  Future<DesignStatus> getDesignStatus(
    String requestId, {
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh && _statusCache.containsKey(requestId)) {
      final cached = _statusCache[requestId]!;
      if (cached.isComplete) {
        // Completed status doesn't change, return cached
        return cached;
      }
    }

    final status = await _apiClient.checkStatus(requestId);
    _statusCache[requestId] = status;
    return status;
  }

  /// Gets the URL for downloading a file.
  String getFileUrl(String requestId, String filename) {
    return _apiClient.getFileUrl(requestId, filename);
  }

  /// Gets the preview PDF URL for a design.
  String getPreviewPdfUrl(String requestId) {
    return getFileUrl(requestId, 'PreviewDrawing.pdf');
  }

  /// Gets the detailed PDF URL for a design.
  String getDetailedPdfUrl(String requestId) {
    return getFileUrl(requestId, 'DetailedDrawing.pdf');
  }

  /// Downloads the preview PDF bytes.
  Future<List<int>?> downloadPreviewPdf(String requestId) async {
    return _apiClient.downloadFile(requestId, 'PreviewDrawing.pdf');
  }

  /// Downloads the detailed PDF bytes.
  Future<List<int>?> downloadDetailedPdf(String requestId) async {
    return _apiClient.downloadFile(requestId, 'DetailedDrawing.pdf');
  }

  /// Checks if the API server is healthy.
  Future<bool> isServerHealthy() async {
    return _apiClient.healthCheck();
  }

  /// Gets a cached design response.
  DesignResponse? getCachedDesign(String requestId) {
    return _designCache[requestId];
  }

  /// Gets a cached status.
  DesignStatus? getCachedStatus(String requestId) {
    return _statusCache[requestId];
  }

  /// Clears all cached data.
  void clearCache() {
    _designCache.clear();
    _statusCache.clear();
  }

  /// Clears cached data for a specific request.
  void clearCacheForRequest(String requestId) {
    _designCache.remove(requestId);
    _statusCache.remove(requestId);
  }

  /// Disposes resources.
  void dispose() {
    clearCache();
    _apiClient.dispose();
  }
}
