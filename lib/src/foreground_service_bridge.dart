// lib/src/foreground_service_bridge.dart
//
// Relocated from the main app (sumaflow_minutes) into privacy-core so the
// platform-channel surface is part of the public audit artifact.
//
// TechSpec §3.3 — Kotlin foreground service controller.
// Without this, Android 12+ kills recording when screen locks.
//
// Audit note: the only methods this bridge exposes to native are `start`
// and `stop`. There is no data channel — the foreground service cannot
// exfiltrate audio or transcripts. The native counterpart is mirrored in
// android/src/main/kotlin/...RecordingForegroundService.kt (see MIRROR.md).

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foregroundServiceBridgeProvider = Provider<ForegroundServiceBridge>(
  (ref) => ForegroundServiceBridge(),
);

class ForegroundServiceBridge {
  static const _channel = MethodChannel('app.sumaflow.minutes/recording');

  Future<void> start() async {
    await _channel.invokeMethod<void>('startForegroundService');
  }

  Future<void> stop() async {
    await _channel.invokeMethod<void>('stopForegroundService');
  }
}
