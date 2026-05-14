return {
  {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = "VeryLazy",
    opts = {
      editor = {
        client = "neovim",
        tooltip = "Neovim",
      },
      display = {
        theme = "default",
        flavor = "dark",
      },
      timestamp = {
        enabled = true,
        reset_on_idle = false,
        reset_on_change = false,
      },
      idle = {
        enabled = true,
        timeout = 300000,
        show_status = true,
        details = "Idling",
        state = nil,
        tooltip = "Zzz",
      },
      text = {
        viewing = function(opts)
          return "Viewing " .. opts.filename
        end,
        editing = function(opts)
          return "Editing " .. opts.filename
        end,
        file_browser = function(opts)
          return "Browsing files in " .. opts.tooltip
        end,
        plugin_manager = function(opts)
          return "Managing plugins in " .. opts.tooltip
        end,
        workspace = function(opts)
          return "In " .. opts.workspace
        end,
      },
      buttons = nil,
      assets = nil,
    },
  },
}
