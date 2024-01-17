local scan = require("plenary.scandir")
local util = require("hardhat.util")
local Path = require("plenary.path")


local M = {}


M.get_deployments_path = function()
    local root = util.get_root()
    return string.format("%s/ignition/deployments", root)
end


M.get_modules = function()
    local root = util.get_root()
    local modules_dir = string.format("%s/ignition/modules", root)
    return scan.scan_dir(modules_dir, {})
end

M.get_chain_deployments = function (deployments_dir, chain_dir)
    local results = {}
    local chain_id = vim.split(chain_dir, "-")[2]

    local deployments_json = Path:new(deployments_dir):joinpath(chain_dir, "deployed_addresses.json"):read()
    if not deployments_json then return {} end

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

M.get_deployments = function()
    local deployments = {}
    local deployments_dir = M.get_deployments_path()
    for chain_dir in vim.fs.dir(deployments_dir) do
        local chain_deployments = M.get_chain_deployments(deployments_dir, chain_dir)
        vim.list_extend(deployments, chain_deployments)
    end
    return deployments
end


return M
