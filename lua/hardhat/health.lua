local util = require("hardhat.util")


local M = {}


--- @param condition boolean
--- @param ok_msg string
--- @param err_msg string
local function check_condition(condition, ok_msg, err_msg)
    if condition then
        vim.health.report_ok(ok_msg)
    else
        vim.health.report_error(err_msg)
    end
end

--- @param module string
local function check_module(module)
    local module_installed = package.loaded[module] and true or false
    check_condition(
        module_installed,
        module .. " installed",
        module .. " is requried"
    )
end

--- @param modules string[]
local function check_modules(modules)
    for _, module in ipairs(modules) do
        check_module(module)
    end
end

M.check = function()
    vim.health.report_start("hardhat.nvim report")

    check_condition(
        util.js_package_manager_exists(),
        "js package manager installed",
        "js package manager required"
    )
    check_modules({"plenary", "telescope", "overseer"})
end


return M
