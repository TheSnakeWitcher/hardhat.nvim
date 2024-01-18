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

    pickers.new( opts , {
        prompt_title = "hardhat deployments",
        finder = finders.new_table({
            results = deployment_finder(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format(" %s %s: %s", entry.chain_id, entry.deployment_id, entry.address),
                    ordinal = entry.chain_id
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
                    vim.notify(string.format("deployment id: %s", deployment.value.deployment_id))
                    actions.close(prompt_bufnr)
                end)
                return true
            end)
        end,
        function()
            M.hardhat_deployments_picker_base(opts, hardhat_deploy.get_deployments, function(prompt_bufnr)
                actions.select_default:replace(function()
                    local deployment = actions_state.get_selected_entry()
                    vim.notify(string.format("deployment id: %s", deployment.value.deployment_id))
                    actions.close(prompt_bufnr)
                end)
                return true
            end)

        end
    )
end


return M
