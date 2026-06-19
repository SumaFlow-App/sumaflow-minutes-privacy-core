// lib/sumaflow_minutes_privacy_core.dart
//
// Runtime entry point for SumaFlow Minutes — Privacy Core.
//
// This barrel exports the privacy-critical *runtime* modules consumed by
// the main app. Test-only helpers (the manifest regression test and the
// network-asserting HttpOverrides) live behind the separate `testing.dart`
// entry point so production builds never pull in flutter_test.
//
// Modules:
//   crypto/   — AES-256-GCM at-rest file encryption + SHA-256 content hashing
//   keys/     — single-master-key generation + HKDF subkey derivation
//   storage/  — the shared flutter_secure_storage (Keystore) backend config

export 'src/crypto/aead_file.dart';
export 'src/crypto/content_hash.dart';
export 'src/foreground_service_bridge.dart';
export 'src/keys/master_key.dart';
export 'src/storage/secure_storage.dart';
