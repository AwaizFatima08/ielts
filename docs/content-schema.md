# IELTS Simulator — content schema (v1)

All exam and practice content is JSON under `assets/content/`. The app reads it; no content lives in Dart code.
All content is **original HomiLabs writing**. Never copy or closely paraphrase Cambridge / British Council / IDP
material, published practice tests or band descriptors.

```
assets/content/
  tests/index.json                 list of tests
  tests/t01/listening.json
  tests/t01/reading_academic.json
  tests/t01/reading_general.json
  tests/t01/writing_academic.json
  tests/t01/writing_general.json
  tests/t01/speaking.json
  practice/index.json              list of practice units
  practice/<unit-id>.json          one practice unit
  descriptors.json                 self-check criteria for Writing and Speaking
assets/audio/t01/listening/<clip-id>.ogg      homidev voice clips (one per script line)
assets/images/...                             SVG maps/plans/diagrams
```

## Question groups (shared by Listening, Reading and practice drills)

Question numbers run 1–40 across a whole Listening or Reading paper, with no gaps or repeats.
Every group has:

| field | required | meaning |
|---|---|---|
| `type` | yes | `gap`, `mcq`, `multi`, `tfng`, `matching` |
| `from`, `to` | yes | first and last question number in the group |
| `instructions` | yes | exactly as an IELTS paper would say it, e.g. "Complete the notes below." |
| `limit` | gap only | e.g. "ONE WORD AND/OR A NUMBER", "NO MORE THAN TWO WORDS" |
| `title` | no | heading above the group (form title, table title, summary title) |
| `image` | no | asset path of an SVG (map, plan, diagram) shown above the group |
| `explain` | yes | object `{ "<n>": "why this is the answer — quote the line of the script/passage" }` for every question |

### `gap` — form / note / table / sentence / summary / flow-chart completion, short answers, diagram labels
```json
{ "type": "gap", "from": 1, "to": 5, "layout": "form",
  "instructions": "Complete the form below.", "limit": "ONE WORD AND/OR A NUMBER",
  "title": "Riverside Sports Centre – Membership",
  "lines": ["Name: Daniel {{1}}", "Postcode: {{2}}", "Preferred activity: {{3}}"],
  "answers": { "1": ["Okafor"], "2": ["BH4 7QT", "BH47QT"], "3": ["swimming"] },
  "explain": { "1": "Man: 'It's Okafor, O-K-A-F-O-R.'" } }
```
- `layout`: `form`, `notes`, `sentences`, `summary`, `flowchart`, `table`, `short` (short-answer questions: one line per question, the question text then `{{n}}`).
- `lines` (all layouts except `table`): strings; a line starting with `# ` is a sub-heading, a line starting with `- ` is a bullet.
- `table` (layout `table` only): `{ "header": ["Course", "Day", "Cost"], "rows": [["Pottery", "{{6}}", "£40"]] }`.
- `{{n}}` marks the blank for question n. Each n from `from` to `to` appears exactly once.
- `answers`: every acceptable spelling/form (`["14", "fourteen"]`, `["colour", "color"]`). Each must respect `limit`.
- `options` (optional): word bank `[{ "key": "A", "text": "rising costs" }]`; then each answer is a key, e.g. `["C"]`.

### `mcq` — single-answer multiple choice
```json
{ "type": "mcq", "from": 11, "to": 13, "instructions": "Choose the correct letter, A, B or C.",
  "questions": [ { "n": 11, "stem": "Why did the club move?",
                   "options": [ {"key":"A","text":"..."}, {"key":"B","text":"..."}, {"key":"C","text":"..."} ],
                   "answer": "B" } ],
  "explain": { "11": "..." } }
```

### `multi` — choose TWO (or THREE) letters; each correct letter scores one mark, any order
```json
{ "type": "multi", "from": 21, "to": 22, "instructions": "Choose TWO letters, A–E.",
  "stem": "Which TWO problems with the survey do the students mention?",
  "options": [ {"key":"A","text":"..."}, ... five options ... ],
  "answers": ["B", "D"], "explain": { "21": "...", "22": "..." } }
```
`to - from + 1` must equal the number of `answers`.

