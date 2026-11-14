"""Narration for a Roblox Studio story Short, from <short_dir>/script.json.

Run:  ~/.venv/bin/python narrate.py <short_dir> [--force]

script.json:
  {
    "voice": "jean",            # Pocket TTS voice (jean = the Story_01/Pet Cloud narrator)
    "speed": 0.96,              # overall speed after the pitch shift (0.96 ~= 200 wpm)
    "semitones": 2,             # pitch up for a younger narrator
    "lead_in": 0.1,             # silence before the first line (0.1: the hook starts at once)
    "sentences": [["In this world, ...", 0.1], ["You see, ...", 0.05], ...]
  }

Writes <short_dir>/audio/lines/raw/NN.wav (raw TTS, kept so changing speed/pitch never
needs new TTS), lines/NN.wav (filtered + trimmed), narration.wav (-16 LUFS) and
timings.json ([{i, text, start, end}] seconds in narration.wav).

Redo one bad line: delete audio/lines/raw/NN.wav (or edit its text) and re-run.
Edited text is detected: a line whose text changed since its raw take is regenerated.
"""
import json
import os
import subprocess
import sys
import tempfile

import scipy.io.wavfile

FF = "/var/mnt/sda3/tools/ffmpeg/bin"


def duration(path):
    out = subprocess.run([f"{FF}/ffprobe", "-v", "error", "-show_entries", "format=duration",
                          "-of", "csv=p=0", path], capture_output=True, text=True, check=True)
    return float(out.stdout)


def main():
    d = os.path.abspath(sys.argv[1])
    force = "--force" in sys.argv
    cfg = json.load(open(os.path.join(d, "script.json")))
    sentences = [(s[0], float(s[1])) for s in cfg["sentences"]]
    rate = 2 ** (cfg.get("semitones", 2) / 12)
    tempo = cfg.get("speed", 0.96) / rate
    filt = f"asetrate=24000*{rate:.5f},aresample=24000,atempo={tempo:.5f}"

    out = os.path.join(d, "audio")
    lines = os.path.join(out, "lines")
    raw_dir = os.path.join(lines, "raw")
    os.makedirs(raw_dir, exist_ok=True)

    # Remember which text each raw take was made from, so edited lines get redone.
    made_path = os.path.join(raw_dir, "texts.json")
    made = json.load(open(made_path)) if os.path.exists(made_path) else {}
    todo = [i for i, (text, _) in enumerate(sentences)
            if force or not os.path.exists(os.path.join(raw_dir, f"{i:02d}.wav"))
            or made.get(f"{i:02d}", text) != text]
    if todo:
        from pocket_tts import TTSModel
        model = TTSModel.load_model()
        state = model.get_state_for_audio_prompt(cfg.get("voice", "jean"))
        for i in todo:
            audio = model.generate_audio(state, sentences[i][0])
            scipy.io.wavfile.write(os.path.join(raw_dir, f"{i:02d}.wav"), model.sample_rate, audio.numpy())
            made[f"{i:02d}"] = sentences[i][0]
            print("generated", i)
        json.dump(made, open(made_path, "w"), indent=1)

    trim = ("silenceremove=start_periods=1:start_threshold=-45dB,areverse,"
            "silenceremove=start_periods=1:start_threshold=-45dB,areverse")
    for i in range(len(sentences)):
        subprocess.run([f"{FF}/ffmpeg", "-y", "-v", "error", "-i", os.path.join(raw_dir, f"{i:02d}.wav"),
                        "-af", f"{filt},{trim}", "-ar", "48000", "-ac", "1",
                        os.path.join(lines, f"{i:02d}.wav")], check=True)

    lead = float(cfg.get("lead_in", 0.1))
    timings, t, parts = [], lead, []
    with tempfile.TemporaryDirectory() as tmp:
        def sil(sec, name):
            p = os.path.join(tmp, name)
            subprocess.run([f"{FF}/ffmpeg", "-y", "-v", "error", "-f", "lavfi", "-i", "anullsrc=r=48000:cl=mono",
                            "-t", f"{sec:.3f}", p], check=True)
            return p
        parts.append(sil(lead, "lead.wav"))
        for i, (text, pause) in enumerate(sentences):
            clip = os.path.join(lines, f"{i:02d}.wav")
            dur = duration(clip)
            timings.append({"i": i, "text": text, "start": round(t, 3), "end": round(t + dur, 3)})
            parts.append(clip)
            parts.append(sil(max(pause, 0.01), f"p{i:02d}.wav"))
            t += dur + pause
        listfile = os.path.join(tmp, "list.txt")
        with open(listfile, "w") as fh:
            fh.writelines(f"file '{p}'\n" for p in parts)
        subprocess.run([f"{FF}/ffmpeg", "-y", "-v", "error", "-f", "concat", "-safe", "0", "-i", listfile,
                        "-af", "loudnorm=I=-16:TP=-1.5:LRA=11", "-ar", "48000", "-ac", "1",
                        os.path.join(out, "narration.wav")], check=True)
    json.dump(timings, open(os.path.join(out, "timings.json"), "w"), indent=1)
    words = sum(len(s[0].split()) for s in sentences)
    print(f"narration {t:.1f}s, {words} words, {words / t * 60:.0f} wpm (target 190-210)")
    for tm in timings:
        print(f"{tm['i']:2d} {tm['start']:6.2f} {tm['end']:6.2f}  {tm['text'][:60]}")


main()
