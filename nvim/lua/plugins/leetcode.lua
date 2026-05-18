return {
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    build = function()
      if pcall(require, "nvim-treesitter") then
        vim.cmd("TSUpdate html")
      end
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      arg = "leetcode.nvim",
      lang = "golang",
      cn = { enabled = false },
      storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
        cache = vim.fn.stdpath("cache") .. "/leetcode",
      },
      injector = {
        ["golang"] = {
          before = { "package main" },
        },
      },
      hooks = {
        ["enter"] = {},
        ["question_enter"] = {},
        ["leave"] = {},
      },
      keys = {
        toggle = { "q" },
        confirm = { "<CR>" },
        reset_testcases = "r",
        use_testcase = "U",
        focus_testcases = "H",
        focus_result = "L",
      },
    },
    keys = {
      { "<leader>lq", "<cmd>Leet<cr>", desc = "LeetCode: dashboard" },
      { "<leader>ll", "<cmd>Leet list<cr>", desc = "LeetCode: problem list" },
      { "<leader>lr", "<cmd>Leet run<cr>", desc = "LeetCode: run tests" },
      { "<leader>ls", "<cmd>Leet submit<cr>", desc = "LeetCode: submit" },
      { "<leader>ld", "<cmd>Leet daily<cr>", desc = "LeetCode: daily question" },
      { "<leader>lR", "<cmd>Leet random difficulty=medium<cr>", desc = "LeetCode: random medium" },
      { "<leader>lc", "<cmd>Leet console<cr>", desc = "LeetCode: console" },
      { "<leader>li", "<cmd>Leet info<cr>", desc = "LeetCode: info" },
      { "<leader>lm", "<cmd>Leet menu<cr>", desc = "LeetCode: menu" },
    },
  },
}
