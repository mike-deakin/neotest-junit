local async = require'nio'.tests
local plugin = require'neotest-junit'({})

describe("Adapter root", function ()
    async.it("should return directory path if it contains a build.gradle", function ()
        local workingDir = './test/gradle-project'
        local adapterRoot = plugin.root(workingDir)

        assert.equal(workingDir, adapterRoot)
    end)

    async.it("should return directory path if it contains a pom.xml", function ()
        local workingDir = './test/maven-project'
        local adapterRoot = plugin.root(workingDir)

        assert.equal(workingDir, adapterRoot)
    end)

    async.it("should return nil if directory is not a project directory", function ()
        local workingDir = './test/non-project-dir'
        local adapterRoot = plugin.root(workingDir)

        assert.equal(nil, adapterRoot)
    end)
end)
