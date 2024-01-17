local Path = require("plenary.path")
local util = require("hardhat.util")


local M = {}


M.get_networks = function ()
    local hardhat_config_filename, lang = util.get_hardhat_config_file()
    if not hardhat_config_filename then return {} end
    local hardhat_config = Path:new(hardhat_config_filename):read()

    local query_name = "hardhat-networks"
    local languaje_tree = vim.treesitter.get_string_parser(hardhat_config, lang):parse()
    local tree = languaje_tree[1]
    local tree_root = tree:root()
    local query = vim.treesitter.query.get(lang, query_name)

    local networks = {}
    for id, node, metadata in query:iter_captures(tree_root, hardhat_config) do
        if query.captures[id] == "networkName" then
            local network = vim.treesitter.get_node_text(node, hardhat_config)
            table.insert(networks, network)
        end
    end
    return networks
end


return M
