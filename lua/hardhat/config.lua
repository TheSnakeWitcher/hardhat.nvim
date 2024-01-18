local util = require("hardhat.util")


local M = {}


M.namespace = vim.api.nvim_create_namespace("hardhat.nvim")

local defaults = {
    package_manager = util.get_js_package_manager(),
}

M.options = {}

setmetatable(M,{
    __index = function(tbl, k)
        if M.options[k] then
            return M.options[k]
        else
            return defaults[k]
        end
    end
})

M.setup = function(options)
    options = options or {}
    M.options = vim.tbl_deep_extend("force", defaults, options)
end


return M
