#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f -- "${BASH_SOURCE[0]}")"
omarchy_config="$(cd -- "$(dirname -- "$script_path")/.." && pwd)"
source_dir="$omarchy_config/plugins/natori.pdf-library"
target_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/natori.pdf-library"

if [[ ! -f "$source_dir/manifest.json" ]]; then
  printf 'PDF Library source not found: %s\n' "$source_dir" >&2
  exit 1
fi

install -d "$target_dir"
install -m 644 "$source_dir/Panel.qml" "$target_dir/Panel.qml"
install -m 644 "$source_dir/README.md" "$target_dir/README.md"
install -m 644 "$source_dir/manifest.json" "$target_dir/manifest.json"
install -m 755 "$source_dir/search-content.sh" "$target_dir/search-content.sh"

printf 'Installed PDF Library to %s\n' "$target_dir"
