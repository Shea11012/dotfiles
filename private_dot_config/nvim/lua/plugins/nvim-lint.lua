return {
    "mfussenegger/nvim-lint",
    specs = {
        { "jay-babu/mason-null-ls.nvim", optional = true, opts = { methods = { diagnostics = false } } }
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require"lint"
        lint.linters_by_ft = {
            go = {"golangcilint"},
            javascript = { "biomejs"},
            javascriptreact = {"biomejs"},
            typescript = { "biomejs"},
            typescriptreact = {"biomejs"},
            json = {"biomejs"},
            vue = {"biomejs"},
            lua = {"selene"},
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", {clear = true})
        vim.api.nvim_create_autocmd({"BufReadPost","BufWritePost","InsertLeave"}, {
            group = lint_augroup,
            callback = function ()
                lint.try_lint()
            end
        })
    end,
}
