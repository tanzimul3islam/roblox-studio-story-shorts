#!/bin/sh
# Hook check for a final render: the first 2 seconds must grab attention.
# Saves the frames at 0.0, 0.5, 1.0 and 2.0 s side by side (look at them: each must show a
# face or action + a caption word), and reports when the first word is heard and how loud the
# first 2 s are compared with the whole video.
# Usage: check_hook.sh <final.mp4> <out.png>
F=/var/mnt/sda3/tools/ffmpeg/bin/ffmpeg
$F -v error -y -i "$1" -vf "select='eq(n\,0)+eq(n\,15)+eq(n\,30)+eq(n\,60)',scale=270:480,tile=4x1" -frames:v 1 -fps_mode vfr "$2" && echo "frames 0/0.5/1/2 s -> $2"
$F -hide_banner -t 3 -i "$1" -af silencedetect=noise=-35dB:d=0.05 -f null - 2>&1 | grep -o "silence_end: [0-9.]*" | head -1 | sed 's/silence_end/first sound after silence at/'
L2=$($F -hide_banner -t 2 -i "$1" -af ebur128 -f null - 2>&1 | grep -A1 "Integrated" | tail -1 | grep -o "[-0-9.]* LUFS")
LA=$($F -hide_banner -i "$1" -af ebur128 -f null - 2>&1 | grep -A1 "Integrated" | tail -1 | grep -o "[-0-9.]* LUFS")
echo "loudness first 2 s: $L2 (whole video: $LA) - the hook should not be quieter"
