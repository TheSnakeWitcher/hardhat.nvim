local hh_cli = require('hardhat.cli')

vim.api.nvim_create_user_command(
    hh_cli.CMD,
    function(opts) hh_cli.run(opts) end,
    {
        --- @help command-attributes
        nargs = '*',
        complete = function(arglead, cmdline, cursor_pos)
            return hh_cli.complete(arglead, cmdline, cursor_pos)
        end,
    }
)
