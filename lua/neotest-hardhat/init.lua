local lib = require("neotest.lib")
local logger = require("neotest.logging")
local util = require("neotest-hardhat.util")


--- @class neotest.Adapter
local adapter = { name = "neotest-hardhat" }

--- @param path string
adapter.root = function(path)
    return lib.files.match_root_pattern("hardhat.config.js", "hardhat.config.ts")(path)
end

--- @param name string
--- @param rel_path string
--- @param root string
--- @return boolean
function adapter.filter_dir(name, rel_path, root)
    return name == "test"
end

--- @param file_path? string
--- @return boolean
function adapter.is_test_file(file_path)
    if file_path == nil then return false end
    return string.match(file_path, "test/.+%.ts$") ~= nil
end

---@async
---@return neotest.Tree | nil
function adapter.discover_positions(path)
    local query_file = vim.treesitter.query.get_files("typescript", "hardhat-tests")[1]
    local success, query = pcall(lib.files.read, query_file)
    if not success then
        logger.error("Could not read hardhat tests queries")
        return {}
    end

    local tree = lib.treesitter.parse_positions(path, query, { require_namespaces = true, nested_tests = true })
    return tree
end

--- @param args neotest.RunArgs
--- @return neotest.RunSpec | nil
function adapter.build_spec(args)

    local tree = args.tree
    local node = tree:data()
    local root = adapter.root(node.path)

    if not util.check_hardhat_neovim_plugin_installed(root) then return {} end

    return {
        command = util.get_command(node, root),
        cwd = root,
    }

end

--- @async
--- @param spec neotest.RunSpec
--- @return neotest.Result[]
function adapter.results(spec, result, tree)
    local success, data = pcall(lib.files.read, result.output)
    if not success then
        logger.error("Could not read from hardhat stdout")
        return {}
    end

    return util.parse_results(data, tree, spec)
end

setmetatable(adapter, {
    __call = function(tbl, opts)
        return adapter
    end,
})

return adapter
