# Grayscale Graphite palette

This palette is adapted from [andres-guzman/grayscale-graphite](https://github.com/andres-guzman/grayscale-graphite).
The Hyprland, Ghostty, and Neovim settings in this dotfiles repository use the
swatches in `grayscale-graphite.toml`.

The upstream project does not include wallpaper-processing code. It links to a
separately hosted collection of 805 wallpapers (about 6.65 GiB); this setup
keeps Omarchy's existing wallpaper handling and does not download that archive.
For local wallpaper folders, `omarchy/.config/omarchy/scripts/grayscale-wallpapers.sh`
creates selectable `*-grayscale` copies without changing the originals. Pass a
folder to make copies beside its images, or use `--output OUTPUT_DIR` followed
by one or more source folders to collect copies in a theme's wallpaper folder.
It uses ImageMagick's `magick` command.

The adapted palette and theme settings are covered by the upstream
GPL-3.0-only license included here. The external wallpaper artwork has
separate rights and is not included.
