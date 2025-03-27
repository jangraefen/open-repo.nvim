local main = require("open-repo.main")
local config = require("open-repo.config")

local OpenRepo = {}

--- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function OpenRepo.toggle()
    if _G.OpenRepo.config == nil then
        _G.OpenRepo.config = config.options
    end

    main.toggle("public_api_toggle")
end

--- Initializes the plugin, sets event listeners and internal state.
function OpenRepo.enable(scope)
    if _G.OpenRepo.config == nil then
        _G.OpenRepo.config = config.options
    end

    main.toggle(scope or "public_api_enable")
end

--- Disables the plugin, clear highlight groups and autocmds, closes side buffers and resets the internal state.
function OpenRepo.disable()
    main.toggle("public_api_disable")
end

-- setup OpenRepo options and merge them with user provided ones.
function OpenRepo.setup(opts)
    _G.OpenRepo.config = config.setup(opts)
end

_G.OpenRepo = OpenRepo

return _G.OpenRepo
