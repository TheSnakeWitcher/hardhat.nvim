require("hardhat.cmds")
local config = require("hardhat.config")
local util = require("hardhat.util")


local M = {}


M.ns = vim.api.nvim_create_namespace("Hardhat")

M.setup = function(opts)
    config.setup(opts or {})
end


M.get_contracts = function()
    return util.get_item(
        util.items.contract,
        util.get_contracts_path()
    )
end

M.get_libraries = function()
    return util.get_item(
        util.items.library,
        util.get_contracts_path()
    )
end

M.get_interfaces = function()
    return util.get_item(
        util.items.interface ,
        util.get_contracts_path()
    )
end


return M
