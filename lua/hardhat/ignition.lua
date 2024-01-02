local scan = pcall(require,'plenary.scandir')
local util = require("hardhat.util")


local M = {}


M.get_deployments_path = function()
    local root = util.get_root()
    return string.format("%s/ignition/deployments", root)
end


M.list_modules = function()
    local root = util.get_root()
    local modules_dir = string.format("%s/ignition/modules", root)
    return scan.scan_dir(modules_dir, {})
end

M.get_chain_deployments = function (deployments_dir, chain_dir)
    local results = {}
    local chain_id = vim.split(chain_dir, "-")[2]

    local file = io.open(string.format("%s/%s/deployed_addresses.json", deployments_dir, chain_dir))
    if not file then return {} end

    local deployments_json = file:read("*a")
    if not deployments_json then return {} end

    local file_closed = file:close()
    if not file_closed then vim.notify("error closing file") end

    local deployments = vim.json.decode(deployments_json)
    if not deployments then return {} end

    for deployment_id, address in pairs(deployments) do
        table.insert(results, {
            chain_id = chain_id,
            deployment_id = deployment_id,
            address = address
        })
    end

    return results
end

M.list_deployments = function()
    local deployments = {}
    local deployments_dir = M.get_deployments_path()
    for chain_dir in vim.fs.dir(deployments_dir) do
        local chain_deployments = M.get_chain_deployments(deployments_dir, chain_dir)
        vim.list_extend(deployments, chain_deployments)
    end
    return deployments
end


return M
