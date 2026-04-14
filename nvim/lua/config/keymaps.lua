-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap

-- Increment/decrement
keymap.set("n", "+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "-", "<C-x>", { desc = "Decrement number" })

-- Delete a word backwards
keymap.set("n", "dw", "vb_d", { desc = "Delete word backward" })

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", { noremap = true, silent = true, desc = "Jump forward" })

-- New tab
keymap.set("n", "te", ":tabedit ", { desc = "New tab" })
keymap.set("n", "<tab>", ":tabnext<Return>", { noremap = true, silent = true, desc = "Next tab" })
keymap.set("n", "<s-tab>", ":tabprev<Return>", { noremap = true, silent = true, desc = "Previous tab" })

-- Split window
keymap.set("n", "ss", ":split<Return>", { noremap = true, silent = true, desc = "Split horizontal" })
keymap.set("n", "sv", ":vsplit<Return>", { noremap = true, silent = true, desc = "Split vertical" })

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><", { desc = "Shrink window width" })
keymap.set("n", "<C-w><right>", "<C-w>>", { desc = "Grow window width" })
keymap.set("n", "<C-w><up>", "<C-w>+", { desc = "Grow window height" })
keymap.set("n", "<C-w><down>", "<C-w>-", { desc = "Shrink window height" })

-- Work set (3-column layout)
keymap.set("n", "tt", function()
  local is_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "snacks_picker_list" then
      is_open = true
      break
    end
  end

  if not is_open then
    Snacks.explorer()
  end

  vim.schedule(function()
    vim.cmd("botright vsplit | terminal")
    vim.cmd("vertical resize 50")
    vim.cmd("startinsert")
  end)
end, { desc = "3-column layout (Explorer + Editor + Terminal)" })

-- Terminal exit
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Terminal window navigation
keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { noremap = true, silent = true, desc = "Next diagnostic" })

-- Show all custom keymaps
keymap.set("n", "<leader>?", function()
  Snacks.picker.keymaps({ filter = { "" } })
end, { desc = "Show all keymaps" })
