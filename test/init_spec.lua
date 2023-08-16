local async = require 'nio'.tests
local plugin = require 'neotest-junit' ()

describe("Adapter root", function()
    async.it("should return directory path if it contains a build.gradle", function()
        local workingDir = './test/gradle-project'
        local adapterRoot = plugin.root(workingDir)

        assert.equal(workingDir, adapterRoot)
    end)

    async.it("should return directory path if it contains a pom.xml", function()
        local workingDir = './test/maven-project'
        local adapterRoot = plugin.root(workingDir)

        assert.equal(workingDir, adapterRoot)
    end)

    async.it("should return nil if directory is not a project directory", function()
        local workingDir = './test/non-project-dir'

        assert.Nil(plugin.root(workingDir))
    end)
end)

describe('is_test_file check function', function()
    for _, ext in ipairs({ '.java', '.kt', '.groovy', '.gvy' }) do
        async.it('should return true for file names ending in "Test' .. ext .. '"', function()
            assert.True(plugin.is_test_file('SomeClassTest' .. ext))
        end)

        async.it('should return false for regular source files', function ()
            assert.False(plugin.is_test_file('SomeClass' .. ext))
        end)
    end

    async.it('should return false for non-JVM source files', function ()
        assert.False(plugin.is_test_file('HowToTest.md'))
    end)
end)
