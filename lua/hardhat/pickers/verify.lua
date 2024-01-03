local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

local Job = require("plenary.job")

local hardhat_util = require("hardhat.util")
local hardhat_deployments_picker_base = require("hardhat.pickers.deployments").hardhat_deployments_picker_base


local M = {}


M.hardhat_verify_picker = function (opts)
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


return M
