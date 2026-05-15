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
/// The SumaFlow Minutes privacy contract (PRD §5) forbids outbound network
/// calls except user-initiated export intents — which do not go through
/// [HttpClient] — so a correctly behaving build never trips this.
class PrivacyAssertingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw StateError(
      'PRIVACY VIOLATION: SumaFlow Minutes attempted to create an HttpClient. '
      'The privacy contract (PRD §5) forbids outbound network calls except '
      'user-initiated export intents. Find the offending code and remove it.',
    );
  }
}
