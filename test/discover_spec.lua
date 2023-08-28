local async = require 'nio'.tests
local adapter = require 'neotest-junit' ()

local function file_length(file_path)
    return tonumber(vim.fn.system({ 'wc', '-l', file_path }):match('%d+'))
end

describe('discover_positions treesitter query', function()
    async.it('should return tree containing "describe" positions for java files', function()
        local spec_file_name = "SomeTest.java"
        local spec_file = "test/non-project-dir/" .. spec_file_name
        local positions = adapter.discover_positions(spec_file):to_list()

        local expectedLocations = {
            {
                id = spec_file,
                name = spec_file_name,
                path = spec_file,
                range = { 0, 0, file_length(spec_file), 0 },
                type = "file",
            },
            {
                {
                    id = spec_file .. '::SomeTest', -- TODO: change id to be a jvm path (org.some.pack.name.SomeTest in this case)
                    name = 'SomeTest',
                    path = spec_file,
                    range = { 2, 0, file_length(spec_file) - 1, 1 },
                    type = 'namespace'
                },
                {
                    {
                        id = spec_file .. '::SomeTest::shouldBeATest',
                        name = 'shouldBeATest',
                        path = spec_file,
                        range = { 8, 4, 11, 5 },
                        type = 'test'
                    }
                }
            }
        }

        assert.same(expectedLocations, positions)
    end)

    async.it('should return tree containing "describe" positions for kotlin files', function()
        local spec_file_name = "SomeTest.java"
        local spec_file = "./test/non-project-dir/" .. spec_file_name
        local positions = adapter.discover_positions(spec_file):to_list()

        local expectedLocations = {
            {
                id = spec_file,
                name = spec_file_name,
                path = spec_file,
                range = { 0, 0, file_length(spec_file), 0 },
                type = "file",
            },
            {
                {
                    id = spec_file .. '::SomeTest', -- TODO: change id to be a jvm path (org.some.pack.name.SomeTest in this case)
                    name = 'SomeTest',
                    path = spec_file,
                    range = { 2, 0, file_length(spec_file) - 1, 1 },
                    type = 'namespace'
                },
                {
                    {
                        id = spec_file .. '::SomeTest::shouldBeATest',
                        name = 'shouldBeATest',
                        path = spec_file,
                        range = { 8, 4, 11, 5 },
                        type = 'test'
                    }
                }
            }
        }

        assert.same(expectedLocations, positions)
    end)
end)
