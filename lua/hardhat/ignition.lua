local ok, scan = pcall(require,'plenary.scandir')
if not ok then
    vim.notify("hardhat.nvim requires plenary")
    return {}
end


local M = {}


M.list_modules = function()
    local root = vim.loop.cwd()
    local modules_dir = string.format("%s/ignition/modules", root)
    return scan.scan_dir(modules_dir, {})
end


return M

