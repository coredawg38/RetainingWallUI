/// Stub file download for non-web platforms.
library;

import 'dart:typed_data';

bool downloadBytes(
  Uint8List bytes,
  String filename, {
  String mimeType = 'application/octet-stream',
}) =>
    false;
