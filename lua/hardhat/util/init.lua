local M = {}


M.get_hardhat_config_file = function()
    local root = vim.loop.cwd()

    local hardhat_config_ts_file = string.format("%s/hardhat.config.ts", root)
    if vim.fn.filereadable(hardhat_config_ts_file) then
        return hardhat_config_ts_file, "typescript"
    end

    local hardhat_config_js_file = string.format("%s/hardhat.config.js", root)
    if vim.fn.filereadable(hardhat_config_js_file) then
        return hardhat_config_js_file , "javascript"
    end

    return nil, nil
end

M.get_js_package_manager = function()
    local package_managers = { "pnpm", "yarn", "npm" }
    for _, package_manager in ipairs(package_managers) do
        if vim.fn.executable(package_manager) then
            return package_manager
        end
    end
end

M.js_package_manager_exists = function()
    local package_manager = M.get_js_package_manager()
    if not package_manager then
        return false
    else
        return true
    end

end


return M
