# MIRROR.md — the duplicated Kotlin file

## What is mirrored

`android/src/main/kotlin/app/sumaflow/minutes/recording/RecordingForegroundService.kt`
in this repo is a **verbatim copy** of the file that actually runs in the
main SumaFlow Minutes app:

`android/app/src/main/kotlin/app/sumaflow/minutes/recording/RecordingForegroundService.kt`
in `SumaFlow-App/sumaflow_minutes` (private).

(The Android package was renamed `app.sumaflow.sumaflow_minutes` →
`app.sumaflow.minutes`; both the directory path and the `package` line in
the mirror were re-synced to match. A `diff` of the two paths produces no
output.)

## Why it is duplicated

The `RecordingForegroundService` is privacy-critical: it is the Android
component that keeps the microphone alive while a meeting records. Auditors
of the privacy contract (PRD §5) need to read it, so it has to be in this
public repo.

But the class is compiled and registered by the main app's Gradle build
and `MainActivity` — it is not a standalone library here. This package is a
Dart package, not a Flutter plugin, so the Kotlin in this repo is **not
built or shipped from here**. It exists only as an audit artifact.

The copy in this repo therefore sits under `android/src/main/kotlin/...`
purely so the path matches the main app for easy diffing — nothing in this
package's `pubspec.yaml` references it.

## The honest smell

A privacy-critical file living in two places is a smell. If the main app's
copy changes and this one does not, the audit artifact silently goes stale.

The cleaner architecture is a Flutter plugin that ships the Kotlin in its
own AAR, so there is exactly one copy. That was deliberately deferred:
plugin packaging is 1–2 days of yak shaving that does not move the
user-facing product forward (Week 2 Day 0 setup note). Revisit in Week 6
when there is slack.

## How to keep the mirror honest until then

When you touch `RecordingForegroundService.kt` in the main app:

1. Copy the new content here, verbatim, in the same commit's sibling PR.
2. The two files must be byte-identical. A `diff` of the two paths should
   produce no output.
3. If you cannot keep them in sync, delete this file rather than leave a
   stale audit artifact — a missing mirror is honest; a wrong one is not.
