local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local actions_utils = require("telescope.actions.utils")


local M = {}

function M.get_pairs(networks, contracts)
    local results = {}
    for _, network in ipairs(networks) do
        for _, contract in ipairs(contracts) do
            table.insert(results, { network, contract })
        end
    end
    return results
end

function M.do_with_pairs(networks, contracts, callback)
    for _, network in ipairs(networks) do
        for _, contract in ipairs(contracts) do
            callback(network, contract)
        end
    end
end

function M.get_entry_and_close_buf(prompt_bufnr)
	local entry = actions_state.get_selected_entry().value
	actions.close(prompt_bufnr)
	return entry
end

function M.get_entries_and_close_buf(prompt_bufnr)
	local entries = {}
    actions_utils.map_selections(prompt_bufnr, function(entry, _)
        table.insert(entries, entry.value)
    end)

	if #entries < 1 then
	    table.insert(
	        entries,
	        actions_state.get_selected_entry().value
	    )
	end

	actions.close(prompt_bufnr)
	return entries
end

return M
