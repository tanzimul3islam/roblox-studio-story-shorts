#!/bin/sh
# Final render: cut the take, crop the Studio viewport to 9:16, upscale to 1080x1920,
# burn in word-by-word captions (captions.ass), mix narration + score, -14 LUFS.
# Usage: [SLOW=5] render.sh <short_dir> <recording.mp4> <take start> <length> <score.wav> [delogo]
#   take start: real seconds in the recording (find_take.sh); length: STORY seconds (LENGTH)
#   SLOW: the take was recorded SLOW x slower (client template, default 5); the cut is
#         length*SLOW real seconds and is sped back up. SLOW=1 for old real-time takes.
#   delogo: optional "x:y:w:h" in crop coordinates to paint out a mouse cursor
#   HOOK_SFX: optional sound (wav) mixed in at 0.0 s under the hook line (a sting or whoosh,
#             e.g. /var/mnt/sda3/Roblox_Shorts/audio/sfx/whoosh.wav); HOOK_GAIN default 0.8
# Writes <short_dir>/<dirname>.mp4
set -e
F=/var/mnt/sda3/tools/ffmpeg/bin/ffmpeg
K=$(dirname "$(readlink -f "$0")")
D=$(cd "$1" && pwd); REC=$(readlink -f "$2"); START="$3"; LEN="$4"; SCORE="$5"
NAME=$(basename "$D")
python3 "$K/make_captions.py" "$D"
if [ "${ROTATE_90:-0}" = "1" ]; then
  CROP="crop=1314:746:419:188,transpose=1"
else
  CROP="crop=460:818:782:148"
fi
if [ -n "$6" ]; then
  set -- $(echo "$6" | tr ':' ' ')
  CROP="$CROP,delogo=x=$1:y=$2:w=$3:h=$4"
fi
SLOW=${SLOW:-5}
FPS=${FPS:-60}
REAL=$(python3 -c "print($LEN * $SLOW)")
FADE=$(python3 -c "print(max(0, $LEN - 1))")
cd "$D"
if [ -f "audio/final_mix.wav" ]; then
  $F -v error -y -ss "$START" -t "$REAL" -i "$REC" -i audio/final_mix.wav \
    -filter_complex "
  [0:v]setpts=(PTS-STARTPTS)/$SLOW,$CROP,eq=contrast=1.08:brightness=0.01:saturation=1.25,scale=1080:1920:flags=lanczos:out_color_matrix=bt709:out_range=limited,unsharp=5:5:0.6,fps=$FPS,setsar=1,ass=captions.ass,format=yuv420p[v];
  [1:a]atrim=0:$LEN,loudnorm=I=-14:TP=-1.0:LRA=11,aresample=48000[a]" \
    -map "[v]" -map "[a]" -c:v libx264 -preset slow -crf 18 -profile:v high \
    -color_primaries bt709 -color_trc bt709 -colorspace bt709 -color_range tv \
    -c:a aac -b:a 192k -t "$LEN" -movflags +faststart "$NAME.mp4"
else
  if [ -n "$HOOK_SFX" ]; then  # hook sting at 0.0 s (the first 2 seconds must grab attention)
    HIN="-i $HOOK_SFX"; HMIX="[3:a]volume=${HOOK_GAIN:-0.8}[h];[n][m][h]amix=inputs=3"
  else
    HIN=""; HMIX="[n][m]amix=inputs=2"
  fi
  $F -v error -y -ss "$START" -t "$REAL" -i "$REC" -i audio/narration.wav -i "$SCORE" $HIN \
    -filter_complex "
  [0:v]setpts=(PTS-STARTPTS)/$SLOW,$CROP,eq=contrast=1.08:brightness=0.01:saturation=1.25,scale=1080:1920:flags=lanczos:out_color_matrix=bt709:out_range=limited,unsharp=5:5:0.6,fps=$FPS,setsar=1,ass=captions.ass,format=yuv420p[v];
  [1:a]apad[n];
  [2:a]volume=0.22,afade=t=out:st=$FADE:d=1[m];
  $HMIX:normalize=0:duration=first,atrim=0:$LEN,loudnorm=I=-14:TP=-1.0:LRA=11,aresample=48000[a]" \
    -map "[v]" -map "[a]" -c:v libx264 -preset slow -crf 18 -profile:v high \
    -color_primaries bt709 -color_trc bt709 -colorspace bt709 -color_range tv \
    -c:a aac -b:a 192k -t "$LEN" -movflags +faststart "$NAME.mp4"
fi
echo "done: $D/$NAME.mp4"
