# Hardhat.nvim


Plugin to more conveniently/easily interact with [hardhat](https://github.com/foundry-rs/foundry/tree/master/chisel) from
neovim. These is a WIP, any contributions are welcome and appreciated.


### Features


- [x] Command `HH` for cli integration with hardhat runner and per project autocompletion(similar to [vim-fugitive](https://github.com/tpope/vim-fugitive).
  Completion still isn't automatic, you need to manually call `require("hardhat.cli").refresh_completion()`.
- [x] [Neotest](https://github.com/nvim-neotest/neotest) integration with `neotest-hardhat` adapter.
- [x] [Telescope](https://github.com/nvim-telescope/telescope.nvim) integrations which provide
    - Picker to deploy using `hardhat-ignition` and `hardhat-deploy` deploy system and with support for multi-chain
      and multi-contract deployments, that is, you can deploy a set of contracts in a set of networks at once.
    - Pickers for verification using `hardhat-verify`(verify or sourcify) with multi-chain and multi-contract support.
    - Pickers to select deployments and networks which are used as intermediary step for the deploy and/or verify pickers.
- [x] [Overseer](https://github.com/stevearc/overseer.nvim) integration for the `HH` command and
  later for provided telescope pickers.


# Index


- [Installation](#Installation)
- [Configuration](#Configuration)
- [Documentation](#Documentation)
- [License](#License)


# Installation


Install using your preferred package manager. Next code
snippet corresponds to lazy.

```lua
{
    "TheSnakeWitcher/hardhat.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-neotest/neotest",
        "nvim-telescope/telescope.nvim",
        "stevearc/overseer.nvim",
    },
}
```


# Configuration


To use the neotest adapter you will need add it to your neotest config and use `hardhat-neovim` in your hardhat project .

```lua
require("neotest").setup({
    adapters = {
        require("neotest-hardhat"),
    },
})
```

To use the telescope pickers add the extension to your telescope config.

```lua
require("telescope").load_extension("hardhat")
```


# Documentation



# License


MIT
