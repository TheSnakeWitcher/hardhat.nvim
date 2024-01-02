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

M.check = function()
    vim.health.report_start("hardhat.nvim report")

    local js_package_manager_exists = util.js_package_manager_exists()
    local plenary_installed =  package.loaded.plenary and true or false

    check_condition(js_package_manager_exists, "pnpm or yarn or npm are installed", "pnpm,or yarn or npm are required")
    check_condition(plenary_installed, "plenary installed", "plenary is requried")

end


return M
