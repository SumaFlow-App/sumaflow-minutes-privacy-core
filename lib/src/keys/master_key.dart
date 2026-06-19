// lib/src/keys/master_key.dart
//
// TechSpec §6.2 + §7 — single master key per install, generated on first
// launch, stored in Android Keystore via flutter_secure_storage.
// All other keys (audio file encryption, SQLCipher DB key) are derived
// from this master via HKDF to keep concerns separated.

import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/secure_storage.dart';

final masterKeyManagerProvider = Provider<MasterKeyManager>(
  (ref) => MasterKeyManager(appSecureStorage),
);

class MasterKeyManager {
  MasterKeyManager(this._storage);
  final FlutterSecureStorage _storage;

  /// Secure-storage key under which the persisted master key lives.
  /// Exposed for tests that pre-seed a deterministic key into a mock store.
  @visibleForTesting
  static const masterKeyStorageKey = 'sumaflow_master_key_v1';

  /// Returns the 32-byte master key, generating it on first call.
  /// The key never leaves the device's Keystore-backed storage.
  Future<SecretKey> getOrCreate() async {
    final existing = await _storage.read(key: masterKeyStorageKey);
    if (existing != null) {
      return SecretKey(base64Decode(existing));
    }
    // VERIFY (TechSpec §12 / Week2 §1.2): the spec sketched a hand-rolled
    // `_generate32Bytes` that abused the nonce generator. The current
    // `cryptography` (2.9.0) idiom is to let the algorithm mint the key:
    // `AesGcm.with256bits().newSecretKey()` draws 256 bits from the
    // platform CSPRNG — never `dart:math` Random, which is not secure.
    final key = await AesGcm.with256bits().newSecretKey();
    final keyBytes = await key.extractBytes();
    await _storage.write(
      key: masterKeyStorageKey,
      value: base64Encode(keyBytes),
    );
    return key;
  }

  /// Overwrites the persisted master key with [keyBytes] (32 bytes from a
  /// backup's unwrapped wrappedMasterKey). Used ONLY by the restore apply-step,
  /// which runs in `main()` before the DB is opened or any subkey is derived, so
  /// the restored SQLCipher DB + audio decrypt under the backup's master key.
  /// Idempotent: re-running with the same bytes is a no-op write, which keeps
  /// the crash-safe re-apply path (PRD §14A.2 device migration) correct.
  Future<void> restoreMasterKey(List<int> keyBytes) async {
    await _storage.write(
      key: masterKeyStorageKey,
      value: base64Encode(keyBytes),
    );
  }

  /// Derives a purpose-specific subkey via HKDF-SHA256.
  /// Use 'audio-aead-v1' for file encryption, 'sqlcipher-v1' for the DB key.
  Future<SecretKey> deriveSubkey({required String purpose}) async {
    final master = await getOrCreate();
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    return hkdf.deriveKey(
      secretKey: master,
      info: utf8.encode(purpose),
      // RFC 5869 §2.2 — when no salt is provided, HKDF uses "a string of
      // HashLen zeros". The pure-Dart `cryptography` package resolves an
      // empty `nonce` to that fallback internally, so host unit tests
      // (which never load the platform delegate) passed with `const []`.
      // On a real device, `cryptography_flutter` registers as the default
      // HMAC impl app-wide, and its Android path feeds the salt straight
      // into `javax.crypto.spec.SecretKeySpec`, which throws
      // `IllegalArgumentException("Empty key")` on a zero-length array.
      // Encoding the fallback explicitly makes the derivation identical
      // whether HMAC runs in pure Dart or on the platform delegate.
      nonce: List<int>.filled(32, 0),
    );
  }
}
