local log = require 'open-repo.util.log'

-- internal methods
local main = {}

---@class FileInfo
---@field name string The file name
---@field line number The line number
---@field path string The relative path from repository root

---@class RepoInfo
---@field domain string The domain of the git host (e.g., "github.com")
---@field owner string The repository owner or organization name
---@field name string The repository name
---@field branch string The branch name
---@field file FileInfo|nil The location within the active file, if available

-- Extracts the repository URL from the current buffer.
--
---@param scope string: internal identifier for logging purposes.
---@return RepoInfo|nil # Repository information or nil if not found
---@private
function main.get_repo_url(scope)
  -- Get the directory to check
  local current_file = vim.fn.expand '%:p'
  local dir_to_check
  local file_info

  if current_file and current_file ~= '' then
    dir_to_check = vim.fn.fnamemodify(current_file, ':h')
    log.debug(scope, 'Using file directory: ' .. dir_to_check)

    -- Get relative path from git root
    local git_root = vim.fn.fnamemodify(vim.fn.system('git rev-parse --show-toplevel'):gsub('[\n\r]', ''), ':p')
    local full_path = vim.fn.fnamemodify(current_file, ':p')
    local relative_path = full_path:sub(#git_root + 2)

    file_info = {
      name = vim.fn.expand '%:t',
      line = vim.fn.line 'v',
      path = relative_path,
    }
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

  cmd = string.format('cd "%s" && git rev-parse --abbrev-ref HEAD', dir_to_check)
  local branch = vim.fn.system(cmd):gsub('[\n\r]', '')
  if vim.v.shell_error ~= 0 then
    log.error(scope, 'Failed to get current branch name')
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
    branch = branch,
    file = file_info,
  }

  log.debug(scope, string.format('Found repository: %s/%s on %s', owner, name, domain))
  return repo_info
end

---@class RepoUrls
---@field repo string The main repository URL
---@field change_requests string The URL for pull/merge requests
---@field cicd string The URL for CI/CD (GitHub Actions or GitLab Pipelines)
---@field file string The URL for the active file

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
    if repo_info.file then
      urls.file = base .. '/blob/' .. repo_info.branch .. '/' .. repo_info.file.path .. '#L' .. repo_info.file.line
    end
  elseif service_type == 'gitlab' then
    log.debug(scope, 'Constructed GitLab URLs')
    urls = {
      repo = base,
      change_requests = base .. '/-/merge_requests',
      cicd = base .. '/-/pipelines',
    }
    if repo_info.file then
      urls.file = base .. '/-/blob/' .. repo_info.branch .. '/' .. repo_info.file.path .. '#L' .. repo_info.file.line
    end
  else
    log.error(scope, string.format('Unsupported service type: %s', service_type))
    return nil
  end

  return urls
end

---@alias UrlType "repo"|"change_requests"|"cicd"|"file"

-- Opens the specified URL type in the configured browser asynchronously
--
---@param scope string internal identifier for logging purposes
---@param url_type UrlType which URL type to open
---@return boolean success whether the URL opening was initiated successfully
---@private
function main.open_url(scope, url_type)
  local urls = main.construct_repo_urls(scope)
  if not urls then
    return false
  end

  local url = urls[url_type]
  if not url then
    if not url_type == 'file' then
      log.error(scope, string.format('Invalid URL type: %s', url_type))
    end
    return false
  end

  local config = _G.OpenRepo.config
  local cmd = { config.browser_command, url }

  local job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        log.error(scope, string.format('Failed to open URL: %s (exit code: %d)', url, exit_code))
      else
        log.debug(scope, string.format('Opened %s URL: %s', url_type, url))
      end
    end,
  })

  if job_id <= 0 then
    log.error(scope, string.format('Failed to start browser command for URL: %s', url))
    return false
  end

  return true
end

return main
