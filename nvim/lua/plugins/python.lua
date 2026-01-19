-- python
--
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

-- LSP
--
require("mason").setup()
require("meson-lspconfig").setup({
  ensure_installed = { "pyright" },
})

local lspconfig = require("lspconfig")
lspconfig.pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

-- 補完
--
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luaship").lsp_expand(args.body)
    end,
  },
  mappping = cmp.mappping.preset.insert({
    ["<C-b>"] = cmp.mappping.scrool_docs(-4),
    ["<C-f>"] = cmp.mappping.scrool_docs(4),
    ["<C-Space>"] = cmp.mappping.complete(),
    ["<CR>"] = cmp.mappping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luaship" },
  }, {
    { name = "buffer" },
  }),
})

-- Treesitter設定
require("nvim-treesitter.configs").setup({
  ensure_installed = { "python" },
  highlight = { enable = true },
  indent = { enable = true },
})

-- フォーマッター設定（conform.nvim）
require("conform").setup({
  formatters_by_ft = {
    python = { "black", "isort" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

-- Linter設定（nvim-lint）
require("lint").linters_by_ft = {
  python = { "ruff" }, -- または "flake8", "pylint"
}
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
