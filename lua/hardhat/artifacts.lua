local util = require("hardhat.util")

local Path = require("plenary.path")


local M = {}


local LANG = "solidity"
local SOL_EXTENSION = ".sol"
local JSON_EXTENSION = ".json"
local DEBUG_EXTENSION = ".dbg" .. JSON_EXTENSION

M.get_artifacts_path = function()
    local root = util.get_root()
    return string.format("%s/artifacts", root)
end

M.get_contracts_artifacts_path = function()
    local artifacts_path = M.get_artifacts_path()
    return string.format("%s/contracts", artifacts_path)
end

M.get_buildinfo_path = function()
    local artifacts_path = M.get_artifacts_path()
    return string.format("%s/build-info", artifacts_path)
end

M.get_contract_buildinfo_filename = function(filename, contract)
    local contracts_artifacts_path = M.get_contracts_artifacts_path()
    local debug_file_path = Path:new(contracts_artifacts_path):joinpath(filename, contract .. DEBUG_EXTENSION)
    local debug_file = vim.json.decode(debug_file_path:read())
    return vim.fs.basename(debug_file.buildInfo)
end

M.get_contract_buildinfo = function(filename, contract)
    local buildinfo_path = M.get_buildinfo_path()
    local buildinfo_filename = M.get_contract_buildinfo_filename(filename, contract)
    local buildinfo = Path:new(buildinfo_path):joinpath(buildinfo_filename):read()
    return vim.json.decode(buildinfo)
end

M.get_contract_output_artifacts = function(filename, contract, source_path)
    local buildinfo = M.get_contract_buildinfo(filename, contract)
    local source = vim.split(filename, SOL_EXTENSION)[1]
    return buildinfo.output.contracts[source_path][source]
end

M.get_sources_output_artifacts = function(filename, contract, source_path)
    local buildinfo = M.get_contract_buildinfo(filename, contract)
    local source = vim.split(filename, SOL_EXTENSION)[1]
    return buildinfo.output.sources[source_path]
end

M.get_function_selectors = function(filename, contract, source_path)
    local artifacts = M.get_contract_output_artifacts(filename, contract, source_path)
    return artifacts.evm.methodIdentifiers
end

M.get_gas_estimates = function(filename, contract, source_path)
    local artifacts = M.get_contract_output_artifacts(filename, contract, source_path)
    return artifacts.evm.gasEstimates
end

M.get_contract_source = function(bufnr)
    local root = util.get_root()
    local source = Path:new(vim.api.nvim_buf_get_name(bufnr))
    local source_path = source:make_relative(root)
    local filename = vim.fs.basename(source:expand())

    local query = vim.treesitter.query.get(LANG, "contract")
    local tree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
    for _, node, _ in query:iter_captures(tree, bufnr) do
        local contract = vim.treesitter.get_node_text(node, bufnr)
        return filename, contract, source_path
    end
end

M.get_contract_gas_estimates = function(bufnr)
    local filename, contract, source_path = M.get_contract_source(bufnr)
    local artifacts = M.get_contract_output_artifacts(filename, contract, source_path)
    return artifacts.evm and artifacts.evm.gasEstimates
end


M.get_current_contract_source = function()
    local bufnr = vim.api.nvim_get_current_buf()
    return M.get_contract_source(bufnr)
end

M.get_current_contract_output_artifacts = function()
    local filename, contract, source_path = M.get_current_contract_source()
    return M.get_contract_output_artifacts(filename, contract, source_path)
end

M.get_current_sources_output_artifacts = function()
    local filename, contract, source_path = M.get_current_contract_source()
    return M.get_sources_output_artifacts(filename, contract, source_path)
end

M.get_current_contract_gas_estimates = function()
    local filename, contract, source_path = M.get_current_contract_source()
    return M.get_gas_estimates(filename, contract, source_path)
end

M.get_current_contract_function_selectors = function()
    local filename, contract, source_path = M.get_current_contract_source()
    return M.get_function_selectors(filename, contract, source_path)
end


M.get_functions_signature = function()
    local filename, contract, source_path = M.get_current_contract_source()
    return M.get_function_selectors(filename, contract, source_path)
end

local function get_function_attributes(bufnr, function_node)
    local query = vim.treesitter.query.get(LANG, "contract-functions-signature")

    local function_name
    local fn_gas_extmark_pos = {}
    local function_params_type = {}
    for id, node, metadata in query:iter_captures(function_node, bufnr) do

        if query.captures[id] == "functionName" then
            function_name = vim.treesitter.get_node_text(node, bufnr)
        elseif query.captures[id] == "paramType" then
            table.insert(
                function_params_type,
                vim.treesitter.get_node_text(node, bufnr)
            )
        elseif query.captures[id] == "functionBody" then
            local start_row, start_col = vim.treesitter.get_node_range(node)
            fn_gas_extmark_pos = {
                starts =  start_row,
                ends = start_col
            }
        end

    end

    local fn_signature = string.format(
        "%s(%s)",
        function_name,
        table.concat(function_params_type, ",")
    )

    return fn_signature, fn_gas_extmark_pos
end

--- These return signatures of only functions in buffer, not include the ones in the inheritance hierarchy
M.get_contract_function_signatures = function(bufnr)
    local query = vim.treesitter.query.get(LANG, "contract-functions")
    local tree = vim.treesitter.get_parser(bufnr, LANG):parse()[1]:root()
    local start_row = tree:start()
    local end_row = tree:end_()

    local function_attributes = {}
    for _, node, _ in query:iter_captures(tree, bufnr, start_row, end_row) do
        local fn_signature, fn_gas_extmark_pos = get_function_attributes(bufnr, node)
        function_attributes[fn_signature] = fn_gas_extmark_pos
    end
    return function_attributes
end

M.get_current_contract_function_signatures = function()
    local bufnr = vim.api.nvim_get_current_buf()
    return M.get_contract_function_signatures(bufnr)
end

return M
