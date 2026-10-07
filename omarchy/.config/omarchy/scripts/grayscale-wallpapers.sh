#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 SOURCE_DIR" >&2
  echo "       $0 --output OUTPUT_DIR SOURCE_DIR [SOURCE_DIR ...]" >&2
  echo "Creates grayscale copies named *-grayscale next to source images by default." >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

if [[ $1 == --output ]]; then
  if [[ $# -lt 3 ]]; then
    usage
    exit 2
  fi
  output_dir=$2
  shift 2
  source_dirs=("$@")
else
  if [[ $# -ne 1 ]]; then
    usage
    exit 2
  fi
  source_dirs=("$1")
  output_dir=$1
fi

for source_dir in "${source_dirs[@]}"; do
  if [[ ! -d $source_dir ]]; then
    echo "Source directory does not exist: $source_dir" >&2
    exit 2
  fi
done

if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick is required (the 'magick' command was not found)." >&2
  exit 1
fi

mkdir -p -- "$output_dir"
converted=0
skipped=0

for source_dir in "${source_dirs[@]}"; do
  while IFS= read -r -d '' source_file; do
    filename=${source_file##*/}
    case "$filename" in
      *-grayscale.*) continue ;;
    esac

    stem=${filename%.*}
    extension=${filename##*.}
    output_file="$output_dir/${stem}-grayscale.${extension}"

    if [[ -e $output_file ]]; then
      echo "Keeping existing copy: $output_file"
      ((skipped += 1))
      continue
    fi

    magick "$source_file" -colorspace Gray "$output_file"
    echo "Created: $output_file"
    ((converted += 1))
  done < <(
    find "$source_dir" -maxdepth 1 -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \) \
      -print0 | sort -z
  )
done

echo "Done: $converted converted, $skipped already existed."
