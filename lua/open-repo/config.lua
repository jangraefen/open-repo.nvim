local log = require("open-repo.util.log")

local OpenRepo = {}

--- OpenRepo configuration with its default values.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
OpenRepo.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
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
    assert(
        type(OpenRepo.options.debug) == "boolean",
        "`debug` must be a boolean (`true` or `false`)."
    )

    return OpenRepo.options
end

--- Define your open-repo setup.
---
---@param options table Module config table. See |OpenRepo.options|.
---
---@usage `require("open-repo").setup()` (add `{}` with your |OpenRepo.options| table)
function OpenRepo.setup(options)
    OpenRepo.options = OpenRepo.defaults(options or {})

    log.warn_deprecation(OpenRepo.options)

    return OpenRepo.options
end

return OpenRepo
