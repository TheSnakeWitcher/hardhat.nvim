local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
    vim.notify("hardhat.nvim requires nvim-telescope/telescope.nvim")
    return
end

local hardhat_pickers = require("hardhat.pickers")


return telescope.register_extension({
    exports = {
        networks = hardhat_pickers.networks,
        deploy = hardhat_pickers.deploy,
        deployments = hardhat_pickers.deployments,
        verify = hardhat_pickers.verify,
        scripts = hardhat_pickers.scripts,
    },
})
