local scripts = require("hardhat.scripts")
local Path = require("plenary.path")


local M = {}


M.get_deploy_scripts = function()
    return scripts.run("hh-deploy-scripts")
end

M.get_deployments_path = function()
    return scripts.run("hh-paths").deployments
end

local function get_chain_deployments(chain_deployments_dir)
    local results = {}
    local chain_id_filename = ".chainId"
    local chain_id = Path:new(chain_deployments_dir):joinpath(chain_id_filename):read()

    for deployment, type in vim.fs.dir(chain_deployments_dir, {depth = 1}) do
        if type == "file" and deployment ~= chain_id_filename then

            local deployment_id = vim.split(deployment, ".json")[1]
            local deployment_json = Path:new(chain_deployments_dir):joinpath(deployment):read()
            local deployment_content = vim.json.decode(deployment_json)
            if not deployment_content then return {} end

            table.insert(results, {
                chain_id = chain_id,
                deployment_id = deployment_id,
                address = deployment_content.address,
                args = deployment_content.args,
            })
        end
    end
    return results
end

M.get_chain_deployments = function(network)
    local deployments_dir = M.get_deployments_path()
    local chain_deployments_dir = Path:new(deployments_dir):joinpath(network)

    if not chain_deployments_dir:exists() then
        return {}
    end

    return get_chain_deployments(chain_deployments_dir:expand())
end

M.get_deployments = function()
    local deployments = {}
    local deployments_dir = M.get_deployments_path()
    for chain_dir in vim.fs.dir(deployments_dir) do
        local chain_deployments_dir = string.format("%s/%s", deployments_dir, chain_dir)
        local chain_deployments = get_chain_deployments(chain_deployments_dir)
        vim.list_extend(deployments, chain_deployments)
    end
    return deployments
end

return M
