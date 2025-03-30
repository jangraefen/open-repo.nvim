<p align="center">
  <h1 align="center">open-repo.nvim</h2>
</p>

<p align="center">
    Bridging the gap between your code editor and your code collaboration platform.
</p>

## ⚡️ Features

While coding, I found myself often in the situation that I quickly wanted to check on the pipeline. Or once I pushed
final commit for a feature, I wanted to open the PR. This plugin is meant to help you with that.

Instead of trying to poorly simulate the platform UI in NeoVim, this plugin just makes switching between both worlds a
bit easier and faster.

- `:OpenRepo`: Open the start page of the current repository.
- `:OpenRepoFile`: Open the current file and line.
- `:OpenRepoCR`: Open the change request for the current repository (Pull requests for GitHub, Merge Requests for GitLab).
- `:OpenRepoCICD`: Open the CICD for the current repository (Actions for GitHub, Pipelines for GitLab).

The current repository is determined by the currently active buffer or the current working directory.

## 📋 Installation

Using [folke/lazy.nvim](https://github.com/folke/lazy.nvim) is recommended, but any plugin manager should work.

```lua
{
  'jangraefen/open-repo.nvim',
  -- If you want to trigger lazy loading on commands
  cmd = {
    'OpenRepo',
    'OpenRepoFile',
    'OpenRepoCR',
    'OpenRepoCICD'
  },
  -- Some inspriration for keybinds
  keys = {
    { '<leader>gr', '<cmd>OpenRepo<CR>', desc = 'Open repository' },
    { '<leader>gf', '<cmd>OpenRepoFile<CR>', desc = 'Open current file' },
    { '<leader>gc', '<cmd>OpenRepoCR<CR>', desc = 'Open change request' },
    { '<leader>gb', '<cmd>OpenRepoCICD<CR>', desc = 'Open builds' }
  },
  opts = {
    -- If you are on WSL, you can install wslu and use wslview as the command
    browser_command = 'xdg-open',
    host_mappings = {
      ["gitlab.mycompany.com"] = "gitlab",
    }
  }
}

```

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 💰 Funding

I do not need any money or support, but please support the Neovim project. They are doing an awesome job!
