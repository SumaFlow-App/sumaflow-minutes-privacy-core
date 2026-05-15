// lib/sumaflow_minutes_privacy_core.dart
//
// Runtime entry point for SumaFlow Minutes — Privacy Core.
//
// This barrel exports the privacy-critical *runtime* modules consumed by
// the main app. Test-only helpers (the manifest regression test and the
// network-asserting HttpOverrides) live behind the separate `testing.dart`
// entry point so production builds never pull in flutter_test.

export 'src/foreground_service_bridge.dart';
