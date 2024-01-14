local util = require("hardhat.util")

local M = {}

M.EMPTY_LINE = ""
M.OPTION_PREFIX = "--"

local PAIR_SEPARATOR = "\t"
local PAIR_KEY_INDEX = 1


--- @enum SECTION_HEADERS
local SECTION_HEADERS = {
    USAGE =  "Usage:",
    GLOBAL_OPTIONS =  "GLOBAL OPTIONS:",
    TASK_SCOPES = "AVAILABLE TASK SCOPES:",
    TASKS = "AVAILABLE TASKS:",
    OPTIONS = "OPTIONS:",
    END = "For global options help run: hardhat help",
}

--- @param word string
M.is_task_or_scope = function(word)
    return word ~= M.EMPTY_LINE and not vim.startswith(word, M.OPTION_PREFIX)
end

--- @param word string
M.is_option = function(word)
    return word ~= M.EMPTY_LINE and not vim.startswith(word, M.OPTION_PREFIX)
end

--- @param cmd? string
local function get_content(cmd)
    local results = {}
    local package_manager = util.get_js_package_manager()

    if not cmd then
        results = vim.fn.systemlist(string.format("%s hardhat --help", package_manager))
    else
        results = vim.fn.systemlist(string.format("%s hardhat %s --help", package_manager, cmd))
    end

    return results
end

M.test_get_content = function(cmd)
    return get_content(cmd)
end

--- @param start number
--- @param content string[]
--- @return string[] results
--- @return number end_index
local function get_pairs_starting_at(start, content)
    local results = {}

    for index = start, #content do
        local pair = content[index]
        if pair == M.EMPTY_LINE then return results, index end

        local key = vim.split(pair, PAIR_SEPARATOR)[PAIR_KEY_INDEX]
        table.insert(results, vim.trim(key))
    end

    return results, -1
end

--- @param content string[]
--- @param pattern string
--- @param start number?
--- @return string[] results
--- @return number end_index
local function find_pairs_of_pattern(content, pattern, start)
    local offset = 2
    for index = start or 1, #content do
        if content[index] == pattern then
            local section_start_index =  index + offset
            return get_pairs_starting_at(section_start_index, content)
        end
    end
    return {}, -1
end

--- @param content string[]
--- @param start number?
--- @return string[] results
--- @return number end_index
M.get_options = function(content, start)
    return find_pairs_of_pattern(content, SECTION_HEADERS.OPTIONS, start)
end

--- @param content string[]
--- @param start number?
--- @return string[] results
--- @return number end_index
M.get_global_options = function(content, start)
    return find_pairs_of_pattern(content, SECTION_HEADERS.GLOBAL_OPTIONS, start)
end

--- @param content string[]
--- @param start number?
--- @return string[] results
--- @return number end_index
M.get_tasks = function(content, start)
    return find_pairs_of_pattern(content, SECTION_HEADERS.TASKS, start)
end

--- @param content string[]
--- @param start number?
--- @return string[] results
--- @return number end_index
M.get_tasks_scopes = function(content, start)
    return find_pairs_of_pattern(content, SECTION_HEADERS.TASK_SCOPES, start)
end

M.get_root = function()
    local content = get_content()
    local SECTION_END_OFFSET = 2

    local global_options, index = M.get_global_options(content)
    local tasks, task_scopes_index = M.get_tasks(content, index + SECTION_END_OFFSET)
    local tasks_scopes = M.get_tasks_scopes(content, task_scopes_index + SECTION_END_OFFSET)

    return {
        global_options = global_options,
        tasks = tasks,
        tasks_scopes = tasks_scopes
    }
end

--- @param task string
--- @return string[] scope_tasks 
M.get_task_options = function(task)
    local task_content = get_content(task)
    local task_options = M.get_options(task_content)
    return task_options
end

--- @param scope string
--- @return string[] scope_tasks 
M.get_scope_tasks = function(scope)
    local scope_content = get_content(scope)
    local scope_tasks = M.get_tasks(scope_content)
    return scope_tasks
end


return M
