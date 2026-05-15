// test/privacy_manifest_test.dart
//
// Runs the parameterized privacy-manifest regression suite against the
// fixture manifest + pubspec bundled in test/fixtures/. The fixtures
// represent a compliant consumer, so this proves the assertion logic
// passes clean inputs. The consuming app (sumaflow_minutes) runs the same
// privacyManifestTests() function against its real manifest + pubspec.

import 'package:sumaflow_minutes_privacy_core/testing.dart';

void main() => privacyManifestTests(
      manifestPath: 'test/fixtures/AndroidManifest.xml',
      pubspecPath: 'test/fixtures/pubspec.yaml',
    );
