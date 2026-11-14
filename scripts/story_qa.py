"""Whisper check of narration lines against the script.

Run with the whisper env:
  /var/mnt/sda3/tools/whisper-env/bin/python scripts/story_qa.py shorts/Story_01
Prints lines whose transcript misses words. Also writes words.json: word-level
timestamps for the full narration.wav, used for the burned-in captions.
"""
import difflib
import json
import os
import re
import sys

from faster_whisper import WhisperModel

d = sys.argv[1]
timings = json.load(open(os.path.join(d, "audio", "timings.json")))
m = WhisperModel("small.en", device="cpu", compute_type="int8",
                 download_root="/var/mnt/sda3/tools/whisper-models")
norm = lambda s: re.sub(r"[^a-z0-9 ]", "", s.lower().replace("-", " ")).split()

bad = 0
for t in timings:
    clip = os.path.join(d, "audio", "lines", f"{t['i']:02d}.wav")
    segs, _ = m.transcribe(clip, beam_size=5, language="en")
    heard = " ".join(s.text for s in segs)
    want, got = norm(t["text"]), norm(heard)
    ratio = difflib.SequenceMatcher(None, want, got).ratio()
    if ratio < 0.85:
        bad += 1
        print(f"{t['i']:02d} {ratio:.2f}\n   want: {t['text']}\n   got:  {heard.strip()}")
print("lines flagged:", bad)

# Word timestamps on the whole narration for captions; script words replace
# Whisper's spelling, matched in order.
segs, _ = m.transcribe(os.path.join(d, "audio", "narration.wav"), beam_size=5,
                       language="en", word_timestamps=True)
words = [{"w": w.word.strip(), "s": round(w.start, 3), "e": round(w.end, 3)} for s in segs for w in s.words]
json.dump(words, open(os.path.join(d, "audio", "words.json"), "w"), indent=0)
print("words:", len(words))
