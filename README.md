# Hardhat.nvim


Plugin to more conveniently/easily interact with [hardhat](https://github.com/foundry-rs/foundry/tree/master/chisel) from
neovim. These is a WIP, any contributions are welcome and appreciated.


### Features


- [x] Command `HH` with autocompletion(still not per project) for cli integration with hardhat runner(similar to [vim-fugitive](https://github.com/tpope/vim-fugitive)).
- [x] [Neotest](https://github.com/nvim-neotest/neotest) integration with `neotest-hardhat` adapter.
- [x] [Telescope](https://github.com/nvim-telescope/telescope.nvim) integrations which provide
    - Picker for deploy using `hardhat-ignition` and `hardhat-deploy` deploy system.
    - Pickers for verification using `hardhat-verify`(verify or sourcify). 
    - Pickers for deployments(only `hardhat-ignition` deployments for now). 
    - Pickers for networks(used as intermediary step for other pickers). 
- [x] [Overseer](https://github.com/stevearc/overseer.nvim) integration for the `HH` command and later for provided telescope pickers.


# Index


1. [Installation](#Installation)
2. [Configuration](#Configuration)
3. [Documentation](#Documentation)
4. [License](#License)


# Installation


Install using your preferred package manager. Next code
snippet corresponds to lazy.

```lua
{
    "TheSnakeWitcher/hardhat.nvim",
    dependencies = {
        "nvim-neotest/neotest",
        "nvim-telescope/telescope.nvim",
        "stevearc/overseer.nvim",
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
