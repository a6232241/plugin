#!/bin/bash

# 如果有參數，直接用參數；否則詢問使用者
if [ -n "$1" ]; then
  INPUT_DIR="$1"
else
  echo "Please enter the input directory (default: ./videos):"
  read -r INPUT_DIR
  INPUT_DIR=${INPUT_DIR:-"./videos"}
fi

OUTPUT_DIR="${INPUT_DIR%/}/fixed"

echo "Output directory: $OUTPUT_DIR"

mkdir -p "$OUTPUT_DIR"

# 常見幀率列表
fps_candidates=(23.976 24 25 30 50 60)

nearest_fps() {
  target=$1
  nearest=${fps_candidates[0]}
  diff=$(echo "scale=3; $target - $nearest" | bc | sed 's/-//')
  for f in "${fps_candidates[@]}"; do
    d=$(echo "scale=3; $target - $f" | bc | sed 's/-//')
    comp=$(echo "$d < $diff" | bc)
    if [ "$comp" -eq 1 ]; then
      nearest=$f
      diff=$d
    fi
  done
  echo $nearest
}

for file in "$INPUT_DIR"/*.{mov,mp4,MOV}; do
  [ -e "$file" ] || continue

  avg=$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate \
        -of default=noprint_wrappers=1:nokey=1 "$file")
  rfr=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate \
        -of default=noprint_wrappers=1:nokey=1 "$file")

  avg_fps=$(bc -l <<< "scale=3; $avg")
  rfr_fps=$(bc -l <<< "scale=3; $rfr")

  echo "檢查：$file (avg=$avg_fps fps, rfr=$rfr_fps fps)"

  if [ "$avg_fps" != "$rfr_fps" ]; then
    target_fps=$(nearest_fps $avg_fps)
    echo "⚠️ 可變幀率 → 轉換成 $target_fps fps"

    ext="${file##*.}"
    output_file="$OUTPUT_DIR/$(basename "${file%.*}")_${target_fps}fps.$ext"
    ffmpeg -i "$file" -map_metadata 0 -c:v libx264 -r $target_fps -pix_fmt yuv420p -c:a copy -b:a 128k "$output_file"
    touch -r "$file" "$output_file"
  else
    echo "✅ 固定幀率 → 直接複製"
    cp "$file" "$OUTPUT_DIR/"
  fi
done

read -p "Press Enter to continue..."
