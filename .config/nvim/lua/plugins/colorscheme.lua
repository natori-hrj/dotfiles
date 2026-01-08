return {
  "rebelot/kanagawa.nvim",
  lazy = true,
  priority = 1000,
  opts = {
    thrme = "dragon",
    transparent = true,
    overrides = function()
      return {
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },

        NeoTreeNormal = { bg = "none" },
        NeoTreeNormalNC = { bg = "none" },
      }
    end,
  },
}
