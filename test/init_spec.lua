local async = require 'nio'.tests
local adapter = require 'neotest-junit' ()

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
    for _, ext in ipairs { '.java', '.kt', '.groovy', '.gvy' } do
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
    for _, dir in ipairs { 'build', 'out', 'resources' } do
        async.it('should return false for ' .. dir .. ' directory', function()
            assert.False(adapter.filter_dir(dir, 'some/path/to/' .. dir, './test/gradle-project'))
        end)
    end
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

        async.it('should run a test within a subproject', function ()
            vim.cmd('cd ./test/gradle-project')
            local specFile = "./subproject/src/test/DifferentTest.kt"
            local positions = adapter.discover_positions(specFile):to_list()
            local tree = require 'neotest.types'.Tree.from_list(positions, function(pos)
                return pos.id
            end)
            local spec = adapter.build_spec({ tree = tree:children()[1]:children()[1] })

            assert.same("./gradlew subproject:test --tests `should be a test`", spec.command)
        end)
    end)
end)
