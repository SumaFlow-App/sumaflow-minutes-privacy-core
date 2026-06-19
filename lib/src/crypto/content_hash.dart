// lib/src/crypto/content_hash.dart
//
// PRD §7.7 — every audit log row stores SHA-256(exported_payload).
// This is the *exported* payload, not the source data:
// after template rendering, just before the export intent fires.

import 'dart:convert';

import 'package:crypto/crypto.dart';

class ContentHash {
  /// SHA-256 of a UTF-8 string, returned as lowercase hex.
  static String ofString(String s) =>
      sha256.convert(utf8.encode(s)).toString();

  /// SHA-256 of arbitrary bytes (PDF buffers), returned as lowercase hex.
  static String ofBytes(List<int> bytes) =>
      sha256.convert(bytes).toString();
}
