-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.OpenRepoLoaded then
    return
end

_G.OpenRepoLoaded = true

vim.api.nvim_create_user_command("OpenRepo", function()
    require("open-repo").open_repo()
end, {
    desc = "Open the main repository URL in the configured browser",
    nargs = 0,
    help = [[
Opens the main repository page in your configured browser.
Uses the git remote URL of the current file or working directory to determine the repository.
For GitHub: Opens https://github.com/owner/repo
For GitLab: Opens https://gitlab.com/owner/repo
    ]],
})

vim.api.nvim_create_user_command("OpenRepoCR", function()
    require("open-repo").open_change_requests()
end, {
    desc = "Open the change requests URL in the configured browser",
    nargs = 0,
    help = [[
Opens the repository's change requests page in your configured browser.
Uses the git remote URL of the current file or working directory to determine the repository.
For GitHub: Opens the Pull Requests page (https://github.com/owner/repo/pulls)
For GitLab: Opens the Merge Requests page (https://gitlab.com/owner/repo/-/merge_requests)
    ]],
})

vim.api.nvim_create_user_command("OpenCICD", function()
    require("open-repo").open_cicd()
end, {
    desc = "Open the CI/CD URL in the configured browser",
    nargs = 0,
    help = [[
Opens the repository's CI/CD page in your configured browser.
Uses the git remote URL of the current file or working directory to determine the repository.
For GitHub: Opens the Actions page (https://github.com/owner/repo/actions)
For GitLab: Opens the Pipelines page (https://gitlab.com/owner/repo/-/pipelines)
    ]],
})
