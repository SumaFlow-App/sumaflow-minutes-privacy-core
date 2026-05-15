# SumaFlow Minutes — Privacy Core

> Private AI minutes of meeting — on-device, no cloud.

Privacy-critical modules of SumaFlow Minutes, open-sourced under MIT
so the privacy contract is verifiable independently of the main app.

## What's in here

- **`lib/src/foreground_service_bridge.dart`** — the Dart side of the
  recording foreground service. Demonstrates that the platform channel
  surface has only `start` and `stop` methods — no data channel.
- **`lib/src/privacy_manifest_tests.dart`** — the static test that fails
  CI if the `INTERNET` permission, known-telemetry packages, or cleartext
  traffic ever appear in a SumaFlow Minutes build. Parameterized so it
  runs against any consuming app's manifest and pubspec.
- **`lib/src/privacy_asserting_http_overrides.dart`** — an `HttpOverrides`
  that throws on any outbound HTTP attempt, used by the main app's
  integration test to assert zero network calls at runtime.
- **`android/src/main/kotlin/...RecordingForegroundService.kt`** —
  audit mirror of the foreground service running in the main app.
  See [`MIRROR.md`](MIRROR.md) for the relationship.

The runtime module is exported from `sumaflow_minutes_privacy_core.dart`;
the test-only helpers are exported from `testing.dart` so production
builds never pull in `flutter_test`.

## What's NOT in here

The full main app — `SumaFlow-App/sumaflow_minutes` is private because
non-privacy-critical code (UI, business logic, future Gemini Nano
integration) doesn't need to be public. The modules that touch audio,
storage, network, or device permissions live here.

## How the contract is verified

Read `lib/src/privacy_manifest_tests.dart`. The assertions there are the
machine-checkable encoding of the SumaFlow Minutes privacy contract:

- No `INTERNET` permission in the merged Android manifest
- No telemetry packages in `pubspec.yaml`
- `usesCleartextTraffic="false"` declared

These run on every commit in the main repo's CI. This package's own
`test/privacy_manifest_test.dart` runs the same assertions against the
compliant fixtures in `test/fixtures/`.

## How the main app consumes this

For now this package is consumed as a **path dependency**, not a
published pub.dev package. Clone it as a sibling of the main app:

```
C:\SumaFlow\
  ├─ sumaflow_minutes\               (main app, private)
  └─ sumaflow-minutes-privacy-core\  (this repo)
```

```powershell
cd C:\SumaFlow
gh repo clone SumaFlow-App/sumaflow_minutes
gh repo clone SumaFlow-App/sumaflow-minutes-privacy-core
```

The main app's `pubspec.yaml` then references it:

```yaml
dependencies:
  sumaflow_minutes_privacy_core:
    path: ../sumaflow-minutes-privacy-core
```

We'll switch to a published pub package later only if the privacy-core
gets external contributors.

## License

MIT. See [LICENSE](LICENSE).
