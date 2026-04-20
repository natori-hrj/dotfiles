#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[info]${NC} $1"; }
warn()    { echo -e "${YELLOW}[warn]${NC} $1"; }
error()   { echo -e "${RED}[error]${NC} $1"; }

link() {
  local src="$1"
  local dst="$2"

  # すでに正しいシンボリックリンクなら何もしない
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    info "already linked: $dst"
    return
  fi

  # 既存ファイル/ディレクトリがあればバックアップ
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "backing up: $dst -> ${dst}.backup"
    mv "$dst" "${dst}.backup"
  fi

  ln -sf "$src" "$dst"
  info "linked: $dst -> $src"
}

mkdir -p "$CONFIG_DIR"

# ~/.config 配下にリンクするディレクトリ
for dir in nvim wezterm claude starship aerospace borders; do
  if [ -d "$DOTFILES_DIR/$dir" ]; then
    link "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
  fi
done

# ~/.zshrc
if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
elif [ -f "$DOTFILES_DIR/zsh/zshrc" ]; then
  link "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
fi

echo ""
info "✨ dotfiles installation complete!"
