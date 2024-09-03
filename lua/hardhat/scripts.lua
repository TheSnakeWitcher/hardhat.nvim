local config = require("hardhat.config")
local util = require("hardhat.util")


local M = {}


--- @param script_name string 
--- @return table results
M.run = function(script_name)
    local script = string.format("scripts/%s.ts", script_name)
    local script_path = vim.api.nvim_get_runtime_file(script, false)[1]

    local encoded_results = vim.fn.system(string.format("%s hardhat run %s",config.package_manager, script_path))
    local results = vim.json.decode(encoded_results)

    if not results then
        vim.notify("no results return from script")
        return {}
    else
        return results
    end
end

--- @return table results
M.get = function()
    local scripts_dir = vim.fs.joinpath(util.get_root(), 'scripts')

    return vim.iter(vim.fs.dir(scripts_dir))
        :map(function(script)
            return vim.fs.joinpath(scripts_dir, script)
        end)
        :totable()
end

return M
