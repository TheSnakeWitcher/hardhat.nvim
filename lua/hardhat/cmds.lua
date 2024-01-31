local cli = require('hardhat.cli')


vim.api.nvim_create_user_command(
    cli.CMD,
    function(opts) cli.run(opts) end,
    {
        --- @help command-attributes
        nargs = '*',
        complete = function(arglead, cmdline, cursor_pos)
            return cli.complete(arglead, cmdline, cursor_pos)
        end,
    }
)
