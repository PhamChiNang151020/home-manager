# Commit message examples (home_manager)

Patterns aligned with SuperApp Mobile / flutter_sdk_switcher bracket tags; tuned for Flutter Web PWA + `.cursor` docs.

## Well-formed subjects

```text
[FEATURE]: Add utilities screen for electricity and water readings
[FEATURE]: Persist expenses in Hive across reloads
[FIX]: Compress bill photos before writing to IndexedDB
[REFACTOR]: Move Hive access from widgets into StorageService
[BUILD]: Configure PWA manifest for Add to Home Screen
[BUILD]: Bump version to 0.1.1 in pubspec.yaml
[DOCS]: Document architecture and MVP roadmap under .cursor/docs
[CHORE]: Track .cursor rules and skills in git
[DOCS]: Update README with flutter run -d chrome
[FEATURE]: Shopping list with check-off and delete
[FIX]: Restore backup JSON without dropping existing shopping items (#3)
```

## Multi-topic (avoid in one local commit)

```text
[FEATURE]: Expenses UI [BUILD]: Bump version
```

Prefer two commits or one PR with a clear title.

## Weak subjects (do not copy)

```text
hello world
update
fix hive stuff
WIP
```

Rewrite as `[FIX]: …` or `[FEATURE]: …` with a clear outcome.

## Type decision cheatsheet

| Changed paths (typical) | Tag |
| --- | --- |
| `lib/features/**`, `lib/core/services/**` (behavior) | `[FEATURE]` / `[FIX]` / `[REFACTOR]` |
| `web/**`, PWA manifest, icons | `[BUILD]` or `[FEATURE]` if new capability; split version bump |
| `pubspec.yaml` version only | `[BUILD]` |
| `.cursor/**`, `README.md` | `[DOCS]` or `[CHORE]` |
| `analysis_options.yaml`, `.gitignore` | `[CHORE]` |
| `test/**` only | `[TEST]` |