### `tfng` — TRUE/FALSE/NOT GIVEN (facts) or YES/NO/NOT GIVEN (writer's views)
```json
{ "type": "tfng", "variant": "tfng", "from": 1, "to": 6,
  "instructions": "Do the following statements agree with the information given in Reading Passage 1?",
  "questions": [ { "n": 1, "text": "...", "answer": "NOT GIVEN" } ], "explain": { "1": "..." } }
```
`variant`: `tfng` (answers TRUE/FALSE/NOT GIVEN) or `ynng` (YES/NO/NOT GIVEN).

### `matching` — headings, information, features, sentence endings, map/plan labels
```json
{ "type": "matching", "from": 14, "to": 19, "instructions": "Reading Passage 2 has six paragraphs, A–F. Choose the correct heading for each paragraph from the list of headings below.",
  "optionsTitle": "List of Headings", "reuse": false,
  "options": [ {"key":"i","text":"..."}, {"key":"ii","text":"..."} ],
  "items": [ { "n": 14, "text": "Paragraph A", "answer": "iii" } ], "explain": { "14": "..." } }
```
- `reuse`: true when an option may be used more than once (add "You may use any letter more than once." to the instructions).
- Map/plan labelling: `image` = SVG with the letters drawn on it; options are the letters (text may be empty `""`).

## Listening — `tests/tNN/listening.json`
```json
{ "id": "t01", "section": "listening",
  "speakers": { "announcer": { "voice": "bm_george", "label": "Announcer" },
                "woman": { "voice": "bf_emma", "label": "Receptionist" } },
  "parts": [ { "number": 1, "context": "A man phones a sports centre to ask about membership.",
               "script": [ { "id": "p1_001", "speaker": "announcer", "text": "Part 1. You will hear ..." },
                           { "pause": 30, "note": "Look at questions 1 to 5" },
                           { "id": "p1_002", "speaker": "woman", "text": "Good morning, Riverside Sports Centre..." } ],
               "groups": [ ... ] } ] }
```
- 4 parts, 10 questions each, ~5–7 minutes of speech per part, rising difficulty. Part 1: everyday dialogue (2 speakers).
  Part 2: everyday monologue. Part 3: academic discussion (2–3 speakers). Part 4: university lecture (monologue).
- Real-test rhythm: announcer introduces each part, `pause` 20–30 s to read questions, the recording, then a pause
  before the next set of questions. Part 1 starts with a worked example. The audio is heard **once**.
- Each script line = one homidev voice clip, so keep lines to natural turns of speech (max ~70 words; split long
  monologues into paragraph-size lines). `id` = `p<part>_<3-digit seq>`, unique, in order.
- Voices available (Kokoro): `af_heart`, `af_bella` (US F), `am_michael` (US M), `bm_george` (UK M), `bf_emma` (UK F).
  Prefer UK voices; give speakers in the same conversation different voices.
- Include the classic distractors (speaker corrects themself, spells a name, changes a date, mentions two options
  then rejects one). Spell names letter by letter as text: "That's B-R-O-W-N-E".

## Reading — `tests/tNN/reading_academic.json` and `reading_general.json`
```json
{ "id": "t01", "section": "reading", "module": "academic",
  "passages": [ { "number": 1, "part": 1, "title": "...", "subtitle": "optional strapline",
                  "paragraphs": [ { "label": "A", "text": "..." } ],
                  "groups": [ ... ] } ] }
```
- Academic: 3 passages, 750–950 words each (rising difficulty), 13/13/14 questions. Label paragraphs A, B, C… only when a
  group refers to paragraph letters; otherwise `label` is `""`.
- General Training: Part 1 = 2–3 short everyday texts (notices, adverts, timetables); Part 2 = 2 work-related texts;
  Part 3 = one long general-interest text (700–850 words). Each text is its own entry in `passages` with `part` 1, 2 or 3.
  Spread 40 questions: ~14 / ~13 / ~13.
