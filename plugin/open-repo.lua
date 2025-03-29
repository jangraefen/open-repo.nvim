-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.OpenRepoLoaded then
  return
end

_G.OpenRepoLoaded = true

vim.api.nvim_create_user_command('OpenRepo', function()
  require('open-repo').open_repo()
end, {
  desc = 'Open the main repository URL in the configured browser',
  nargs = 0,
})

vim.api.nvim_create_user_command('OpenRepoCR', function()
  require('open-repo').open_change_requests()
end, {
  desc = 'Open the change requests URL in the configured browser',
  nargs = 0,
})

vim.api.nvim_create_user_command('OpenCICD', function()
  require('open-repo').open_cicd()
end, {
  desc = 'Open the CI/CD URL in the configured browser',
  nargs = 0,
})
