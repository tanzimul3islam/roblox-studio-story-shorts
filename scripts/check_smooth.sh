#!/bin/sh
# Smoothness check of a final render: counts frames that actually change (mpdecimate).
# A smooth 30 fps Short shows ~28-30 unique fps and no frozen gaps over ~70 ms.
# Only the top 1100 px are measured, so the word captions (y ~1180-1300) don't count as motion.
# Static shots (nothing moving) lower the number legitimately; look at the longest gaps.
# Usage: check_smooth.sh <final.mp4>
F=/var/mnt/sda3/tools/ffmpeg/bin/ffmpeg
D=$(/var/mnt/sda3/tools/ffmpeg/bin/ffprobe -v error -show_entries format=duration -of csv=p=0 "$1")
$F -hide_banner -i "$1" -vf "crop=1080:1100:0:0,scale=270:275,mpdecimate=hi=64*4:lo=64:frac=0.1,showinfo" -an -f null - 2>&1 \
  | grep -o "pts_time:[0-9.]*" | cut -d: -f2 | python3 -c "
import sys
t = [float(x) for x in sys.stdin]
d = [b - a for a, b in zip(t, t[1:])]
D = float('$D')
print(f'unique frames: {len(t)} in {D:.1f} s = {len(t) / D:.1f} fps')
if d:
    s = sorted(d)
    print(f'gap median {s[len(s)//2]*1000:.0f} ms, p90 {s[int(len(s)*.9)]*1000:.0f} ms, max {s[-1]*1000:.0f} ms')
    print('frozen gaps > 70 ms:', sum(1 for x in d if x > 0.07), ' > 120 ms:', sum(1 for x in d if x > 0.12))
"
