#!/bin/sh

query=$1
shift

for file do
  [ -f "$file" ] || continue
  if pdftotext -l 6 -q "$file" - 2>/dev/null | grep -Fqi -- "$query"; then
    printf '%s\n' "$file"
  fi
done
