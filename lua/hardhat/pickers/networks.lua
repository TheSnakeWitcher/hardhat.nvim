local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local themes = require("telescope.themes")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local actions_utils = require("telescope.actions.utils")
local make_entry = require("telescope.make_entry")

local hardhat_networks = require("hardhat.networks")


local M = {}


local function hardhat_networks_mappings(prompt_bufnr, map)
    actions.select_default:replace(function()
        local networks = {}
        actions_utils.map_selections(prompt_bufnr, function(entry, _)
            table.insert(networks, entry.value)
        end)
	    actions.close(prompt_bufnr)

        if #networks < 1 then
	        local network = actions_state.get_selected_entry().value
	        return network
        else
	        return networks
        end
	end)

    return true
end

M.hardhat_networks_picker_base = function(opts, mappings)
    opts = opts or {}
    pickers.new(themes.get_dropdown(), {
        prompt_title = "hardhat networks",
        finder = finders.new_table({
            results = hardhat_networks.get_networks(),
            entry_maker = make_entry.gen_from_string(opts),
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = mappings,
    }):find()
end

M.hardhat_networks_picker = function(opts)
    M.hardhat_networks_picker_base(opts, hardhat_networks_mappings)
end


return M
