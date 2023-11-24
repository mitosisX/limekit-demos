function writeToConsole(content)
    logConsole:appendText('>> ' .. content)
end

function clearConsole()
    logConsole:setText("")
end

-- This is where all edit fields are provided with values from the 
function openProject()
    file = app.openFile(window, "Open a project", limekitProjectsFolder, {
        ["Limekit app"] = {".json"}
    })

    if file ~= "" then
        -- homeStackedWidget:slideNext() -- switch from welcome page to app's page

        createdUserProjectFolder = string.match(file, '.*/') -- This gets the folder for the selected project

        userProjectJSON = app.readJSON(file) -- the app.json

        scriptsFolder = app.joinPaths(createdUserProjectFolder, 'scripts')
        imagesFolder = app.joinPaths(createdUserProjectFolder, 'images')
        miscFolder = app.joinPaths(createdUserProjectFolder, 'misc')

        local appName = userProjectJSON.project.name -- will be used in multiple location

        loadedAppName:setText(py.str_format('App: <strong>{}</strong> ', appName))
        editAppName:setText(appName)

        editAppVersion:setText(userProjectJSON.project.version)
        editAppAuthor:setText(userProjectJSON.project.author)
        editAppCopyright:setText(userProjectJSON.project.copyright)
        editAppDescription:setText(userProjectJSON.project.description)
        editAppEmail:setText(userProjectJSON.project.email)

        loadedAppIcon:setImage(app.joinPaths(imagesFolder, 'window.png'))
    end
end

-- 24 November, 2023 (12:29 PM)
-- This is where all the magic happens

function runProject()
    writeToConsole('Please wait while running your app')

    runner = app.runProject(createdUserProjectFolder)

    runner:setOnProcessReadyRead(function(data)
        if string.find(data, 'Error:') then
            print(2)
        end

        writeToConsole(data)
    end)

    runner:setOnProcessStarted(function()
        writeToConsole('<strong>Starting app</strong>')

        runAppButton:disable()
        runAppButton:setText('Running')
        runProgress:setVisibility(true)

    end)

    runner:setOnProcessFinished(function()
        writeToConsole('<strong>App closed</strong>')

        runAppButton:enable()
        runAppButton:setText('Run')
        runProgress:setVisibility(false)

    end)

    runner:run()
end

-- function runProject_()

--     worker = Worker()
--     worker:setOnThreadRun(function()
--         -- dir = string.match(file, '.*/')
--         output = app.runProject(createdUserProjectFolder)
--         -- print(output)
--         -- writeToConsole(output)
--     end)
--     worker:start()

-- end
