// lib/src/storage/secure_storage.dart
//
// Single source of truth for the flutter_secure_storage Android backend.
// EVERY FlutterSecureStorage instance in the consuming app MUST use these
// options so that all keys live in the same Keystore-backed
// EncryptedSharedPreferences bucket and behave identically across OEM quirks
// (TechSpec §6.2).
//
// History / why this exists: the settings instances were briefly built with
// a bare `const FlutterSecureStorage()`. Its AndroidOptions default to
// `encryptedSharedPreferences: false` — the *legacy* keystore-wrapped
// backend — while the master key, onboarding flag, and SQLCipher key all
// used `encryptedSharedPreferences: true`. On some OEMs the legacy backend
// fails to decrypt its values back after an app restart, so every setting
// read returned null and silently reverted to its default. Centralising the
// options here removes the per-call-site copy that let the two diverge.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AndroidOptions shared by every secure-storage instance in the app.
/// `const` so it slots straight into `const FlutterSecureStorage(...)`.
const AndroidOptions kAppAndroidSecureStorageOptions = AndroidOptions(
  encryptedSharedPreferences: true,
  // StrongBox where available per TechSpec §6.2.
  keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
  storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
);

/// The app-wide secure storage instance. Const-constructible so headless
/// isolates (which have no Riverpod scope) can build the identical store.
const FlutterSecureStorage appSecureStorage = FlutterSecureStorage(
  aOptions: kAppAndroidSecureStorageOptions,
);
