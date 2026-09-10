return {
  "rebelot/kanagawa.nvim",
  lazy = true,
  priority = 1000,
  opts = {
    -- Cool blue-gray palette to match the winter Ghostty background.
    theme = "wave",
    transparent = true,
    colors = {
      -- Keep the Wave structure, but use the terminal's muted winter palette.
      palette = {
        fujiWhite = "#F2EFE9",
        oldWhite = "#E7E3DC",
        fujiGray = "#8D8A83",
        waveBlue1 = "#3B414A",
        waveBlue2 = "#56616C",
        crystalBlue = "#8EA8C5",
        springBlue = "#B0C8E1",
        oniViolet = "#AD9AB7",
        oniViolet2 = "#B9ACBF",
        springViolet1 = "#AD9AB7",
        springViolet2 = "#C4B1CE",
        waveAqua1 = "#8FB8B1",
        waveAqua2 = "#B0D3CB",
        springGreen = "#9BB58E",
        boatYellow2 = "#C5AA7A",
        carpYellow = "#D9C08F",
        autumnRed = "#C9857E",
        waveRed = "#C9857E",
        samuraiRed = "#E2A19A",
        peachRed = "#E2A19A",
      },
      theme = {
        all = {
          ui = {
            bg_gutter = "none",
          },
        },
      },
    },
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
