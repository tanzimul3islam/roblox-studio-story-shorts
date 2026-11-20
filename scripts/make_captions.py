"""Word-by-word burned-in captions (Flookus style) as an ASS file.

  python3 scripts/make_captions.py shorts/Story_01
Reads audio/timings.json (script text) and audio/words.json (Whisper word
times on narration.wav); writes captions.ass for a 1080x1920 frame.
Script words are shown (Whisper spellings like "Dr." or "200" are replaced),
each popping in from 80% to 100% size.
"""
import difflib
import json
import os
import re
import sys

d = sys.argv[1]
timings = json.load(open(os.path.join(d, "audio", "timings.json")))
heard = json.load(open(os.path.join(d, "audio", "words.json")))

norm = lambda w: re.sub(r"[^a-z0-9]", "", w.lower())
script = [w for t in timings for w in t["text"].split()]
a = [norm(w) for w in script]
b = [norm(w["w"]) for w in heard]

# Align script words to Whisper words; matched words take Whisper's times.
times = [None] * len(script)
for blk in difflib.SequenceMatcher(None, a, b, autojunk=False).get_matching_blocks():
    for k in range(blk.size):
        h = heard[blk.b + k]
        times[blk.a + k] = (h["s"], h["e"])

# Unmatched words: spread them over their sentence gap between known neighbours.
bounds = []
for t in timings:
    bounds += [(t["start"], t["end"])] * len(t["text"].split())
i = 0
while i < len(times):
    if times[i] is not None:
        i += 1
        continue
    j = i
    while j < len(times) and times[j] is None:
        j += 1
    lo = times[i - 1][1] if i > 0 else bounds[i][0]
    hi = times[j][0] if j < len(times) else bounds[j - 1][1]
    step = max(0.05, (hi - lo) / (j - i))
    for k in range(i, j):
        times[k] = (lo + step * (k - i), lo + step * (k - i + 1))
    i = j


def ts(sec):
    cs = int(round(sec * 100))
    return f"{cs // 360000}:{cs // 6000 % 60:02d}:{cs // 100 % 60:02d}.{cs % 100:02d}"


head = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
WrapStyle: 2

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Word,Arial Black,96,&H00FFFFFF,&H00FFFFFF,&H00000000,&H64000000,1,0,0,0,100,100,0,0,1,7,3,5,40,40,0,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
lines = []
for k, (word, (s, e)) in enumerate(zip(script, times)):
    nxt = times[k + 1][0] if k + 1 < len(times) else e + 0.4
    end = min(max(e, s + 0.12), nxt) if nxt > s else e
    text = re.sub(r"[^\w'?!-]", "", word)
    lines.append(f"Dialogue: 0,{ts(s)},{ts(end)},Word,,0,0,0,,"
                 f"{{\\pos(540,1240)\\fscx80\\fscy80\\t(0,90,\\fscx100\\fscy100)}}{text}")
open(os.path.join(d, "captions.ass"), "w").write(head + "\n".join(lines) + "\n")
print(f"captions: {len(lines)} words, {sum(t is not None for t in times)} timed")
