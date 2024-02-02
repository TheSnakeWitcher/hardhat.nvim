local util = require("hardhat.util")

local Path = require("plenary.path")


local M = {}


local LANG = "solidity"
local SOL_EXTENSION = ".sol"
local JSON_EXTENSION = ".json"
local DEBUG_EXTENSION = ".dbg" .. JSON_EXTENSION
local JSON_DECODE_OPTS = { luanil = { object = true, array = true } }

--- @return string artifacts_path
M.get_artifacts_path = function()
    local root = util.get_root()
    return string.format("%s/artifacts", root)
end

--- @return string buildinfo_path
M.get_buildinfo_path = function()
    local artifacts_path = M.get_artifacts_path()
    return string.format("%s/build-info", artifacts_path)
end

--- @param bufnr number
--- @return ContractInfo contract_info 
M.get_contract_info = function(bufnr)
    local root = util.get_root()
    local source = Path:new(vim.api.nvim_buf_get_name(bufnr))
    local source_path = source:make_relative(root)
    local filename = vim.fs.basename(source:expand())

    local query = vim.treesitter.query.get(LANG, "contract")
    local tree = vim.treesitter.get_parser(bufnr):parse()[1]:root()
    for _, node, _ in query:iter_captures(tree, bufnr) do
        local contract = vim.treesitter.get_node_text(node, bufnr)
        return {
            path = source_path,
            filename = filename,
            source = vim.split(filename, SOL_EXTENSION)[1],
            contract = contract,
        }
    end
end

--- @param contract_info ContractInfo
M.get_contract_buildinfo_filename = function(contract_info)
    local artifacts_path = M.get_artifacts_path()
    local debug_file_path = Path:new(artifacts_path):joinpath(
        contract_info.path,
        contract_info.contract .. DEBUG_EXTENSION
    )

    local debug_file = vim.json.decode(debug_file_path:read(), JSON_DECODE_OPTS)
    return vim.fs.basename(debug_file.buildInfo)
end

--- @param contract_info ContractInfo
--- @return table|nil buildinfo_filename
M.get_contract_buildinfo = function(contract_info)
    local buildinfo_path = M.get_buildinfo_path()
    local buildinfo_filename = M.get_contract_buildinfo_filename(contract_info)

    local buildinfo = Path:new(buildinfo_path):joinpath(buildinfo_filename)
    if not buildinfo:exists() then return nil end

    return vim.json.decode(buildinfo:read(), JSON_DECODE_OPTS)
end

--- @param contract_info ContractInfo
--- @return table|nil contract_output_artifacts
M.get_output_contract_artifacts = function(contract_info)
    local buildinfo = M.get_contract_buildinfo(contract_info)
    return buildinfo.output.contracts[contract_info.path][contract_info.source]
end

--- @return table|nil sources_output_artifacts
M.get_output_sources_artifacts = function(contract_info)
    local buildinfo = M.get_contract_buildinfo(contract_info)
    return buildinfo.output.sources[contract_info.path][contract_info.source]
end

--- @param contract_info ContractInfo
--- @return table|nil function_selectors
M.get_function_selectors = function(contract_info)
    local artifacts = M.get_output_contract_artifacts(contract_info)
    return artifacts.evm.methodIdentifiers
end

--- @param contract_info ContractInfo
--- @return table|nil gas_estimates
M.get_gas_estimates = function(contract_info)
    local artifacts = M.get_output_contract_artifacts(contract_info)
    return artifacts.evm.gasEstimates
end

--- @param contract_info ContractInfo
--- @return table|nil metadata
M.get_metadata = function(contract_info)
    local artifacts = M.get_output_contract_artifacts(contract_info)
    return artifacts.metadata
end

--- @return table|nil function_selectors
M.get_contract_function_selectors = function(bufnr)
    local contract_info = M.get_contract_info(bufnr)
    return M.get_function_selectors(contract_info)
end

--- @param bufnr number
--- @return table|nil gas_estimates
M.get_contract_gas_estimates = function(bufnr)
    local contract_info = M.get_contract_info(bufnr)
    return M.get_gas_estimates(contract_info)
end

--- @param bufnr number
--- @return table|nil metadata
M.get_contract_metadata = function(bufnr)
    local contract_info = M.get_contract_info(bufnr)
    return M.get_metadata(contract_info)
end

--- @return ContractInfo contract_info
M.get_current_contract_info = function()
    local bufnr = vim.api.nvim_get_current_buf()
    return M.get_contract_info(bufnr)
end

--- @return table|nil contract_output_artifacts
M.get_current_contract_output_artifacts = function()
    local contract_info = M.get_current_contract_info()
    return M.get_output_contract_artifacts(contract_info)
end

--- @return table|nil sources_output_artifacts
M.get_current_sources_output_artifacts = function()
    local contract_info = M.get_current_contract_info()
    return M.get_output_sources_artifacts(contract_info)
end

--- @return table|nil gas_estimates
M.get_current_contract_gas_estimates = function()
    local contract_info = M.get_current_contract_info()
    return M.get_gas_estimates(contract_info)
end

--- @return table|nil function_selectors
M.get_current_contract_function_selectors = function()
    local contract_info = M.get_current_contract_info()
    return M.get_function_selectors(contract_info)
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
