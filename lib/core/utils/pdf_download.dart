/// PDF download helpers for triggering a browser file download.
library;

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'pdf_download_stub.dart'
    if (dart.library.js_interop) 'pdf_download_web.dart' as impl;

/// Triggers a download of [bytes] as [filename].
///
/// On web, creates an object URL and clicks a temporary anchor.
/// On other platforms, this is a no-op (returns false).
bool downloadPdfBytes(List<int> bytes, String filename) {
  if (!kIsWeb) {
    return false;
  }
  return impl.downloadPdfBytes(Uint8List.fromList(bytes), filename);
}
