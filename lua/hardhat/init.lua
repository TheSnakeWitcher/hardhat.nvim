require("hardhat.cmds")

local config = require("hardhat.config")
local util = require("hardhat.util")
local scripts = require("hardhat.scripts")


local M = {}


M.setup = function(options)
    config.setup(options)
end

M.run_script = scripts.run

M.get_paths = function()
    return scripts.run("hh-paths")
end

M.get_contracts = function()
    return util.get_item(
        util.items.CONTRACT,
        util.get_contracts_path()
    )
end

M.get_libraries = function()
    return util.get_item(
        util.items.LIBRARY,
        util.get_contracts_path()
    )
end

M.get_interfaces = function()
    return util.get_item(
        util.items.INTERFACE ,
        util.get_contracts_path()
    )
end


return M
