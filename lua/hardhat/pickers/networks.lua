local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local themes = require("telescope.themes")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local make_entry = require("telescope.make_entry")

local hardhat_networks = require("hardhat.networks")
local pickers_util = require("hardhat.util.pickers")


local M = {}


local function hardhat_networks_mappings(prompt_bufnr, map)
    actions.select_default:replace(function()
        return pickers_util.get_entries_and_close_buf(prompt_bufnr)
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
