local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
    vim.notify("hardhat.nvim requires nvim-telescope/telescope.nvim")
    return
end

local hardhat_pickers = require("hardhat.pickers")


return telescope.register_extension({
    exports = {
        deploy = hardhat_pickers.deploy,
        networks = hardhat_pickers.networks,
        deployments = hardhat_pickers.deployments,
        verify = hardhat_pickers.verify,

        -- TODO: add pickers for these
        -- run = {},       -- find and run task
        -- export = {},    -- find and export deployments with hardhat-verify
        -- sourcify = {},  -- find and verify deployed contracts with sourcify
    },
})
