# PDF Library

This Omarchy shell panel indexes PDFs in the home directory, searches titles,
paths, and extracted text, and keeps favorites, recent opens, and reading
counts. Opening an entry launches it in Zathura, which saves the current page
and resumes from that page next time.

State is stored outside the dotfiles at
`~/.local/state/omarchy/pdf-library.json`.

## Use

- Press `Super + Alt + N` to show or hide the library.
- Type `/` to focus the search field. Searches of three or more characters also
  check the first six pages of indexed PDFs.
- Use the arrow keys to move through results, `Enter` to open, `F` to toggle a
  favorite, `C` to copy a path, and `Escape` to close.
- The path field opens a PDF that is not in the scanned library.
- Rescan with the circular arrow in the header.

The library opens on the left at 780×620, with Zathura on the right at
600×700. Both are floating windows and remain resizable. `shell.json` enables
the panel, and Hyprland places both windows side by side.

Resize the PDF Library with `Super + Ctrl + Shift + ←/→` for width and
`Super + Ctrl + Shift + ↑/↓` for height, in 80-pixel steps. `Super + right-drag`
also resizes the focused floating window.

Resize Zathura from the keyboard in 80-pixel steps: `Super + Ctrl + Alt + ←`
narrows it, `→` widens it, `↑` shortens it, and `↓` increases its height.
`Super + right-drag` also resizes the floating window.

## Dependencies

Omarchy supplies Quickshell. PDF reading needs `zathura` and
`zathura-pdf-mupdf`; full-text search uses `poppler` (`pdftotext`), path copying
uses `wl-clipboard`, and the folder action uses `xdg-utils`. These packages are
already installed on this machine.

## Reference and licensing

The feature set and general layout were informed by
[codetesla51/uthman_dotfiles](https://github.com/codetesla51/uthman_dotfiles),
which documents its PDF Library in the repository README. The repository has no
top-level license file; its only tracked license file is for the Neovim config.
No source code from that repository is included here.
