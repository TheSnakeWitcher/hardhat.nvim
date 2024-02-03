local extmarks = require("hardhat.extmarks")

return {
    desc = "refresh extmarks for buffers in windows after compile",
    editable = false,
    serializable = false,
    constructor = function()
        return {
            ---@param status overseer.Status Can be CANCELED, FAILURE, or SUCCESS
            ---@param result table A result table.
            on_complete = function(self, task, status, result)
                if status ~= "SUCCESS" or task.name ~= "hardhat compile" then return end

                local bufs = vim.tbl_map(
                    function(win)
                        local buf = vim.api.nvim_win_get_buf(win)
                        local is_solidity_buf = vim.api.nvim_buf_get_option(buf, "ft") == "solidity"
                        if is_solidity_buf then return buf end
                    end,
                    vim.api.nvim_list_wins()
                )

                vim.tbl_map(extmarks.set_gas_extmarks, bufs)
            end,
        }
    end,
}
