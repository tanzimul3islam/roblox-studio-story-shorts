#!/bin/sh
# Contact sheet of the 9:16 crop of a take, one frame every STEP story seconds (default 1.45).
# Usage: [ROTATE_90=1] [SLOW=5] sheet.sh <recording.mp4> <take start> <length> <out.png> [step]
#   take start: real seconds (find_take.sh); length: STORY seconds; SLOW/ROTATE_90 as in render.sh
F=/var/mnt/sda3/tools/ffmpeg/bin/ffmpeg
STEP=${5:-1.45}
SLOW=${SLOW:-5}
if [ "${ROTATE_90:-0}" = "1" ]; then
  CROP="crop=1314:746:419:188,transpose=1"
else
  CROP="crop=460:818:782:148"
fi
REAL=$(python3 -c "print($3 * $SLOW)")
$F -v error -y -ss "$2" -i "$1" -t "$REAL" \
  -vf "setpts=(PTS-STARTPTS)/$SLOW,$CROP,select='isnan(prev_selected_t)+gte(t-prev_selected_t\,$STEP)',scale=160:-1,tile=15x2" \
  -frames:v 1 -fps_mode vfr "$4" && echo "$4"
