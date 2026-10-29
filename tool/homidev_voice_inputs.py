#!/usr/bin/env python3
"""Write one homidev `voice-en-standard` inputs.json per listening script line.

Usage: python3 tool/homidev_voice_inputs.py t01 [out_dir]
Output: <out_dir>/<clip-id>.json  (default out_dir: build/homidev_inputs/<test>)

Each file is passed to ~/ai-inbox/_tools/asset-job.sh ielts voice-en-standard yes <file>.
After Homi approves a clip, integrate it as assets/audio/<test>/listening/<clip-id>.ogg.
Nothing here talks to homidev; it only prepares inputs.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COMMON_WORDS = {"I", "The", "A", "And", "But", "So", "Yes", "No", "Well", "Right", "OK", "Okay"}


def glossary_for(text: str, fallback: str) -> list[str]:
    """Proper nouns and spelled-out words the voice must pronounce carefully."""
    # Capitalised words that do not start a sentence are names or places.
    names = {
        match.group(1)
        for match in re.finditer(r"(?<![.?!:]\s)(?<!^)\b([A-Z][a-zA-Z'-]{2,})\b", text)
        if match.group(1) not in COMMON_WORDS and match.start() > 0
    }
    spelled = re.findall(r"\b(?:[A-Z]-){2,}[A-Z]\b", text)
    terms = sorted(names | set(spelled))
    if terms:
        return terms
    words = re.findall(r"[a-zA-Z']{4,}", text)
    return [max(words, key=len)] if words else [fallback]


def main() -> None:
    test_id = sys.argv[1] if len(sys.argv) > 1 else "t01"
    out_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "build" / "homidev_inputs" / test_id
    paper = json.loads((ROOT / "assets/content/tests" / test_id / "listening.json").read_text())
    out_dir.mkdir(parents=True, exist_ok=True)
    speakers = paper["speakers"]
    count = 0
    for part in paper["parts"]:
        for item in part["script"]:
            if "id" not in item:
                continue
            inputs = {
                "script": item["text"],
                "glossary": glossary_for(item["text"], "IELTS"),
                "voice": speakers[item["speaker"]]["voice"],
            }
            (out_dir / f"{item['id']}.json").write_text(json.dumps(inputs, indent=2, ensure_ascii=False))
            count += 1
    print(f"{count} inputs written to {out_dir}")


if __name__ == "__main__":
    main()
