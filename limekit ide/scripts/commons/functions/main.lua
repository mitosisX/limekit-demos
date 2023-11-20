function writeToConsole(content)
    logConsole:setText(content .. '\n')
end

function openProject()
    file = app.openFile(window, "Open a project", limekitProjectsFolder, {
        ["Limekit app"] = {".json"}
    })

    -- worker = Worker()
    -- worker:setOnThreadRun(function()
    --     dir = string.match(file, '.*/')

    --     print(app.readJSON(dir .. 'app.json'))
    --     output = app.runProject(dir, function(a)
    --         print('Output')
    --     end)

    --     -- print(output)
    --     -- writeToConsole(output)
    -- end)
    -- worker:start()

    -- writeToConsole(dir)
end
