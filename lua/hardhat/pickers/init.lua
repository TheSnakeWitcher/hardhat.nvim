local M = {}


M.networks = require("hardhat.pickers.networks").hardhat_networks_picker
M.deploy = require("hardhat.pickers.deploy").hardhat_deploy_picker
M.deployments = require("hardhat.pickers.deployments").hardhat_deployments_picker
M.verify = require("hardhat.pickers.verify").hardhat_verify_picker
M.scripts = require("hardhat.pickers.scripts").hardhat_scripts_picker


return M
