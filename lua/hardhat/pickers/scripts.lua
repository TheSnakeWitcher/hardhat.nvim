local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")

local overseer = require("overseer")

local config = require("hardhat.config")
local util = require("hardhat.util")
local pickers_util = require("hardhat.util.pickers")

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
        attach_mappings = function (prompt_bufnr, map)
            actions.select_default:replace(function()
                local scripts = pickers_util.get_entries_and_close_buf(prompt_bufnr)
                vim.iter(scripts):each(function (script)
                    local task = overseer.new_task({
                        cmd = config.package_manager,
                        args =  { "hardhat","run", script },
                        name = string.format("hardhat script %s", vim.fs.basename(script) ),
                        cwd = util.get_root(),
                    })
                    overseer.run_action(task, "start")
                end)
	        end)
            return true
        end
    }):find()
end


return M
