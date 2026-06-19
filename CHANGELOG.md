## 0.1.0

Crypto layer + key management moved in from the main app (Week 8 Day 4) — the
at-rest encryption that backs PRD §5 promises 1–3 now lives in the auditable
package. Verbatim relocation: same algorithms, same on-disk AEAD format, same
key derivation and Keystore options, so existing encrypted data is unaffected.

* **`crypto/aead_file.dart`** — AES-256-GCM file encryption, on-disk format
  `[12-byte nonce][16-byte MAC][ciphertext]`, via `cryptography` +
  `cryptography_flutter` (native delegate).
* **`keys/master_key.dart`** — single per-install master key in Keystore-backed
  storage; all subkeys HKDF-derived (audio-file key, SQLCipher DB key).
* **`crypto/content_hash.dart`** — SHA-256 helper for the export audit log.
* **`storage/secure_storage.dart`** — shared `flutter_secure_storage`
  (`EncryptedSharedPreferences`) backend config; the single source of truth for
  the Keystore options, consumed by both the crypto layer and the app.
* New runtime deps: `cryptography`, `cryptography_flutter`,
  `flutter_secure_storage`, `crypto`. All exported via the runtime barrel.
* No network behaviour added — the package still makes zero network calls of
  its own.
* Repository scaffolding for the public launch: `SECURITY.md` (disclosures →
  security@sumaflow.app), `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`; the README
  now lists the crypto / keys / storage modules.

## 0.0.2

Factual sync with the shipping app (2026-05-31). The app's privacy posture
changed when the v1 on-device-model engine landed on 2026-05-16; this
release brings the public audit artifact back in line with what the app
actually does.

* **Network posture corrected.** `privacy_manifest_tests.dart` no longer
  forbids `INTERNET` outright. It now enforces the gated-download contract
  the app actually ships: `INTERNET` is allowed **only** with a documented
  model-download rationale in the manifest (opt-in, Wi-Fi-only,
  SHA256-verified download from `huggingface.co` — Gemma 4 E2B + optional
  Whisper `small.en`), while the genuinely-forbidden permissions, telemetry
  packages, and cleartext traffic remain hard failures. Adds an
  `internetRationaleMarkers` parameter (defaults to the SumaFlow markers).
* `test/fixtures/AndroidManifest.xml` now mirrors the main app's gated
  `INTERNET` + `ACCESS_NETWORK_STATE` block (with rationale), proving the
  rationale-detection path passes on a compliant input.
* `privacy_asserting_http_overrides.dart` — docs corrected: the helper
  guards the zero-network scenarios (boot, idle, core record → minutes
  flow); the opt-in model download is the one allowed flow and is not
  exercised under this override.
* `RecordingForegroundService.kt` mirror re-synced verbatim and moved to
  the renamed package path `app/sumaflow/minutes/recording/` (was
  `app/sumaflow/sumaflow_minutes/recording/`); also picks up the rebrand
  notification icon (`R.drawable.ic_notification`). See `MIRROR.md`.
* `README.md` — added a "Network posture" section; corrected the
  contract-verification bullets and the "how the main app consumes this"
  section (git `ref` pin, not a path dependency).

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
