return {
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    opts = {
      view = {
        display_mode = "border",
      },
    },
    keys = {
      { "<leader>cv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view", ft = { "csv", "tsv" } },
    },
  },
}
