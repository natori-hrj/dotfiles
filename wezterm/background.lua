local background_image = "/Users/natori/dotfiles/wezterm/IMG_0153.png"

return {
  {
    source = { Color = "#000000" },
    width = "100%",
    height = "100%",
  },
  {
    source = { File = background_image },
    horizontal_align = "Center",
    vertical_align = "Middle",
    hsb = { brightness = 0.3 },
    opacity = 0.85,
  },
}
