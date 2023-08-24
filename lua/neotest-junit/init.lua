local lib = require 'neotest.lib'

---@class neotest.Adapter
local Adapter = {
    name = 'neotest-junit',
    root = nil,
    filter_dir = nil,
    is_test_file = nil,
    discover_positions = require'neotest-junit.discover'.discover_positions,
    build_spec = nil,
    results = nil,
}

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param path string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function Adapter.root(path)
    return lib.files.match_root_pattern('build.gradle')(path)
        or lib.files.match_root_pattern('pom.xml')(path)
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function Adapter.filter_dir(name, rel_path, root)
    return string.match(rel_path, 'src/test') ~= nil
end

---@async
---@param file_path string
---@return boolean
function Adapter.is_test_file(file_path)
    for _, suffix in ipairs({ '.java', '.kt', '.groovy', '.gvy' }) do
        if string.match(file_path, 'Test' .. suffix .. '$') ~= nil then
            return true
        end
    end
    return false
end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function Adapter.build_spec(args) end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function Adapter.results(spec, result, tree)
    return {}
end

setmetatable(Adapter, {
    __call = function(_, _opts)
        return Adapter
    end,
})

return Adapter
