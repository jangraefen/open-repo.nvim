local Helpers = dofile 'tests/helpers.lua'

-- See https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/test.lua for more documentation

local child = Helpers.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart { '-u', 'scripts/minimal_init.lua' }
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
}

-- Tests related to the `setup` method.
T['setup()'] = MiniTest.new_set()

T['setup()']['sets exposed methods and default options value'] = function()
  child.lua [[require('open-repo').setup()]]

  -- global object that holds your plugin information
  Helpers.expect.global_type(child, '_G.OpenRepo', 'table')

  -- public methods
  Helpers.expect.global_type(child, '_G.OpenRepo.setup', 'function')

  -- config
  Helpers.expect.global_type(child, '_G.OpenRepo.config', 'table')

  -- assert the value, and the type
  Helpers.expect.config(child, 'debug', false)
  Helpers.expect.config_type(child, 'debug', 'boolean')
  Helpers.expect.config(child, 'browser_command', 'xdg-open')
  Helpers.expect.config_type(child, 'browser_command', 'string')
  Helpers.expect.config(child, 'host_mappings', {
    ['github.com'] = 'github',
    ['gitlab.com'] = 'gitlab',
  })
  Helpers.expect.config_type(child, 'host_mappings', 'table')
end

T['setup()']['overrides default values'] = function()
  child.lua [[require('open-repo').setup({
        -- write all the options with a value different than the default ones
        debug = true,
        browser_command = "firefox",
        host_mappings = {
            ["github.company.com"] = "github",
        },
    })]]

  -- assert the value, and the type
  Helpers.expect.config(child, 'debug', true)
  Helpers.expect.config_type(child, 'debug', 'boolean')
  Helpers.expect.config(child, 'browser_command', 'firefox')
  Helpers.expect.config_type(child, 'browser_command', 'string')
  Helpers.expect.config(child, 'host_mappings', {
    ['github.com'] = 'github',
    ['gitlab.com'] = 'gitlab',
    ['github.company.com'] = 'github',
  })
  Helpers.expect.config_type(child, 'host_mappings', 'table')
end

-- T["setup()"]["can open a browser"] = function()
--     child.lua([[
--     local open_repo = require('open-repo')
--     open_repo.setup({
--         debug = true,
--     })
--
--     open_repo.open_repo()
--     ]])
-- end

return T
