-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.OpenRepoLoaded then
    return
end

_G.OpenRepoLoaded = true

-- Useful if you want your plugin to be compatible with older (<0.7) neovim versions
if vim.fn.has("nvim-0.7") == 0 then
    vim.cmd("command! OpenRepo lua require('open-repo').toggle()")
else
    vim.api.nvim_create_user_command("OpenRepo", function()
        require("open-repo").toggle()
    end, {})
end
