local async = require 'nio'.tests
local adapter = require 'neotest-junit' ()

local function file_length(file_path)
    return tonumber(vim.fn.system({ 'wc', '-l', file_path }):match('%d+'))
end

describe("Adapter root", function()
    async.it("should return directory path if it contains a build.gradle", function()
        local workingDir = './test/gradle-project'
        local projectRoot = adapter.root(workingDir)

        assert.equal(workingDir, projectRoot)
    end)

    async.it("should return directory path if it contains a pom.xml", function()
        local workingDir = './test/maven-project'
        local projectRoot = adapter.root(workingDir)

        assert.equal(workingDir, projectRoot)
    end)

    async.it("should return nil if directory is not a project directory", function()
        local workingDir = './test/non-project-dir'

        assert.Nil(adapter.root(workingDir))
    end)
end)

describe('is_test_file check function', function()
    for _, ext in ipairs({ '.java', '.kt', '.groovy', '.gvy' }) do
        async.it('should return true for file names ending in "Test' .. ext .. '"', function()
            assert.True(adapter.is_test_file('SomeClassTest' .. ext))
        end)

        async.it('should return false for regular source files', function()
            assert.False(adapter.is_test_file('SomeClass' .. ext))
        end)
    end

    async.it('should return false for non-JVM source files', function()
        assert.False(adapter.is_test_file('HowToTest.md'))
    end)
end)

describe('filter_dir test file path filter', function()
    async.it('should return true for src/test directories', function()
        assert.True(adapter.filter_dir('anything', 'src/test/anything', './test/gradle-project'))
    end)
end)

describe('discover_positions treesitter query', function()
    async.it('should return tree containing "describe" positions', function()
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

describe('build_spec', function()
    describe('for gradle projects', function()
        async.it('should run a test file', function()
            local specFile = "./test/gradle-project/SomeTest.java"
            local positions = adapter.discover_positions(specFile):to_list()
            local tree = require 'neotest.types'.Tree.from_list(positions, function(pos)
                return pos.id
            end)
            local spec = adapter.build_spec({ tree = tree })

            assert.same("./gradlew test --tests " .. specFile, spec.command)
        end)

        async.it('should run a namespace (test class)', function()
            local specFile = "./test/gradle-project/SomeTest.java"
            local positions = adapter.discover_positions(specFile):to_list()
            local tree = require 'neotest.types'.Tree.from_list(positions, function(pos)
                return pos.id
            end)
            local spec = adapter.build_spec({ tree = tree:children()[1] })

            assert.same("./gradlew test --tests SomeTest", spec.command)
        end)

        async.it('should run a test (test method)', function()
            local specFile = "./test/gradle-project/SomeTest.java"
            local positions = adapter.discover_positions(specFile):to_list()
            local tree = require 'neotest.types'.Tree.from_list(positions, function(pos)
                return pos.id
            end)
            local spec = adapter.build_spec({ tree = tree:children()[1]:children()[1] })

            assert.same("./gradlew test --tests shouldBeATest", spec.command)
        end)
    end)
end)
