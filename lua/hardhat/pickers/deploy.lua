local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")

local Job = require("plenary.job")

local config = require("hardhat.config")
local hardhat_util = require("hardhat.util")
local hardhat_ignition = require("hardhat.ignition")
local hardhat_deploy = require("hardhat.deploy")
local hardhat_networks_picker_base = require("hardhat.pickers.networks").hardhat_networks_picker_base


local M = {}


local function get_entry_and_close_buf(prompt_bufnr)
	local entry = actions_state.get_selected_entry().value
	actions.close(prompt_bufnr)
	return entry
end

local function hardhat_ignition_mappings(top_prompt_bufnr, _)
    actions.select_default:replace(function()

        local deploy_module = get_entry_and_close_buf(top_prompt_bufnr)

        hardhat_networks_picker_base({}, function(prompt_bufnr)

            actions.select_default:replace(function()

                -- TODO: add support for multiple networks
                -- local networks = {}
                -- actions_utils.map_selections(prompt_bufnr, function(entry, _)
                --     table.insert(networks, entry.value)
                -- end)

                local network = get_entry_and_close_buf(prompt_bufnr)

                vim.notify(string.format("deploying %s using network %s", deploy_module, network))
                Job:new({
                    command = config.package_manager,
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

local function hardhat_deploy_mappings(top_prompt_bufnr, _)
    actions.select_default:replace(function()

        local contract = get_entry_and_close_buf(top_prompt_bufnr)
        hardhat_networks_picker_base({}, function(prompt_bufnr)

            actions.select_default:replace(function()
                local network = get_entry_and_close_buf(prompt_bufnr)

                vim.notify(string.format("deploying %s using network %s", contract, network))
                Job:new({
                    command = config.package_manager,
                    args = { "hardhat", "deploy", "--tags", contract, "--network", network },
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
    local prompt_title = "hardhat deploy"

    hardhat_util.check_deploy_system_and_do(
        function()
            return pickers.new(opts, {
                prompt_title =prompt_title,
                finder = finders.new_table({
                    results = hardhat_ignition.get_modules(),
                    entry_maker = make_entry.gen_from_file(opts),
                }),
                sorter = conf.file_sorter(opts),
                previewer = conf.file_previewer(opts),
                attach_mappings = hardhat_ignition_mappings,
            }):find()
        end,
        function()
            return pickers.new(opts, {
                prompt_title = prompt_title,
                finder = finders.new_table({
                    results = hardhat_deploy.get_deploy_scripts(),
                    entry_maker = make_entry.gen_from_string(opts),
                }),
                sorter = conf.file_sorter(opts),
                previewer = conf.file_previewer(opts),
                attach_mappings = hardhat_deploy_mappings,
            }):find()
        end
    )
end


return M
