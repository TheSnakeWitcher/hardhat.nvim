local scripts = require("hardhat.scripts")


local M = {}


M.get_deploy_scripts = function()
    return scripts.run("hh-deploy-scripts")
end


return M
