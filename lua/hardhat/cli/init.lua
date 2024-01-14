local config = require("hardhat.config")
local cli_parse = require("hardhat.cli.parse")
local overseer = require("overseer")


local M = {}


M.CMD = "HH"

M.global_options = {}
M.scopes = {}
M.tasks = {}

M.task_options = {}
M.scope_tasks = {}

M.refresh_completion = function()
    local completion_options = cli_parse.get_root()
    M.global_options = completion_options.global_options
    M.scopes = completion_options.tasks_scopes
    M.tasks = completion_options.tasks
end

M.run = function(opts)
    overseer.run_action(
        overseer.new_task({
            cmd = config.package_manager,
            args =  vim.list_extend( { "hardhat" }, opts.fargs ),
            name = string.format("hardhat %s", opts.fargs[1])
        }),
        "start"
    )
end

--- @param cmd string
--- @return string[] completion_options
local get_task_scope_completion = function(cmd)
    if M.scope_tasks[cmd] then
        return M.scope_tasks[cmd]
    end
    M.scope_tasks[cmd] = cli_parse.get_scope_tasks(cmd)
    return M.scope_tasks[cmd]
end

--- @param cmd string
--- @return string[] completion_options
local get_task_completion = function(cmd)
    if M.task_options[cmd] then
       return M.task_options[cmd]
    end
    M.task_options[cmd] = cli_parse.get_task_options(cmd)
    return M.task_options[cmd]
end

--- @return string[] completion_options
local get_root_completion = function()
    local completion_options = {}
    vim.list_extend(completion_options, M.scopes)
    vim.list_extend(completion_options, M.tasks)
    vim.list_extend(completion_options, M.global_options)

    return completion_options
end

--- @param cmd string[]
--- @return boolean
local function is_scope(cmd)
    return vim.tbl_contains(M.scopes, cmd)
end

--- @param cmd string[]
--- @return boolean
local function is_task(cmd)
    return vim.tbl_contains(M.tasks, cmd)
end

--- @param arglead string
--- @param cmdline string
--- @param cursor_pos number
--- @return string[] completion_options
M.complete = function(arglead, cmdline, cursor_pos)
    local words = vim.split(cmdline, '%s+')
    local initial_pos = #M.CMD + 1
    local word_number = #words

    if cursor_pos == initial_pos or word_number < 2 then
         return get_root_completion()
    end

    local cmds = vim.tbl_filter(
        function(word) return cli_parse.is_task_or_scope(word) end,
        words
    )
    if #cmds == 0 then return get_root_completion() end

    local cmd = cmds[2]
    if is_scope(cmd) then
        return get_task_scope_completion(cmd)
    elseif is_task(cmd) then
        return get_task_completion(cmd)
    end

    return get_root_completion()
end


return M
