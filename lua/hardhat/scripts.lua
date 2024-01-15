local config = require("hardhat.config")


local M = {}


--- @param script_name string 
--- @return table paths
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


return M
