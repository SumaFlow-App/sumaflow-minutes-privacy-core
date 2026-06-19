# Security Policy

SumaFlow Minutes is built around a privacy contract: audio, transcripts, and
minutes stay on the user's device, and the app makes no outbound network calls
except a single opt-in, Wi-Fi-only, SHA256-verified model download. This
repository holds the privacy-critical code that backs those claims, so we take
reports about it seriously.

## Reporting a vulnerability

Please report suspected vulnerabilities privately — **do not** open a public
issue for a security problem.

- Email: **security@sumaflow.app**
- Include: a description, the affected file(s) or behavior, reproduction steps
  or a proof of concept, and the version / commit SHA.
- If you would like to encrypt your report, say so in a first message and we
  will arrange a key.

## What to expect

- **Acknowledgement** within 3 business days.
- An initial assessment — a path to a fix, or an explanation if we conclude it
  is not a vulnerability — within 10 business days.
- We will keep you updated, and credit you in the release notes if (and only
  if) you would like.

We ask that you give us reasonable time to address an issue before any public
disclosure.

## Scope

In scope: the code in this package — the at-rest encryption, key management,
secure-storage configuration, the foreground-service bridge, and the no-network
test harness — and the privacy claims they back.

Out of scope: the private main application's non-privacy-critical code (UI,
business logic, the on-device minutes engine); third-party dependencies' own
vulnerabilities (report those upstream, and tell us if the app's *use* of them
is affected); and findings that require an already-compromised or rooted device
with the screen unlocked, which is documented as outside the threat model.

## No certification claims

This project describes what its architecture *does*; it makes no regulatory
certification claims. Reports are assessed on technical merit against the
privacy contract, not against any certification.
