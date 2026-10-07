-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- Grayscale Graphite appearance palette and decoration.
-- Palette adapted from https://github.com/andres-guzman/grayscale-graphite
hl.config({
  general = {
    col = {
      active_border = "rgb(99979b)",
      inactive_border = "rgb(2d2d2f)",
    },
  },
  group = {
    col = {
      border_active = "rgb(99979b)",
      border_inactive = "rgb(2d2d2f)",
    },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    rounding = 8,
    rounding_power = 3,
    active_opacity = 0.65,
    inactive_opacity = 0.65,
    fullscreen_opacity = 1.0,
    dim_inactive = false,
    blur = {
      enabled = true,
      size = 2,
      passes = 3,
      vibrancy = 0.1696,
      brightness = 1.20,
      contrast = 1.25,
      vibrancy_darkness = 0.0,
      new_optimizations = true,
      xray = true,
      special = true,
      input_methods = true,
      noise = 0,
      popups = true,
      popups_ignorealpha = 0.20,
      input_methods_ignorealpha = 0.20,
    },
    shadow = {
      enabled = true,
      range = 35,
      render_power = 4,
      color = "rgba(2c2b304d)",
    },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 5,
  bezier = "easeOutQuint",
  style = "slide",
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
