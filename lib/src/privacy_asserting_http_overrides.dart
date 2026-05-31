// lib/src/privacy_asserting_http_overrides.dart
//
// PRIVACY REGRESSION TEST HELPER — TechSpec §10
// "The privacy test is the most important test in this codebase.
//  A regression that introduces a network call is a P0."
//
// Extracted from the main app's integration_test/privacy_no_network_test.dart
// so the helper itself is part of the public audit artifact. The
// integration test stays in the main app and imports this class via
// `package:sumaflow_minutes_privacy_core/testing.dart`.

import 'dart:io';

/// An [HttpOverrides] that throws the moment any code attempts to create an
/// [HttpClient]. Install it as `HttpOverrides.global` before booting the app
/// in an integration test; any outbound network attempt then surfaces as a
/// test failure with a stack trace pointing at the offending code.
///
/// It is meant to guard the scenarios where SumaFlow Minutes expects ZERO
/// network activity — app boot, idle, and the core record → transcribe →
/// minutes → export flow. A correctly behaving build never trips it under
/// those scenarios.
///
/// It is deliberately NOT installed around the one flow that legitimately
/// uses the network: the opt-in, Wi-Fi-only, SHA256-verified model download
/// from huggingface.co (the Gemma 4 E2B minutes model — TechSpec §5.3 — and
/// the optional Whisper "small.en" model — TechSpec §4.4). That download is
/// explicitly user-initiated, host-pinned, and disclosed in the privacy
/// whitepaper; it is exercised by its own download tests, not under this
/// override. Inference itself runs entirely on-device and never reaches here.
class PrivacyAssertingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw StateError(
      'PRIVACY VIOLATION: SumaFlow Minutes attempted to create an HttpClient '
      'in a scenario that must produce zero network calls. The only allowed '
      'outbound flow is the opt-in, Wi-Fi-only, SHA256-verified model '
      'download from huggingface.co, which is not exercised under this '
      'override. Find the offending code and remove it.',
    );
  }
}
