local log = require("open-repo.util.log")
local state = require("open-repo.state")

-- internal methods
local main = {}

-- Extracts the repository URL from the current buffer.
--
---@param scope string: internal identifier for logging purposes.
---@return table|nil # Repository info containing domain, owner, and name, or nil if not found
---@private
function main.get_repo_url(scope)
    -- Get the directory to check
    local current_file = vim.fn.expand('%:p')
    local dir_to_check
    
    if current_file and current_file ~= '' then
        dir_to_check = vim.fn.fnamemodify(current_file, ':h')
        log.debug(scope, "Using file directory: " .. dir_to_check)
    else
        dir_to_check = vim.fn.getcwd()
        log.debug(scope, "Using working directory: " .. dir_to_check)
    end

    -- Change to the directory and get git remote URL
    local cmd = string.format('cd "%s" && git remote get-url origin', dir_to_check)
    local remote_url = vim.fn.system(cmd):gsub("[\n\r]", "")
    
    if vim.v.shell_error ~= 0 then
        log.error(scope, "Failed to get git remote URL")
        return nil
    end

    -- Parse the remote URL into components
    local domain, owner, name
    
    if remote_url:match("^git@") then
        -- SSH format: git@github.com:owner/repo.git
        domain, owner, name = remote_url:match("^git@([^:]+):([^/]+)/(.+)$")
    else
        -- HTTPS format: https://github.com/owner/repo.git
        domain, owner, name = remote_url:match("^https?://([^/]+)/([^/]+)/(.+)$")
    end

    -- Remove .git suffix if present
    if name then
        name = name:gsub("%.git$", "")
    end

    if not (domain and owner and name) then
        log.error(scope, "Failed to parse repository information from URL: " .. remote_url)
        return nil
    end

    local repo_info = {
        domain = domain,
        owner = owner,
        name = name
    }

    log.debug(scope, string.format("Found repository: %s/%s on %s", owner, name, domain))
    return repo_info
end

-- Toggle the plugin by calling the `enable`/`disable` methods respectively.
--
---@param scope string: internal identifier for logging purposes.
---@private
function main.toggle(scope)
    if state.get_enabled(state) then
        log.debug(scope, "open-repo is now disabled!")

        return main.disable(scope)
    end

    log.debug(scope, "open-repo is now enabled!")

    main.enable(scope)
end

--- Initializes the plugin, sets event listeners and internal state.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.enable(scope)
    if state.get_enabled(state) then
        log.debug(scope, "open-repo is already enabled")

        return
    end

    state.set_enabled(state)

    -- saves the state globally to `_G.OpenRepo.state`
    state.save(state)
end

--- Disables the plugin for the given tab, clear highlight groups and autocmds, closes side buffers and resets the internal state.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.disable(scope)
    if not state.get_enabled(state) then
        log.debug(scope, "open-repo is already disabled")

        return
    end

    state.set_disabled(state)

    -- saves the state globally to `_G.OpenRepo.state`
    state.save(state)
end

return main
