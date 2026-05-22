-- blink.cmp の補完をトグル可能にする
return {
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      if vim.g.cmp_enabled == false then
        return false
      end
      if vim.bo.filetype == "markdown" then
        return false
      end
      return true
    end,
  },
}
