// lib/src/privacy_manifest_tests.dart
//
// PRIVACY MANIFEST REGRESSION TEST — TechSpec §8.1, §10
//
// Relocated from the main app's test/privacy_manifest_test.dart and
// parameterized so it runs against any consumer's manifest + pubspec.
// The main app keeps a thin test/ wrapper that calls privacyManifestTests()
// with its real paths; this package's own test/ runs it against fixtures.
//
// NETWORK POSTURE — the honest, current contract (PRD §5, TechSpec §5.3/§4.4):
//
//   SumaFlow Minutes performs ZERO outbound network calls during normal
//   operation: record → transcribe → minutes → export all run entirely
//   on-device. The ONE exception is an opt-in, Wi-Fi-only, SHA256-verified
//   model download from huggingface.co — the Gemma 4 E2B minutes model
//   (TechSpec §5.3) and the optional Whisper "small.en" model (TechSpec
//   §4.4). The download is the reason the manifest declares INTERNET and
//   ACCESS_NETWORK_STATE; inference itself never touches the network.
//
// These assertions therefore DO NOT forbid INTERNET outright (an earlier
// release did, before the v1 on-device-model engine landed on 2026-05-16).
// They enforce the contract as it actually ships:
//
//   - INTERNET, if declared, must carry a documented rationale in the
//     manifest — a bare, unexplained declaration is a regression.
//   - No genuinely-forbidden permission (contacts, calendar, camera,
//     location, phone, SMS, wifi-state, …) ever appears.
//   - No known-telemetry package is in the dependency list.
//   - Cleartext traffic stays disabled.
//
// They run on every commit as part of `flutter test`.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Default substrings that prove the INTERNET permission's rationale is
/// documented in the manifest. The SumaFlow Minutes manifest wraps its
/// INTERNET / ACCESS_NETWORK_STATE declarations in a comment explaining the
/// opt-in model-download split; matching any of these confirms the rationale
/// is present rather than a bare declaration. Consumers with a different
/// rationale can override [internetRationaleMarkers].
const List<String> kDefaultInternetRationaleMarkers = <String>[
  'Gemma 4 E2B model download',
  'TechSpec §5.3',
];

/// Registers the SumaFlow Minutes privacy-manifest regression tests against
/// a specific consumer's Android manifest and pubspec.
///
/// Call this from a `test/` file in any app that depends on
/// `sumaflow_minutes_privacy_core`:
///
/// ```dart
/// import 'package:sumaflow_minutes_privacy_core/testing.dart';
///
/// void main() => privacyManifestTests(
///       manifestPath: 'android/app/src/main/AndroidManifest.xml',
///       pubspecPath: 'pubspec.yaml',
///     );
/// ```
void privacyManifestTests({
  required String manifestPath,
  required String pubspecPath,
  List<String> internetRationaleMarkers = kDefaultInternetRationaleMarkers,
}) {
  group('PRIVACY: Android manifest', () {
    test('Required microphone-related permissions are declared', () {
      final manifest = File(manifestPath).readAsStringSync();
      expect(manifest.contains('RECORD_AUDIO'), isTrue,
          reason: 'RECORD_AUDIO permission is required for the core flow.');
      expect(manifest.contains('FOREGROUND_SERVICE_MICROPHONE'), isTrue,
          reason: 'FOREGROUND_SERVICE_MICROPHONE required on Android 14+.');
    });

    test('Only the model-download network permissions may be present', () {
      final manifest = File(manifestPath).readAsStringSync();
      // INTERNET + ACCESS_NETWORK_STATE are intentionally ALLOWED — they
      // gate the opt-in, Wi-Fi-only, SHA256-verified model download from
      // huggingface.co (see the network-posture note at the top of this
      // file). Everything else network/sensor-adjacent must stay out.
      const forbiddenPermissions = [
        'ACCESS_WIFI_STATE',
        'CHANGE_WIFI_STATE',
        'CHANGE_NETWORK_STATE',
        'READ_CONTACTS',
        'WRITE_CONTACTS',
        'READ_CALENDAR',
        'WRITE_CALENDAR',
        'CAMERA',
        'ACCESS_FINE_LOCATION',
        'ACCESS_COARSE_LOCATION',
        'ACCESS_BACKGROUND_LOCATION',
        'READ_PHONE_STATE',
        'READ_SMS',
      ];
      for (final permission in forbiddenPermissions) {
        expect(
          manifest.contains('android.permission.$permission'),
          isFalse,
          reason:
              'PRIVACY VIOLATION: $permission appeared in $manifestPath. '
              'SumaFlow Minutes v1 does not require this permission. '
              'If you are adding it, update the privacy policy at '
              'sumaflow.app/minutes/privacy and the architecture page at '
              'sumaflow.app/minutes/privacy-architecture FIRST.',
        );
      }
    });

    test('INTERNET permission, if declared, has its rationale documented', () {
      // INTERNET is allowed but only with a comment explaining why; a bare
      // declaration is a regression. The SumaFlow Minutes manifest wraps it
      // in the opt-in model-download rationale block.
      final manifest = File(manifestPath).readAsStringSync();
      if (!manifest.contains('android.permission.INTERNET')) return;
      final hasRationale = internetRationaleMarkers.any(manifest.contains);
      expect(
        hasRationale,
        isTrue,
        reason:
            'INTERNET permission is declared in $manifestPath but its '
            'rationale is not documented. Add a comment explaining the '
            'on-device-inference / opt-in-download split (and disclose it in '
            'the privacy whitepaper at sumaflow.app/minutes/privacy) before '
            'merging.',
      );
    });

    test('Manifest declares usesCleartextTraffic="false"', () {
      final manifest = File(manifestPath).readAsStringSync();
      expect(
        manifest.contains('android:usesCleartextTraffic="false"'),
        isTrue,
        reason: 'Cleartext traffic must be disabled (TechSpec §8.1).',
      );
    });
  });

  group('PRIVACY: pubspec dependencies', () {
    test('No known-telemetry packages in dependencies', () {
      final pubspec = File(pubspecPath).readAsStringSync();

      const knownTelemetryPackages = [
        'firebase_analytics',
        'firebase_crashlytics',
        'mixpanel_flutter',
        'amplitude_flutter',
        'sentry_flutter',
        'segment_analytics_flutter',
        'posthog_flutter',
        'google_analytics',
        'facebook_app_events',
      ];

      for (final package in knownTelemetryPackages) {
        expect(
          pubspec.contains(package),
          isFalse,
          reason:
              'PRIVACY VIOLATION: $package is a known-telemetry package '
              'found in $pubspecPath. CLAUDE.md and PRD §5 prohibit '
              'third-party SDKs that phone home.',
        );
      }
    });
  });
}
