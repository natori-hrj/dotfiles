local background_image = os.getenv("HOME") .. "/Pictures/gopher.jpeg"

return {
  {
    source = { Color = "#16161D" },
    width = "100%",
    height = "100%",
  },
  {
    source = { File = background_image },
    horizontal_align = "Center",
    vertical_align = "Middle",
    hsb = { brightness = 0.3 },
    opacity = 0.10,
  },
}
