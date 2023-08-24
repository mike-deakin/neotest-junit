local lib = require 'neotest.lib'

local M = {}

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function M.discover_positions(file_path)
    local query = [[
    (class_declaration
          name: (identifier) @namespace.name
    ) @namespace.definition

    (method_declaration
        (modifiers (marker_annotation (identifier) @annotation.name)) (#eq? @annotation.name "Test")
        (identifier) @test.name
      ) @test.definition
    ]]

    return lib.treesitter.parse_positions(file_path, query, {
    })
end

return M
