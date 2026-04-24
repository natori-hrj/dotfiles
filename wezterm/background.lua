local background_image = os.getenv("HOME") .. "/Pictures/gopher.jpeg"

return {
  {
    source = { Color = "#16161D" },
    width = "100%",
    height = "100%",
    opacity = 0.85,
  },
  {
    source = { File = background_image },
    horizontal_align = "Center",
    vertical_align = "Middle",
    repeat_x = "NoRepeat",
    repeat_y = "NoRepeat",
    width = "Cover",
    height = "Cover",
    hsb = { brightness = 0.3 },
    opacity = 0.10,
  },
}
