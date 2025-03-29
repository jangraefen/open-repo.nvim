local log = require 'open-repo.util.log'
local state = require 'open-repo.state'

-- internal methods
local main = {}

-- Toggle the plugin by calling the `enable`/`disable` methods respectively.
--
---@param scope string: internal identifier for logging purposes.
---@private
function main.toggle(scope)
  if state.get_enabled(state) then
    log.debug(scope, 'open-repo is now disabled!')

    return main.disable(scope)
  end

  log.debug(scope, 'open-repo is now enabled!')

  main.enable(scope)
end

--- Initializes the plugin, sets event listeners and internal state.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.enable(scope)
  if state.get_enabled(state) then
    log.debug(scope, 'open-repo is already enabled')

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
    log.debug(scope, 'open-repo is already disabled')

    return
  end

  state.set_disabled(state)

  -- saves the state globally to `_G.OpenRepo.state`
  state.save(state)
end

---@class RepoInfo
---@field domain string The domain of the git host (e.g., "github.com")
---@field owner string The repository owner or organization name
---@field name string The repository name

-- Extracts the repository URL from the current buffer.
--
---@param scope string: internal identifier for logging purposes.
---@return RepoInfo|nil # Repository information or nil if not found
---@private
function main.get_repo_url(scope)
  -- Get the directory to check
  local current_file = vim.fn.expand '%:p'
  local dir_to_check

  if current_file and current_file ~= '' then
    dir_to_check = vim.fn.fnamemodify(current_file, ':h')
    log.debug(scope, 'Using file directory: ' .. dir_to_check)
  else
    dir_to_check = vim.fn.getcwd()
    log.debug(scope, 'Using working directory: ' .. dir_to_check)
  end

  -- Change to the directory and get git remote URL
  local cmd = string.format('cd "%s" && git remote get-url origin', dir_to_check)
  local remote_url = vim.fn.system(cmd):gsub('[\n\r]', '')

  if vim.v.shell_error ~= 0 then
    log.error(scope, 'Failed to get git remote URL')
    return nil
  end

  -- Parse the remote URL into components
  local domain, owner, name

  if remote_url:match '^git@' then
    -- SSH format: git@github.com:owner/repo.git
    domain, owner, name = remote_url:match '^git@([^:]+):([^/]+)/(.+)$'
  else
    -- HTTPS format: https://github.com/owner/repo.git
    domain, owner, name = remote_url:match '^https?://([^/]+)/([^/]+)/(.+)$'
  end

  -- Remove .git suffix if present
  if name then
    name = name:gsub('%.git$', '')
  end

  if not (domain and owner and name) then
    log.error(scope, 'Failed to parse repository information from URL: ' .. remote_url)
    return nil
  end

  local repo_info = {
    domain = domain,
    owner = owner,
    name = name,
  }

  log.debug(scope, string.format('Found repository: %s/%s on %s', owner, name, domain))
  return repo_info
end

---@class RepoUrls
---@field repo string The main repository URL
---@field change_requests string The URL for pull/merge requests
---@field cicd string The URL for CI/CD (GitHub Actions or GitLab Pipelines)

-- Constructs various repository-related URLs based on the host
--
---@param scope string internal identifier for logging purposes
---@return RepoUrls|nil # Repository URLs or nil if host not supported
---@private
function main.construct_repo_urls(scope)
  local repo_info = main.get_repo_url(scope)
  if not repo_info then
    log.error(scope, 'No repository information provided')
    return nil
  end

  local config = _G.OpenRepo.config
  local service_type = config.host_mappings[repo_info.domain]

  if not service_type then
    log.error(scope, string.format('No service type mapping found for host: %s', repo_info.domain))
    return nil
  end

  local base = string.format('https://%s/%s/%s', repo_info.domain, repo_info.owner, repo_info.name)
  local urls = {}

  if service_type == 'github' then
    log.debug(scope, 'Constructed GitHub URLs')
    urls = {
      repo = base,
      change_requests = base .. '/pulls',
      cicd = base .. '/actions',
    }
  elseif service_type == 'gitlab' then
    log.debug(scope, 'Constructed GitLab URLs')
    urls = {
      repo = base,
      change_requests = base .. '/-/merge_requests',
      cicd = base .. '/-/pipelines',
    }
  else
    log.error(scope, string.format('Unsupported service type: %s', service_type))
    return nil
  end

  return urls
end

---@alias UrlType "repo"|"change_requests"|"cicd"

-- Opens the specified URL type in the configured browser
--
---@param scope string internal identifier for logging purposes
---@param url_type UrlType which URL type to open
---@return boolean success whether the URL was opened successfully
---@private
function main.open_url(scope, url_type)
  local urls = main.construct_repo_urls(scope)
  if not urls then
    return false
  end

  local url = urls[url_type]
  if not url then
    log.error(scope, string.format('Invalid URL type: %s', url_type))
    return false
  end

  local config = _G.OpenRepo.config
  local cmd = string.format('%s "%s"', config.browser_command, url)

  vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    log.error(scope, string.format('Failed to open URL: %s', url))
    return false
  end

  log.debug(scope, string.format('Opened %s URL: %s', url_type, url))
  return true
end

return main
