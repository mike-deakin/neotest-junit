local lib = require 'neotest.lib'

local M = {}

local queries = {
    ['kt'] = [[
(class_declaration
      (type_identifier) @namessace.name
) @namespace.definition

(function_declaration
  (modifiers (annotation (user_type (type_identifier) @annotation))) (#eq? @annotation "Test")
  (simple_identifier) @test.name
) @test.definition
    ]],

    ['java'] = [[
(class_declaration
      name: (identifier) @namespace.name
) @namespace.definition

(method_declaration
    (modifiers (marker_annotation (identifier) @annotation.name)) (#eq? @annotation.name "Test")
    (identifier) @test.name
) @test.definition
    ]],
}

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function M.discover_positions(file_path)
    local fext = string.match(file_path, '%.([^.]+)$')
    local query = queries[fext]

    if query ~= nil then
        return lib.treesitter.parse_positions(file_path, query, {})
    end
    return nil
end

return M
