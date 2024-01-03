local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")

local Job = require("plenary.job")

local hardhat_ignition = require("hardhat.ignition")
local hardhat_networks_picker_base = require("hardhat.pickers.networks").hardhat_networks_picker_base
local hardhat_util = require("hardhat.util")


local M = {}


local function hardhat_deploy_mappings(top_prompt_bufnr, map)
    actions.select_default:replace(function()

	    local deploy_module = actions_state.get_selected_entry().value
	    vim.notify("deploying " .. deploy_module)
	    actions.close(top_prompt_bufnr)

        hardhat_networks_picker_base({}, function(prompt_bufnr)
            actions.select_default:replace(function()

                -- TODO: add support for multiple networks
                -- local networks = {}
                -- actions_utils.map_selections(prompt_bufnr, function(entry, _)
                --     table.insert(networks, entry.value)
                -- end)

	            local network = actions_state.get_selected_entry().value
	            actions.close(prompt_bufnr)
                vim.notify(network)

                Job:new({
                    command = "pnpm",
                    args = { "hardhat","ignition", "deploy", deploy_module, "--network", network },
                    cwd = hardhat_util.get_root(),
                    on_exit = function(job,_) vim.notify(job:result()) end,
                }):start()
            end)

            return true
        end)

	end)
    return true
end

M.hardhat_deploy_picker = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "hardhat ignition deploy modules",
        finder = finders.new_table({
            results = hardhat_ignition.list_modules(),
            entry_maker = make_entry.gen_from_file(opts),
        }),
        sorter = conf.file_sorter(opts),
        previewer = conf.file_previewer(opts),
        attach_mappings = hardhat_deploy_mappings,
    }):find()
end


return M
