# SumaFlow Minutes — Privacy Core

> Private AI minutes of meeting — on-device, no cloud.

Privacy-critical modules of SumaFlow Minutes, open-sourced under MIT
so the privacy contract is verifiable independently of the main app.

## What's in here

- **`lib/src/foreground_service_bridge.dart`** — the Dart side of the
  recording foreground service. Demonstrates that the platform channel
  surface has only `start` and `stop` methods — no data channel.
- **`lib/src/privacy_manifest_tests.dart`** — the static test that fails
  CI if a forbidden permission (contacts, calendar, camera, location,
  phone, SMS, …), a known-telemetry package, or cleartext traffic ever
  appears in a SumaFlow Minutes build — and that fails if the `INTERNET`
  permission is ever declared **without** its documented model-download
  rationale (see [Network posture](#network-posture) below). Parameterized
  so it runs against any consuming app's manifest and pubspec.
- **`lib/src/privacy_asserting_http_overrides.dart`** — an `HttpOverrides`
  that throws on any outbound HTTP attempt, installed by the main app's
  integration test to assert zero network calls during the scenarios that
  must produce none (boot, idle, and the core record → minutes flow).
- **`android/src/main/kotlin/...RecordingForegroundService.kt`** —
  audit mirror of the foreground service running in the main app.
  See [`MIRROR.md`](MIRROR.md) for the relationship.

The runtime module is exported from `sumaflow_minutes_privacy_core.dart`;
the test-only helpers are exported from `testing.dart` so production
builds never pull in `flutter_test`.

## What's NOT in here

The full main app — `SumaFlow-App/sumaflow_minutes` is private because
non-privacy-critical code (UI, business logic, the on-device minutes
engine) doesn't need to be public. The modules that touch audio,
storage, network, or device permissions live here.

## Network posture

SumaFlow Minutes performs **zero outbound network calls during normal
operation** — record → transcribe → minutes → export all run entirely
on-device, and minutes/transcription inference never touches the network.

There is exactly **one** network flow, and it is the reason the manifest
declares `INTERNET` and `ACCESS_NETWORK_STATE`:

- An **opt-in, Wi-Fi-only, SHA256-verified** model download from
  `huggingface.co` — the Gemma 4 E2B minutes model (TechSpec §5.3) and the
  optional Whisper `small.en` model (TechSpec §4.4). Each file is verified
  against a pinned HuggingFace commit; no other host is ever contacted.

(An earlier release of this package forbade `INTERNET` outright. That was
correct until the v1 on-device-model engine landed on 2026-05-16; the
assertions below now encode the gated-download contract the app actually
ships, rather than a posture it no longer holds.)

## How the contract is verified

Read `lib/src/privacy_manifest_tests.dart`. The assertions there are the
machine-checkable encoding of the SumaFlow Minutes privacy contract:

- `INTERNET`, if declared, must carry its documented model-download
  rationale in the manifest — a bare, unexplained declaration fails CI
- No forbidden permission (contacts, calendar, camera, location, phone,
  SMS, wifi-state, …) in the merged Android manifest
- No telemetry packages in `pubspec.yaml`
- `usesCleartextTraffic="false"` declared

The main app additionally enforces, in `integration_test/`, that no
network call occurs during boot, idle, and the core record → minutes flow
(via `PrivacyAssertingHttpOverrides`). These run on every commit in the
main repo's CI. This package's own `test/privacy_manifest_test.dart` runs
the same manifest/pubspec assertions against the compliant fixtures in
`test/fixtures/`.

## How the main app consumes this

The main app pins this package by a **git `ref`** (a specific commit),
not a path dependency or a published pub.dev package. Pinning by commit
keeps CI and fresh clones reproducible with no sibling-checkout setup, and
makes the exact audited privacy code explicit in `pubspec.yaml`:

```yaml
dependencies:
  sumaflow_minutes_privacy_core:
    git:
      url: https://github.com/SumaFlow-App/sumaflow-minutes-privacy-core.git
      ref: <commit-sha>   # bump deliberately when privacy-core changes
```

To work on both repos at once, clone this one as a sibling and temporarily
switch the `pubspec.yaml` entry to a `path:` dependency:

```
C:\SumaFlow\
  ├─ sumaflow_minutes\               (main app, private)
  └─ sumaflow-minutes-privacy-core\  (this repo)
```

We'll switch to a published pub package later only if the privacy-core
gets external contributors.

## License

MIT. See [LICENSE](LICENSE).
