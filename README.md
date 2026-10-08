# dotfiles

Personal configuration for Omarchy / Arch Linux, Hyprland, Ghostty, Neovim,
and Zsh. GNU Stow links each package into the home directory.

## Setup

```bash
git clone git@github.com:natori-hrj/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow <package>
```

## PDF Library

The Omarchy plugin in `omarchy/.config/omarchy/plugins/natori.pdf-library`
provides a centered Quickshell window for browsing PDFs. Press `Super + Alt + N`
to open it. It supports title/path and PDF text search, favorites, recent opens,
reading counts, and opening files in Zathura. Zathura also saves the current
page and resumes from it next time.

On a fresh Omarchy install, apply the relevant packages with:

```bash
stow --no-folding hypr omarchy zathura
./omarchy/.config/omarchy/scripts/install-pdf-library.sh
hyprctl reload
omarchy-restart-shell
```

The PDF workflow needs `zathura`, `zathura-pdf-mupdf`, `poppler`,
`wl-clipboard`, and `xdg-utils`; Quickshell is provided by Omarchy. These
packages are already installed on this machine. Library state is stored in
`~/.local/state/omarchy/pdf-library.json`, outside the dotfiles.
