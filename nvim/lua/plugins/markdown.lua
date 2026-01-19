return {
  -- Markdownプレビュー用プラグイン
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && npm install",
    config = function()
      -- GFM (GitHub Flavored Markdown) スタイルの改行を有効化
      vim.g.mkdp_preview_options = {
        breaks = true, -- これで改行がそのまま<br>になります
      }
      -- GFMモードを有効化
      vim.g.mkdp_markdown_css = ""
      vim.g.mkdp_page_title = "${name}"
      vim.g.mkdp_auto_close = 0 -- プレビュー終了時にブラウザを自動で閉じない

      -- ブラウザを明示的に指定
      if vim.fn.has("mac") == 1 then
        vim.g.mkdp_browser = "open" -- macOS
      elseif vim.fn.has("unix") == 1 then
        vim.g.mkdp_browser = "xdg-open" -- Linux
      elseif vim.fn.has("win32") == 1 then
        vim.g.mkdp_browser = "" -- Windows デフォルトブラウザ
      end

      -- その他の設定
      vim.g.mkdp_auto_start = 0 -- ファイルを開いたときに自動でプレビューを開かない
      vim.g.mkdp_open_to_the_world = 0 -- ローカルのみ
      vim.g.mkdp_port = "8080" -- ポート指定
      vim.g.mkdp_echo_preview_url = 1 -- プレビューURLをコマンドラインに表示
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview in Browser" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Stop Markdown Preview" },
    },
  },

  -- Markdown用の設定
  {
    "markdown-settings",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          -- スペルチェックを無効化
          vim.opt_local.spell = false

          -- その他のMarkdown用設定
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.conceallevel = 2

          -- PDF変換してブラウザで開く（Pandoc使用）
          vim.keymap.set("n", "<leader>pdf", function()
            local input = vim.fn.expand("%:p")
            local output = vim.fn.expand("%:p:r") .. ".pdf"

            -- PDF生成（日本語対応）
            local cmd = string.format(
              "pandoc %s -o %s --pdf-engine=xelatex -V CJKmainfont='Hiragino Sans'",
              vim.fn.shellescape(input),
              vim.fn.shellescape(output)
            )

            print("Generating PDF...")
            local result = vim.fn.system(cmd)

            if vim.v.shell_error ~= 0 then
              print("Error generating PDF: " .. result)
              return
            end

            -- ブラウザで開く
            if vim.fn.has("mac") == 1 then
              vim.fn.system("open " .. vim.fn.shellescape(output))
            elseif vim.fn.has("unix") == 1 then
              vim.fn.system("xdg-open " .. vim.fn.shellescape(output))
            elseif vim.fn.has("win32") == 1 then
              vim.fn.system("start " .. vim.fn.shellescape(output))
            end

            print("PDF generated and opened: " .. output)
          end, { buffer = true, desc = "Convert to PDF and open in browser" })
        end,
      })
    end,
  },
}
