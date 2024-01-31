local config = require("hardhat.config")
local artifacts = require("hardhat.artifacts")


local M = {}


local extmarks_of = {}

local function set_gas_extmark(bufnr, fn, fn_attributes, fn_gas_estimate)
    local extmark_id = extmarks_of[bufnr] and extmarks_of[bufnr][fn]
    if extmark_id then
        vim.api.nvim_buf_set_extmark(
            bufnr,
            config.ns,
            fn_attributes.starts,
            fn_attributes.ends,
            {
                id = extmark_id,
                virt_text = {
                    {
                        string.format(
                            "%s %s",
                            config.gas_extmarks.sign,
                            fn_gas_estimate
                        ),
                        config.gas_extmarks.highlight
                    },
                },
                virt_text_pos = "eol"
            }
        )
    else
        local new_extmark_id = vim.api.nvim_buf_set_extmark(
            bufnr,
            config.ns,
            fn_attributes.starts,
            fn_attributes.ends,
            {
                virt_text = {
                    {
                        string.format(
                            "%s %s",
                            config.gas_extmarks.sign,
                            fn_gas_estimate
                        ),
                        config.gas_extmarks.highlight
                    },
                },
                virt_text_pos = "eol"
            }
        )
        if extmarks_of[bufnr] then
            extmarks_of[bufnr][fn] = new_extmark_id
        else
            extmarks_of[bufnr] = {
                [fn] = new_extmark_id
            }
        end
    end
end

function M.set_gas_extmarks(bufnr)
    local gas_estimates = artifacts.get_contract_gas_estimates(bufnr)
    if not gas_estimates then
        vim.notify(string.format("there isn't gas estimates for buffer %d", bufnr))
        return nil
    end
    local contract_gas_estimates = vim.tbl_extend("error", gas_estimates.external or {}, gas_estimates.internal or {})

    local fn_attributes = artifacts.get_contract_function_signatures(bufnr)
    if not fn_attributes then
        vim.notify(string.format("there isn't functions attributes in buffer %d", bufnr))
        return nil
    end


    for fn, attributes in pairs(fn_attributes) do
        set_gas_extmark(bufnr, fn, attributes, contract_gas_estimates[fn])
    end
end

setmetatable(M, {
    __index = function(_, key)
        return extmarks_of
    end
})


return M
