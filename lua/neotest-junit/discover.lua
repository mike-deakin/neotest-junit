local lib = require 'neotest.lib'

local M = {}

local queries = {
    ['kt'] = [[
(class_declaration
      (type_identifier) @namespace.name
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
        return lib.treesitter.parse_positions(file_path, query, {
            build_position = 'require"neotest-junit.discover"._build_position'
        })
    end
    return nil
end

local function get_match_type(captured_nodes)
  if captured_nodes["test.name"] then
    return "test"
  end
  if captured_nodes["namespace.name"] then
    return "namespace"
  end
end

function M._build_position(file_path, source, captured_nodes)
    local subproject = string.match(file_path, '^%.?/?(.*)/src')
    if subproject ~= nil then
        subproject = subproject:gsub('/', ':')
    end
    local match_type = get_match_type(captured_nodes)
    if match_type then
        local name = vim.treesitter.get_node_text(captured_nodes[match_type .. ".name"], source)
        local definition = captured_nodes[match_type .. ".definition"]

        return {
            type = match_type,
            path = file_path,
            name = name,
            range = { definition:range() },
            subproject = subproject
        }
    end
end

return M
