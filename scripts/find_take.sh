#!/bin/sh
# Find takes in an OBS recording: the client shows full-screen black before and after a
# take, so a take is the gap between two black segments. Prints "take <start> <end> <len>".
# Usage: find_take.sh <recording.mp4>
F=/var/mnt/sda3/tools/ffmpeg/bin/ffmpeg
$F -hide_banner -i "$1" -vf "crop=400:400:812:340,blackdetect=d=0.5:pix_th=0.05" -an -f null - 2>&1 \
  | grep -o 'black_start:[0-9.]* black_end:[0-9.]*' \
  | python3 -c '
import re, sys
b = [tuple(map(float, re.findall(r"[0-9.]+", l))) for l in sys.stdin]
for (s0, e0), (s1, e1) in zip(b, b[1:]):
    print(f"take {e0 + 0.02:.2f} {s1:.2f} {s1 - e0:.2f}")
if len(b) < 2:
    print("fewer than 2 black segments: recording missed the black lead-in or tail", b)
'
