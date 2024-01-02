local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
    vim.notify("hardhat.nvim requires nvim-telescope/telescope.nvim")
    return
end

local has_plenary, Job = pcall(require, "plenary.job")
if not has_plenary then
    vim.notify("hardhat.nvim requires plenary")
    return
end


local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local themes = require("telescope.themes")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local actions_utils = require("telescope.actions.utils")
local make_entry = require("telescope.make_entry")

local hardhat_ignition = require("hardhat.ignition")
local hardhat_networks = require("hardhat.networks")
local hardhat_util = require("hardhat.util")


local hardhat_networks_mappings = function(prompt_bufnr, map)
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

local hardhat_networks_picker_base = function(opts, mappings)
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

local hardhat_networks_picker = function(opts)
    hardhat_networks_picker_base(opts, hardhat_networks_mappings)
end

local hardhat_deploy_mappings = function(top_prompt_bufnr, map)
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

local hardhat_deploy_picker = function(opts)
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

local hardhat_deployments_picker_base = function(opts, mappings)
    opts = opts or {}
    pickers.new(themes.get_dropdown(), {
        prompt_title = "hardhat ignition deployments",
        finder = finders.new_table({
            results = hardhat_ignition.list_deployments(),
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

local function hardhat_deployments_picker(opts)
    hardhat_deployments_picker_base(opts, function(prompt_bufnr)
        actions.select_default:replace(function()
            local deployment = actions_state.get_selected_entry()
            vim.notify(string.format("deployment id: %s", deployment.value.deployment_id))
            actions.close(prompt_bufnr)
        end)
        return true
    end)
end

local function hardhat_verify_picker(opts)
    hardhat_deployments_picker_base(opts, function(prompt_bufnr)
        actions.select_default:replace(function()

            local deployment_id = actions_state.get_selected_entry().value.deployment_id
	        vim.notify("veifying " .. deployment_id)
	        actions.close(prompt_bufnr)

            Job:new({
                command = "pnpm",
                args = { "hardhat","ignition", "verify", deployment_id},
                cwd = hardhat_util.get_root(),
                on_exit = function(job,_) vim.notify(job:result()) end,
            }):start()
        end)

        return true
    end)
end


return telescope.register_extension({
    exports = {
        deploy = hardhat_deploy_picker,
        networks = hardhat_networks_picker,
        deployments = hardhat_deployments_picker,
        verify = hardhat_verify_picker,

        -- TODO: add pickers for these
        -- run = {},       -- find and run task
        -- export = {},    -- find and export deployments with hardhat-verify
        -- sourcify = {},  -- find and verify deployed contracts with sourcify
    },
})