- Mix question types across a paper like the real test; every answer must be findable in the text.

## Writing — `tests/tNN/writing_academic.json` and `writing_general.json`
```json
{ "id": "t01", "section": "writing", "module": "academic",
  "tasks": [ { "number": 1, "minutes": 20, "minWords": 150,
               "prompt": "The chart below shows ...", "instructions": "Summarise the information by selecting and reporting the main features, and make comparisons where relevant.",
               "bullets": [], "chart": { ... }, "image": null,
               "modelAnswer": "...", "modelBand": 8, "tips": ["...", "..."] },
             { "number": 2, "minutes": 40, "minWords": 250, "prompt": "...", "instructions": "Give reasons for your answer and include any relevant examples from your own knowledge or experience.",
               "modelAnswer": "...", "modelBand": 8, "tips": [] } ] }
```
- Chart (Academic Task 1), drawn by the app:
  `{ "kind": "bar" | "line" | "pie" | "table", "title": "...", "xLabels": ["2000","2010"], "yLabel": "Percentage", "unit": "%",
     "series": [ { "name": "Cars", "values": [40, 52] } ] }` — pie: one series, labels = `xLabels`; table: columns = `xLabels`, one row per series.
- Process diagrams or maps: use `image` (SVG path) and `chart: null`.
- GT Task 1 is a letter: `prompt` = situation, `bullets` = the three bullet points, `instructions` = "Write at least 150 words. You do NOT need to write any addresses. Begin your letter as follows: Dear ...,".
- Model answers are original, clearly Band 8 level, Task 1 ≈ 170–190 words, Task 2 ≈ 270–300 words; paragraphs separated by `\n\n`.

## Speaking — `tests/tNN/speaking.json`
```json
{ "id": "t01", "section": "speaking",
  "part1": [ { "topic": "Work or studies", "questions": ["...", "..."] } ],
  "part2": { "cueCard": "Describe a ...", "bullets": ["what ...", "when ...", "who ..."], "closing": "and explain why ...",
             "roundOff": ["Would you ... again?"] },
  "part3": [ { "topic": "...", "questions": ["...", "..."] } ],
  "modelAnswers": [ { "part": 2, "question": "Describe a ...", "answer": "...", "band": 8 } ],
  "usefulLanguage": [ "..." ] }
```
Part 1: 3 topics × 4 questions (first topic is always work/studies or home). Part 3: 2 topics × 3–4 questions linked to Part 2.

## Practice units — `practice/index.json` + `practice/<id>.json`
`index.json`: `{ "units": [ { "id": "r-tfng", "skill": "reading", "title": "True / False / Not Given", "summary": "..." } ] }`
(`skill`: `listening`, `reading`, `writing`, `speaking`, `vocabulary`, `test-overview`).

Unit file:
```json
{ "id": "r-tfng", "skill": "reading", "title": "...",
  "guide": [ { "h": "What it tests" }, { "p": "..." }, { "bullets": ["...", "..."] }, { "tip": "..." }, { "example": "..." } ],
  "drill": null | { "passage": { "title": "...", "paragraphs": [ { "label": "", "text": "..." } ] } | null,
                    "script": [ ...listening script lines as above... ] | null,
                    "groups": [ ...question groups, numbered from 1... ] },
  "vocab": [ { "word": "...", "meaning": "...", "example": "..." } ],
  "models": [ { "title": "...", "prompt": "...", "answer": "...", "band": 8, "notes": ["..."] } ] }
```
Only `id`, `skill`, `title`, `guide` are required.

## descriptors.json — self-check (paraphrased in plain English, never quoted from official descriptors)
```json
{ "writing1": [ { "id": "TA", "name": "Task achievement", "bands": { "9": "...", "8": "...", "7": "...", "6": "...", "5": "...", "4": "..." } }, ... CC, LR, GRA ],
  "writing2": [ TR, CC, LR, GRA ],
  "speaking": [ FC, LR, GRA, P ] }
```
