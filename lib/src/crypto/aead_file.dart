// lib/src/crypto/aead_file.dart
//
// TechSpec §7 — AES-256-GCM file encryption.
// File format on disk: [12-byte nonce][16-byte MAC][ciphertext]
//
// For 90-minute recordings the AAC file is ~50 MB. Loading the whole
// thing into RAM during encryption is acceptable on modern Android
// (peak +50 MB is dwarfed by Whisper's ~1 GB peak in Week 2). We use
// AesGcm from the `cryptography` package, delegated to platform-native
// crypto via `cryptography_flutter` for performance.

import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../keys/master_key.dart';

final aeadFileServiceProvider = Provider<AeadFileService>((ref) {
  return AeadFileService(ref.watch(masterKeyManagerProvider));
});

class AeadFileService {
  AeadFileService(this._keys);
  final MasterKeyManager _keys;

  static const _purpose = 'audio-aead-v1';

  // VERIFY (TechSpec §12 / Week2 §1.3): the spec sketched
  // `FlutterAesGcm.with256bits().toAesGcm()`, but cryptography_flutter
  // 2.3.4 has no `toAesGcm()`. `FlutterAesGcm` already *is* an `AesGcm`
  // and transparently falls back to the pure-Dart implementation when
  // platform APIs are unavailable (e.g. the Flutter test host), so we
  // use it directly.
  late final AesGcm _algorithm = FlutterAesGcm.with256bits();

  /// Encrypts [plaintext] and writes it to [outFile].
  /// Overwrites [outFile] if it exists.
  Future<void> encryptToFile(Uint8List plaintext, File outFile) async {
    final key = await _keys.deriveSubkey(purpose: _purpose);
    final nonce = _algorithm.newNonce();
    final box = await _algorithm.encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
    );
    final bytes = BytesBuilder(copy: false)
      ..add(nonce)
      ..add(box.mac.bytes)
      ..add(box.cipherText);
    await outFile.writeAsBytes(bytes.takeBytes(), flush: true);
  }

  /// Decrypts [inFile] and returns the plaintext bytes.
  /// Throws [SecretBoxAuthenticationError] on MAC mismatch (tampering or
  /// wrong key — both indistinguishable from the AEAD).
  Future<Uint8List> decryptFromFile(File inFile) async {
    final key = await _keys.deriveSubkey(purpose: _purpose);
    final raw = await inFile.readAsBytes();
    if (raw.length < 28) {
      throw const FormatException('Ciphertext file too short.');
    }
    final nonce = raw.sublist(0, 12);
    final mac = Mac(raw.sublist(12, 28));
    final cipherText = raw.sublist(28);
    final box = SecretBox(cipherText, nonce: nonce, mac: mac);
    final clear = await _algorithm.decrypt(box, secretKey: key);
    return Uint8List.fromList(clear);
  }
}
