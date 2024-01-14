local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local themes = require("telescope.themes")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

local hardhat_ignition = require("hardhat.ignition")


local M = {}


M.hardhat_deployments_picker_base = function(opts, mappings)
    opts = opts or {}
    pickers.new(themes.get_dropdown(), {
        prompt_title = "hardhat ignition deployments",
        finder = finders.new_table({
            results = hardhat_ignition.get_deployments(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format(" %s %s: %s",entry.chain_id, entry.deployment_id, entry.address),
                    ordinal = entry.chain_id
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = mappings,
    }):find()
end

M.hardhat_deployments_picker = function(opts)
    M.hardhat_deployments_picker_base(opts, function(prompt_bufnr)
        actions.select_default:replace(function()
            local deployment = actions_state.get_selected_entry()
            vim.notify(string.format("deployment id: %s", deployment.value.deployment_id))
            actions.close(prompt_bufnr)
        end)
        return true
    end)
end


return M
