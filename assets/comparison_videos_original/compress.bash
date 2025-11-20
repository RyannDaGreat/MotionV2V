#!/bin/bash
set -e

# High Quality Video Compression Script
# Uses AV1 CRF 35 with Preset 4 for maximum quality
# Processes all MP4 files in parallel

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../comparison_videos_compressed"

# Compression settings
CRF=35          # Lower = better quality (18-50 range, 35 is excellent)
PRESET=4        # Lower = better quality but slower (0-13 range, 4 is quality-focused)
CODEC="libsvtav1"

echo "=================================================="
echo "High Quality Video Compression"
echo "=================================================="
echo "Settings:"
echo "  Codec:  AV1 ($CODEC)"
echo "  CRF:    $CRF (excellent quality)"
echo "  Preset: $PRESET (quality-focused)"
echo "  Mode:   Parallel processing"
echo ""
echo "Input:  $SCRIPT_DIR"
echo "Output: $OUTPUT_DIR"
echo "=================================================="
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to compress a single video
compress_video() {
  local file="$1"
  local filename=$(basename "$file")

  echo "Starting: $filename"

  ffmpeg -i "$file" \
    -c:v "$CODEC" -crf "$CRF" -preset "$PRESET" \
    -c:a copy \
    "$OUTPUT_DIR/$filename" \
    -y 2>&1 > "/tmp/ffmpeg_${filename}.log"

  if [ -f "$OUTPUT_DIR/$filename" ]; then
    local oldsize=$(ls -lh "$file" | awk '{print $5}')
    local newsize=$(ls -lh "$OUTPUT_DIR/$filename" | awk '{print $5}')
    echo "✓ $filename: $oldsize → $newsize"
  else
    echo "✗ FAILED: $filename"
  fi
}

export -f compress_video
export OUTPUT_DIR CODEC CRF PRESET

# Get list of video files
video_files=()
while IFS= read -r -d '' file; do
  video_files+=("$file")
done < <(find "$SCRIPT_DIR" -maxdepth 1 -name "*.mp4" -type f -print0)

if [ ${#video_files[@]} -eq 0 ]; then
  echo "No MP4 files found in $SCRIPT_DIR"
  exit 1
fi

echo "Found ${#video_files[@]} video(s) to compress"
echo "Launching parallel compression..."
echo ""

# Launch all compressions in parallel
pids=()
for file in "${video_files[@]}"; do
  compress_video "$file" &
  pids+=($!)
done

# Wait for all to complete
for pid in "${pids[@]}"; do
  wait "$pid"
done

echo ""
echo "=================================================="
echo "Compression Complete!"
echo "=================================================="
echo ""
echo "Original directory size:"
du -sh "$SCRIPT_DIR"
echo ""
echo "Compressed directory size:"
du -sh "$OUTPUT_DIR"
echo ""
echo "Compression logs saved to /tmp/ffmpeg_*.log"
echo "=================================================="
