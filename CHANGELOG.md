## 0.0.1

* Initial privacy-core scaffolding.
* `foreground_service_bridge.dart` — Dart side of the recording foreground
  service, relocated from the main app.
* `privacy_manifest_tests.dart` — parameterized manifest/pubspec privacy
  regression suite, relocated from the main app's `test/`.
* `privacy_asserting_http_overrides.dart` — network-asserting `HttpOverrides`
  helper extracted from the main app's integration test.
* `RecordingForegroundService.kt` — verbatim audit mirror of the main app's
  foreground service (see `MIRROR.md`).
