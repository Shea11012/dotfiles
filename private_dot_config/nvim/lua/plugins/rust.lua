return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    lazy = false, -- This plugin is already lazy
    ft = "rust",
    config = function()
      vim.g.rustaceanvim = function()
        return {
          server = {
            on_attach = function(_, bufnr)
              vim.keymap.set(
                "n",
                "K",
                function() vim.cmd.RustLsp { "hover", "actions" } end,
                { desc = "Rust hover actions", buffer = bufnr }
              )

              vim.keymap.set(
                "n",
                "<leader>dr",
                function() vim.cmd.RustLsp { "debuggables", bang = true } end,
                { desc = "Rust debuggables", buffer = bufnr }
              )
            end,
          },
        }
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      local rustaceanvim_avail, rustaceanvim = pcall(require, "rustaceanvim.neotest")
      if rustaceanvim_avail then table.insert(opts.adapters, rustaceanvim) end
    end,
  },
}
