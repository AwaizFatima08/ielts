# Release and hosting kit: English Language Test Simulator

## Build
- Package `com.homilabs.ielts_simulator` (locked after the first Play upload) · version 1.0.0 (versionCode 1).
- Bundle: `releases/v1.0.0-1/ielts-simulator-1.0.0-1.aab` (52.6 MB, signed with the upload key).
  SHA-256 of the file: `1592f542ce65012b09b326ad9bfff1a64b47a2c8736e266cff0c8baf24c5548f`.
- Rebuild: `flutter build appbundle --release`, then `./gradlew --stop` in `android/`. Signing reads
  `android/key.properties` → `.secrets/ielts-upload.keystore` (credentials in `.secrets/ielts-upload-keystore-credentials.txt`).
  Back up `.secrets/` (the local and Drive backups include it). Losing the upload key means a support request to Google.
- Upload key SHA-1: `3E:74:57:12:75:06:67:4A:52:65:FE:A7:20:ED:60:77:00:A6:09:84`.
- Next release: raise `version:` in `pubspec.yaml` (the build number must go up) and keep a folder under `releases/`.

## Website: https://ielts.homilabs.org (Hostinger, manual upload)
1. hPanel → Websites → homilabs.org → Domains → Subdomains → create `ielts`.
   Wait until it shows as active (DNS and SSL can take a few minutes).
2. File Manager → open the subdomain's folder → upload the **contents** of `website/` (or extract
   `releases/ielts-site-2026-11-01.zip` there), **including the hidden `.htaccess`**.
3. Flush the CDN cache (hPanel → homilabs.org → Performance → CDN → Flush cache).
4. Check https://ielts.homilabs.org/ , /privacy.html , /terms.html (and /privacy, /terms).
5. Add an entry for the app on homilabs.org (`homilabs_site`) once it is live.
After editing `website/`, re-upload and flush the cache again.

## Play Console
| Item | Value |
|---|---|
| App bundle | `releases/v1.0.0-1/ielts-simulator-1.0.0-1.aab` |
| App icon 512×512 | `store-assets/icon-512.png` |
| Privacy policy URL | https://ielts.homilabs.org/privacy.html |
| Website | https://ielts.homilabs.org |
| Contact email | homilabs.smc@gmail.com |
| Ads | **Yes** (Google AdMob: banner on Home/Practice/Results, one interstitial after a finished report) |
| App access | All functionality available without login |
| Data safety | Collected and shared: **Device or other IDs** (advertising ID) and **App activity/diagnostics via ads SDK**, purpose *Advertising or marketing*, shared with Google AdMob; encrypted in transit; not optional to share. Not collected: personal info, audio (recordings stay on the device), location beyond what the ads SDK derives from IP. Declare the Advertising ID permission use as *Advertising* |
| Content rating | Reference/educational; answer No to violence, sexuality, language, drugs, gambling, purchases, user interaction |
| Target audience | 13+ (an exam-prep app; do not choose under-13) |
| Category | Education |
| Track | Start with **Internal testing**, then Closed testing; a new personal developer account needs 12 testers for 14 days before production |

**App name** (Play allows 30 characters; "English Language Test Simulator" is 31, so the store title needs one shorter, e.g. `English Language Test Sim` is poor — prefer `Language Test Simulator` (23) or `English Test Simulator` (22). The app's own name on the phone is the full one.)

**Short description** (80 max): `IELTS-style mock tests with a real test-day timer, reports and practice drills.`

**Full description**:
```
Practise for the IELTS test the way it feels on the day. English Test Simulator gives you full-length IELTS-style mock tests with the real timings, estimated bands and a practice library that covers every part of the exam. Test 1 is ready now; more tests are on the way.

MOCK TESTS
• Listening: four parts, 40 questions, with reading time and two minutes at the end to check. Recordings are being added test by test; until a recording is ready the section runs on its timer without sound and the app says so.
• Reading: three passages, 40 questions, 60 minutes, with a question navigator and flagging.
• Writing: Task 1 and Task 2 in 60 minutes, with a live word count.
• Speaking: three parts, one minute of preparation for Part 2, and your answers recorded so you can play them back.
• Academic and General Training modules.

REPORT AND SELF-CHECK
• Estimated bands and every answer explained, with transcripts and passages.
• Writing and Speaking self-check against plain-English criteria, next to Band 8 model answers.
• Progress across your attempts.

PRACTICE LIBRARY
• Guides and drills for each question type, Writing and Speaking guides, and topic vocabulary.

PRIVATE AND OFFLINE
• Tests and lessons work offline; no account needed.
• Your Speaking recordings stay on your device.
• Free, with light ads (never during a test).

English Test Simulator is independent practice material by HomiLabs. It is not affiliated with or endorsed by IELTS, the British Council, IDP or Cambridge. Bands are estimates for practice, not official results. Writing and Speaking are self-checked, not marked by the app.
```

## AdMob
- Account homilabs.smc@gmail.com, app **English Language Test Simulator** — app ID `ca-app-pub-2087846699268567~7135036289`.
- Units: banner `ca-app-pub-2087846699268567/4129598992`, interstitial `ca-app-pub-2087846699268567/8911152384`. Debug builds use Google test units.
- The app shows "Limited ad serving" until the Play listing is live and linked: after publishing, AdMob → Apps → this app → Add store (com.homilabs.ielts_simulator).
- Consent: Google UMP form (configure the message under AdMob → Privacy & messaging if you want a custom EEA/UK message).

## Before production (open items)
- Listening audio is not generated yet: the app plays a silent timed gap and shows a notice. Do not go past internal
  testing until the voice approach is decided and the clips are in (see `CLAUDE.md`).
- Only Test 1 is ready; Tests 2–10 show "Coming soon".
- Store graphics still needed: feature graphic 1024×500 and phone screenshots (2–8). The icon is code-drawn and can be replaced.
- Trademark: the name no longer contains "IELTS", but the description, icon and website do. The disclaimer is on the website and in the description, but Play can still ask for
  proof of permission. A neutral name avoids this.
