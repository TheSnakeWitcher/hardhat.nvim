local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

local Job = require("plenary.job")

local config = require("hardhat.config")
local util = require("hardhat.util")
local pickers_util = require("hardhat.util.pickers")
local hardhat_ignition = require("hardhat.ignition")
local hardhat_deploy = require("hardhat.deploy")
local hardhat_deployments_picker_base = require("hardhat.pickers.deployments").hardhat_deployments_picker_base
local hardhat_networks_picker_base = require("hardhat.pickers.networks").hardhat_networks_picker_base


local M = {}


local function hardhat_verify_ignition_picker(opts)
    hardhat_networks_picker_base({}, function(top_prompt_bufnr)
        actions.select_default:replace(function()

            local network = pickers_util.get_entry_and_close_buf(top_prompt_bufnr)
            hardhat_deployments_picker_base(opts, hardhat_ignition.get_deployments, function(top_prompt_bufnr)
                actions.select_default:replace(function()

                    local deployment_id = pickers_util.get_entry_and_close_buf(top_prompt_bufnr).deployment_id
	                vim.notify(string.format("verifying %s using netowrk %s", deployment_id, network))
                    Job:new({
                        command = config.package_manager, args = { "hardhat", "--network", network, "ignition", "verify", deployment_id },
                        cwd = util.get_root(),
                        on_exit = function(job,_) vim.notify(job:result()) end,
                    }):start()
                end)

                return true
            end)
        end)

        return true
    end)
end


local function hardhat_verify_deploy_picker(opts)
    hardhat_networks_picker_base({}, function(top_prompt_bufnr)
        actions.select_default:replace(function()

            local selected_network = pickers_util.get_entry_and_close_buf(top_prompt_bufnr)
            hardhat_deployments_picker_base(opts, { hardhat_deploy.get_chain_deployments, selected_network }, function(prompt_bufnr)
                actions.select_default:replace(function()

                    local deployments = pickers_util.get_entries_and_close_buf(prompt_bufnr)
                    pickers_util.do_with_pairs({ selected_network }, deployments, function(network, deployment)
	                    vim.notify(string.format("verifying %s using netowrk %s", deployment.deployment_id, network))
                        Job:new({
                            command = config.package_manager,
                            args = vim.list_extend({ "hardhat", "--network", network, "verify", deployment.address }, deployment.args ),
                            cwd = util.get_root(),
                            on_exit = function(job,_) vim.notify(job:result()) end,
                        }):start()
                    end)

                end)

                return true
            end)
        end)

        return true
    end)
end

M.hardhat_verify_picker = function (opts)
    opts = opts or {}
    util.check_deploy_system_and_do(
        hardhat_verify_ignition_picker,
        hardhat_verify_deploy_picker
    )
end


return M
