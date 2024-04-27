local lib = require("neotest.lib")
local logger = require("neotest.logging")
local types = require("neotest.types")
local PositionType = types.PositionType

local M = {}

--- @param msg string
local function log_and_notify(msg)
    logger.error(msg)
    vim.notify(msg)
end

--- @param node neotest.Position
--- @param root string
--- @return string
M.get_command = function(node, root)

    if node.type == PositionType.dir and node.path == root then
        return string.format('pnpm hardhat test --neovim')
    elseif node.type == PositionType.dir then
        return string.format('pnpm hardhat test %s/** --neovim', node.path)
    elseif node.type == PositionType.file then
        return string.format("pnpm hardhat test %s --neovim", node.path)
    else
        return string.format('pnpm hardhat test %s --grep "%s" --neovim', node.path, node.name)
    end

end

--- @param root string
--- @return boolean
M.check_hardhat_neovim_plugin_installed = function(root)
    local hardhat_neovim_plugin_name = "hardhat-neovim" ;
    local package_json_file = "package.json" ;

    local success, package_json_content = pcall(lib.files.read, string.format("%s/%s", root, package_json_file))
    if not success then
        log_and_notify("Could not find " .. package_json_file)
        return true
    end

    local package_json = vim.json.decode(package_json_content)

    if package_json.devDependencies ~= nil and package_json.devDependencies[hardhat_neovim_plugin_name] then
        return true
    elseif package_json.dependencies ~= nil and package_json.dependencies[hardhat_neovim_plugin_name] then
        vim.notify(string.format("%s installed as dependency, try moving it to devDependencies", hardhat_neovim_plugin_name))
        return true
    end

    vim.notify(string.format("install %s plugin",hardhat_neovim_plugin_name))
    return false
end

--- @param msg string
--- These function will check if results start with an arbitrary
--- message before the actual JSON content
local function check_errors_in_msg(msg)
    local JSON_START_CHAR = '{'

    local msg_is_ok = vim.startswith(msg, JSON_START_CHAR)
    if msg_is_ok then
        return msg
    end

    local starts = string.find(msg, JSON_START_CHAR)
    return string.sub(msg, starts)
end

--- @return neotest.Result[]
M.parse_results = function(unparsed_data, tree, spec)
    local data = vim.json.decode(check_errors_in_msg(unparsed_data))
    if not data then
        log_and_notify("failed to parse data")
        return {}
    end
    return data.tests
end


return M
