local wezterm = require("wezterm")

local function file_exists(path)
  local file = io.open(path, "r")
  if file == nil then
    return false
  end

  file:close()
  return true
end

local home = os.getenv("HOME") or ""
local configured_image = os.getenv("WEZTERM_BACKGROUND")
local image_candidates = {
  configured_image,
  wezterm.config_dir .. "/terminal-winter.jpeg",
  home .. "/Pictures/gopher.jpeg",
  wezterm.config_dir .. "/IMG_0153.png",
}

local background_image
for _, candidate in ipairs(image_candidates) do
  if candidate ~= nil and candidate ~= "" and file_exists(candidate) then
    background_image = candidate
    break
  end
end

local layers = {}

if background_image ~= nil then
  table.insert(layers, {
    source = { File = background_image },
    horizontal_align = "Center",
    vertical_align = "Middle",
    repeat_x = "NoRepeat",
    repeat_y = "NoRepeat",
    width = "Cover",
    height = "Cover",
    hsb = {
      brightness = 1.0,
      saturation = 0.9,
    },
    opacity = 1.0,
  })
else
  table.insert(layers, {
    source = { Color = "#121419" },
    width = "100%",
    height = "100%",
  })
end

table.insert(layers, {
  source = { Color = "#121419" },
  width = "100%",
  height = "100%",
  opacity = 0.12,
})

return layers
