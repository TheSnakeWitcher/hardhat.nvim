local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")

local overseer = require("overseer")

local config = require("hardhat.config")
local util = require("hardhat.util")
local pickers_util = require("hardhat.util.pickers")
local hardhat_networks_picker_base = require("hardhat.pickers.networks").hardhat_networks_picker_base

local M = {}


M.hardhat_scripts_picker = function(opts)
    pickers.new(opts, {

        prompt_title = "hardhat scripts",
        finder = finders.new_table({
            results = require("hardhat.scripts").get(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = vim.fs.basename(entry),
                    ordinal = entry,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        previewer = conf.file_previewer(opts),
        attach_mappings = function(top_prompt_bufnr, map)
            actions.select_default:replace(function()

                local scripts = pickers_util.get_entries_and_close_buf(top_prompt_bufnr)
                hardhat_networks_picker_base({}, function(prompt_bufnr)
                    actions.select_default:replace(function()

                        local networks = pickers_util.get_entries_and_close_buf(prompt_bufnr)
                        pickers_util.do_with_pairs(networks, scripts, function(network, script)
                            overseer.new_task({
                                cmd = config.package_manager,
                                args =  { "hardhat", "run", script, "--network", network },
                                name = string.format("hardhat script %s in %s", vim.fs.basename(script), network),
                                cwd = util.get_root(),
                            }):start()
                        end)

	                end)
                    return true
	            end)

	        end)
            return true
        end

    }):find()
end


return M
