local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local themes = require("telescope.themes")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

local util = require("hardhat.util")
local hardhat_ignition = require("hardhat.ignition")
local hardhat_deploy = require("hardhat.deploy")


local M = {}


M.hardhat_deployments_picker_base = function(opts, deployment_finder, mappings)
    opts = vim.tbl_deep_extend("force", opts or {}, themes.get_dropdown())

    local deployment_finder_fn, deployment_finder_args
    if type(deployment_finder) == "table" then

        deployment_finder_fn = deployment_finder[1]
        deployment_finder_args = deployment_finder[2]

    elseif type(deployment_finder) == "function" then

        deployment_finder_fn = deployment_finder
        deployment_finder_args = nil

    end

    pickers.new( opts , {
        prompt_title = "hardhat deployments",
        finder = finders.new_table({
            results = deployment_finder_fn(deployment_finder_args),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format(" %s %s: %s", entry.chain_id, entry.deployment_id, entry.address),
                    ordinal = entry.deployment_id
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = mappings,
    }):find()
end


M.hardhat_deployments_picker = function(opts)
    opts = opts or {}
    util.check_deploy_system_and_do(
        function()
            M.hardhat_deployments_picker_base(opts, hardhat_ignition.get_deployments, function(prompt_bufnr)
                actions.select_default:replace(function()
                    local deployment = actions_state.get_selected_entry()
                    vim.notify(string.format("deployment id: %s", deployment.value.address))
                    actions.close(prompt_bufnr)
                end)
                return true
            end)
        end,
        function()
            M.hardhat_deployments_picker_base(opts, hardhat_deploy.get_deployments, function(prompt_bufnr)
                actions.select_default:replace(function()
                    local deployment = actions_state.get_selected_entry()
                    vim.notify(string.format("deployment id: %s", deployment.value.address))
                    actions.close(prompt_bufnr)
                end)
                return true
            end)

        end
    )
end


return M
