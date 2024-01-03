# Hardhat.nvim


Plugin to more conveniently/easily interact with [hardhat](https://github.com/foundry-rs/foundry/tree/master/chisel) from
neovim. These is a WIP, any contributions are welcome and appreciated.


### Features


* [x] [Neotest](https://github.com/nvim-neotest/neotest) integration with neotest-hardhat adapter.
* [x] [Telescope](https://github.com/nvim-telescope/telescope.nvim) integrations which provide
    * Pickers for `hardhat-ignition` and `hardhat-deploy` deploy systems.
    * Pickers for verification using `hardhat-verify`(verify or sourcify). 
* [ ] [Overseer](https://github.com/stevearc/overseer.nvim) integration.
* [ ] Command `HH` for cli integration with hardhat runner(similar to [vim-fugitive](https://github.com/tpope/vim-fugitive)).


# Index


1. [Installation](#Installation)
2. [Configuration](#Configuration)
3. [Documentation](#Documentation)
4. [License](#License)


# Installation


Install using your prefered package manager. Next code
snippet corresponds to lazy.

```lua
{
    "TheSnakeWitcher/hardhat.nvim",
    dependencies = {
        "nvim-neotest/neotest",
        "nvim-telescope/telescope.nvim",
    },
}
```


# Configuration


To use the neotest adapter add it to your neotest config.

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
