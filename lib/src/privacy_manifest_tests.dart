// lib/src/privacy_manifest_tests.dart
//
// PRIVACY MANIFEST REGRESSION TEST — TechSpec §8.1
// "INTERNET permission intentionally absent — share intents do not
//  require it. If a future feature genuinely needs INTERNET, document
//  why in this manifest."
//
// Relocated from the main app's test/privacy_manifest_test.dart and
// parameterized so it runs against any consumer's manifest + pubspec.
// The main app keeps a thin test/ wrapper that calls privacyManifestTests()
// with its real paths; this package's own test/ runs it against fixtures.
//
// These assertions fail if any dependency or code change adds the INTERNET
// permission to the merged Android manifest, pulls in a known-telemetry
// package, or re-enables cleartext traffic. They run on every commit as
// part of `flutter test`.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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
}) {
  group('PRIVACY: Android manifest', () {
    test('INTERNET permission must NOT be declared', () {
      final manifest = File(manifestPath).readAsStringSync();

      final hasInternetPermission = manifest.contains(
        'android.permission.INTERNET',
      );

      expect(
        hasInternetPermission,
        isFalse,
        reason:
            'PRIVACY VIOLATION: $manifestPath '
            'declares the INTERNET permission. SumaFlow Minutes\'s privacy '
            'contract (PRD §5) requires zero outbound network calls from '
            'the core app. Share/export uses Android intents which do not '
            'require this permission. If a feature genuinely needs INTERNET, '
            'this test must be updated and the privacy whitepaper revised '
            'to disclose the change.',
      );
    });

    test('Manifest declares expected microphone-related permissions only', () {
      final manifest = File(manifestPath).readAsStringSync();

      // Required for recording
      expect(manifest.contains('RECORD_AUDIO'), isTrue,
          reason: 'RECORD_AUDIO permission is required for the core flow.');
      expect(manifest.contains('FOREGROUND_SERVICE_MICROPHONE'), isTrue,
          reason: 'FOREGROUND_SERVICE_MICROPHONE required on Android 14+.');

      // Must NOT be present
      const forbiddenPermissions = [
        'INTERNET',
        'ACCESS_NETWORK_STATE',
        'ACCESS_WIFI_STATE',
        'READ_CONTACTS',
        'READ_CALENDAR',
        'CAMERA',
        'ACCESS_FINE_LOCATION',
        'ACCESS_COARSE_LOCATION',
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
