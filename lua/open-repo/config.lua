local log = require("open-repo.util.log")

local OpenRepo = {}

--- OpenRepo configuration with its default values.
---
---@class OpenRepoConfig
---@field debug boolean Prints useful logs about what events are triggered, and reasons actions are executed
---@field host_mappings table<string, "github"|"gitlab"> host mappings for custom GitHub/GitLab instances. Key is the domain name, value must be either "github" or "gitlab"
---@field browser_command string Command to open URLs in browser
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
OpenRepo.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,

    -- Command to open URLs in browser
    browser_command = 'xdg-open',  -- Default for Linux, uses system's default browser

    -- Host mappings for custom GitHub/GitLab instances
    -- Format: { host = "github|gitlab" }
    host_mappings = {
        -- Default instances
        ["github.com"] = "github",
        ["gitlab.com"] = "gitlab",
        -- Example: Enterprise GitHub instance
        -- ["github.company.com"] = "github",
        -- Example: Self-hosted GitLab instance
        -- ["gitlab.company.com"] = "gitlab",
    },
}

---@private
local defaults = vim.deepcopy(OpenRepo.options)

--- Defaults OpenRepo options by merging user provided options with the default plugin values.
---
---@param options table Module config table. See |OpenRepo.options|.
---
---@private
function OpenRepo.defaults(options)
    OpenRepo.options = vim.deepcopy(vim.tbl_deep_extend("keep", options or {}, defaults or {}))

    -- let your user know that they provided a wrong value, this is reported when your plugin is executed.
    assert(type(OpenRepo.options.debug) == "boolean", "`debug` must be a boolean (`true` or `false`).")
    assert(type(OpenRepo.options.browser_command) == "string", "`browser_command` must be a string")

    if OpenRepo.options.host_mappings then
        assert(type(OpenRepo.options.host_mappings) == "table", "`host_mappings` must be a table")

        for host, platform in pairs(OpenRepo.options.host_mappings) do
            assert(type(host) == "string", "Domain name must be a string")
            assert(platform == "github" or platform == "gitlab", string.format("Platform for host '%s' must be either 'github' or 'gitlab'", domain))
        end
    end

    return OpenRepo.options
end

--- Define your open-repo setup.
---
---@param options OpenRepoConfig Module config table. See |OpenRepo.options|.
---
---@usage `require("open-repo").setup()` (add `{}` with your |OpenRepo.options| table)
function OpenRepo.setup(options)
    OpenRepo.options = OpenRepo.defaults(options or {})

    log.warn_deprecation(OpenRepo.options)

    return OpenRepo.options
end

return OpenRepo
