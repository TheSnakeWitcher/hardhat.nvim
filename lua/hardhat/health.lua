local util = require("hardhat.util")


local M = {}


--- @param condition boolean
--- @param ok_msg string
--- @param err_msg string
local function check_condition(condition, ok_msg, err_msg)
    if condition then
        vim.health.ok(ok_msg)
    else
        vim.health.error(err_msg)
    end
end

--- @param module string
local function check_module(module)
    local module_installed = package.loaded[module] and true or false
    check_condition(
        module_installed,
        module .. " installed",
        module .. " is required"
    )
end

M.check = function()
    vim.health.start("hardhat.nvim report")

    check_condition(
        util.check_js_package_manager_exists(),
        "js package manager installed",
        "js package manager required"
    )

    vim.iter({"plenary", "telescope", "overseer"}):map(check_module)
end


return M
