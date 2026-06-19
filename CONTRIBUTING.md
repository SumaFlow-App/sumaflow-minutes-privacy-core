# Contributing

Thank you for looking at the SumaFlow Minutes privacy core. This package is
small on purpose: it holds only the privacy-critical modules of SumaFlow
Minutes, open-sourced so the privacy contract (PRD §5) can be verified
independently of the main app.

## Scope

We keep this package limited to code whose correctness backs a privacy promise
— at-rest encryption, key management, the secure-storage backend configuration,
the foreground-service bridge, and the no-network test harness. Code that does
not back a privacy promise (UI, business logic, the on-device minutes engine)
lives in the main app and will not be accepted here.

## Mirrored files

Some files in this repository are **verbatim audit mirrors** of code that ships
in the private main app (see [`MIRROR.md`](MIRROR.md)). A change to a mirrored
file must originate in the main app and be re-synced here — a divergent edit
here would make the mirror lie. `MIRROR.md` lists which files are mirrors.

## Development

```sh
flutter pub get
flutter analyze
flutter test
```

To work on this package alongside the main app, clone it as a sibling and
temporarily switch the app's `pubspec.yaml` entry to a `path:` dependency (see
the README). Restore the pinned git `ref:` before committing the app.

## Pull requests

- Keep changes focused, and explain the privacy rationale.
- `flutter analyze` and `flutter test` must pass.
- Do not add a dependency that makes network calls, collects analytics, or
  reports crashes off-device. The manifest/pubspec assertions in
  `privacy_manifest_tests.dart` reject known-telemetry packages.

## Security issues

Do not open a public issue for a security problem — see [`SECURITY.md`](SECURITY.md).
