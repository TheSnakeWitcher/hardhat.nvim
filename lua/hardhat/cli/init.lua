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

--- @param cmd string
--- @return table components 
local function get_overseer_components(cmd)
    local components = { "default" }

    if cmd == "compile" then
        vim.list_extend(components, {
            {
                -- https://www.reddit.com/r/vim/comments/jk4b0f/better_errorformat_testing/
                -- https://flukus.github.io/vim-errorformat-demystified.html
                "on_output_quickfix",
                errorformat = [[%E%.%#Error:\ %m,%Z\ %#-->\ %f:%l:%c:,%WWarning:\ %m,%Z-->\ %f]],
            },
        })
    end

    return components
end

M.run = function(opts)
    local cmd = opts.fargs[1]
    overseer.new_task({
        cmd = config.package_manager,
        args =  vim.list_extend({ "hardhat" }, opts.fargs),
        name = string.format("hardhat %s", cmd),
        components = get_overseer_components(cmd)
    }):start()
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

    if #M.global_options == 0 then
        vim.notify("completion refreshed")
        vim.schedule(M.refresh_completion)
    end

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
    else
        return get_root_completion()
    end
end


return M
