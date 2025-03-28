-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.OpenRepoLoaded then
    return
end

_G.OpenRepoLoaded = true

vim.api.nvim_create_user_command("OpenRepo", function()
    require("open-repo").get_repo_info()
end, {})
