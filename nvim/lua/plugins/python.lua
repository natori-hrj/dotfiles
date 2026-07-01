return {
  -- LSP: configure servers through LazyVim's `opts.servers` so LazyVim's own
  -- LSP setup (gd / references / hover keymaps, mason auto-install) stays intact.
  -- A custom `config` function here would replace LazyVim's and break those.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          before_init = function(_, config)
            -- Auto-detect the project virtualenv
            local venv = os.getenv("VIRTUAL_ENV")
              or vim.fn.finddir(".venv", vim.fn.getcwd() .. ";")
              or vim.fn.finddir("venv", vim.fn.getcwd() .. ";")
            if venv and venv ~= "" then
              config.settings.python.pythonPath = venv .. "/bin/python"
            end
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                -- Analyze the whole workspace, not just open files.
                diagnosticMode = "workspace",
                -- Suggest functions/classes from anywhere in the project and
                -- insert the matching import when the completion is accepted.
                autoImportCompletions = true,
              },
            },
          },
        },
      },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "python", "lua", "go", "gomod", "gosum" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- フォーマッター
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "black", "isort" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end
  },

  -- Linter
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        python = { "ruff" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end
  },
}
