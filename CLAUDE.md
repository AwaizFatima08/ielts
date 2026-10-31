# English Language Test Simulator (HomiLabs) — project notes

Flutter Android app: timed IELTS mock tests (Academic + General Training) and a practice library.
Package `ielts_simulator`, app id `com.homilabs.ielts_simulator`.

## Locations
- Code: `/mnt/storage/projects/ielts` · GitHub `AwaizFatima08/ielts` (public repo)
- Local backup: `/mnt/storage/project_backups/ielts_backup`
- Google Drive backup folder: https://drive.google.com/drive/folders/1tafV7aZYAUs3KEHcEyS7wq8rrUneUQPK

## Decisions (Homi, 29–30 Oct 2026)
- Both modules; Listening and Speaking shared, Reading and Writing per module.
- Listening audio: homidev Kokoro voices (`voice-en-standard`), one clip per script line.
  Until a clip exists the app waits a silent gap of estimated length and says audio is pending.
- Writing and Speaking: offline self-check against plain-English criteria (`assets/content/descriptors.json`)
  next to Band 8 model answers. No AI scoring, no backend.
- Delivery: engine + Test 1 first for review, then Tests 2–10 in the same style.

## Content
- All content is JSON under `assets/content/`, format in `docs/content-schema.md`. Content is original —
  never copy Cambridge/IDP/British Council material or quote the official band descriptors.
- `flutter test test/content` validates every paper (numbering 1–40, keys, word limits, answers present
  in the script/passage). Run it after any content change.
- A new test: add `assets/content/tests/tNN/` (6 files), list the folder and its audio folder in
  `pubspec.yaml`, set `"ready": true` in `tests/index.json`.

## Listening audio (homidev)
- `python3 tool/homidev_voice_inputs.py tNN` writes one `inputs.json` per clip to `build/homidev_inputs/tNN/`.
- Follow the homidev workflow (ask Homi first, batches of ≤5, review sheet, Homi approves each clip).
- Approved clips go to `assets/audio/tNN/listening/<clip-id>.ogg`; practice drill clips to
  `assets/audio/practice/<unit-id>/<clip-id>.ogg` (declare the folder in pubspec).

## Gate before commit
```
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
