local Job = require("plenary.job")


local M = {}


M.items = {
    CONTRACT = "contract",
    LIBRARY = "library",
    INTERFACE = "interface",
}

M.deploy_systems_tasks = {
    HARDHAT_IGNITION = "ignition",
    HARDHAT_DEPLOY = "deploy"
}

--- @return string|nil hardhat_config_file
--- @return string|nil hardhat_config_filetype
M.get_hardhat_config_file = function()
    local root = vim.loop.cwd()
    local opts = { upward = true, stop = root, type = "file" }
    local hardhat_config_file = "hardhat.config"

    local ts_results = vim.fs.find(hardhat_config_file .. ".ts", opts)
    if #ts_results == 1 then
        return ts_results[1] , "typescript"
    end

    local js_results = vim.fs.find(hardhat_config_file .. ".js", opts)
    if #js_results == 1 then
        return js_results[1] , "javascript"
    end

    return nil, nil
end

--- @return boolean exists
--- @return string|nil hardhat_config_file
M.check_hardhat_config_file_exists = function()
    local hardhat_config_file = M.get_hardhat_config_file()
    if hardhat_config_file then
        return true, hardhat_config_file
    else
        return false, nil
    end
end

--- @return string root
M.get_root = function()
    local hardhat_config_file = M.get_hardhat_config_file()
    return vim.fs.dirname(hardhat_config_file)
end

--- @return string contracts_path
M.get_contracts_path = function()
    local root = M.get_root()
    return string.format("%s/contracts", root)
end


M.get_js_package_manager = function()
    local package_managers = { "pnpm", "yarn", "npm" }
    for _, package_manager in ipairs(package_managers) do
        if vim.fn.executable(package_manager) then
            return package_manager
        end
    end
end

M.check_js_package_manager_exists = function()
    local package_manager = M.get_js_package_manager()
    if not package_manager then
        return false
    else
        return true
    end

end

M.rg_query_files = function(query, path)
    local results = {}
    Job:new({
        command = 'rg',
        args = { "-e", query, "-t", "solidity", "--only-matching", path },
        on_exit = function(job) results =  job:result() end
    }):sync()
    return results
end

M.get_item = function(query, path)
    local results = M.rg_query_files(query .. " \\w+", path)
    local contracts = vim.tbl_map(function(result)
        local item_name = vim.split(result, query .. " ")[2]
        return item_name
    end, results)
    return contracts
end

--- @return string|nil package_json
M.get_package_json = function()
    local root = M.get_root()
    local package_json_path = string.format("%s/package.json", root)

    local package_json_file = io.open(package_json_path)
    local package_json = package_json_file:read("*a")
    package_json_file:close()

    local content = vim.json.decode(package_json)
    return content
end

--- @param plugin string 
--- @param version ?string 
--- @return boolean plugin_exists
M.check_plugin_installed = function(plugin)
    local out = vim.fn.system(string.format("pnpm hardhat %s", plugin))
    if vim.startswith(out, 'Error') then
        return false
    else
        return true
    end
end

--- @return table|nil callback_results
M.check_deploy_system_and_do = function(hh_ignition_callback, hh_deploy_callback)
    local hardhat_ignition = M.deploy_systems_tasks.HARDHAT_IGNITION
    local hardhat_deploy = M.deploy_systems_tasks.HARDHAT_DEPLOY

    if M.check_plugin_installed(hardhat_ignition) then
        return hh_ignition_callback()
    elseif M.check_plugin_installed(hardhat_deploy) then
        return hh_deploy_callback()
    else
        return nil
    end
end


return M
