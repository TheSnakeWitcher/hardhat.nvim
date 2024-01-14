local hardhat_cli = require("hardhat.cli")
local util = require("hardhat.util")


local hardhat_group = vim.api.nvim_create_augroup("Hardhat", { clear = false })

vim.api.nvim_create_autocmd("LspAttach", {
    group = hardhat_group,
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if vim.tbl_contains(client.config.filetypes, "solidity")
            and util.hardhat_config_file_exists()
        then
            vim.schedule(hardhat_cli.refresh_completion)
        end
    end,
})
