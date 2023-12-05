function writeToConsole(content)
    logConsole:appendText('>> ' .. content)
end

function clearConsole()
    logConsole:setText("")
end

-- This is where all edit fields are provided with values from the 
function openProject()
    file = app.openFileDialog(window, "Open a project", limekitProjectsFolder, {
        ["Limekit app"] = {".json"}
    })

    if file ~= "" then
        homeStackedWidget:slideNext() -- switch from welcome page to app's page

        userProjectFolder = string.match(file, '.*/') -- This gets the folder for the selected project

        readPackagePaths()

        userProjectJSON = app.readJSON(file) -- the app.json

        scriptsFolder = app.joinPaths(userProjectFolder, 'scripts')
        imagesFolder = app.joinPaths(userProjectFolder, 'images')
        miscFolder = app.joinPaths(userProjectFolder, 'misc')

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
-- This is where all the magic happens ;-)

function runProject()
    clearConsole()

    writeToConsole('Please wait while running your app')

    projectRunnerProcess = app.runProject(userProjectFolder) -- Setting the global var in main.lua

    projectRunnerProcess:setOnProcessReadyRead(function(data)
        if string.find(data, 'Error:') or string.find(data, 'ython>"]') then
            writeToConsole("<span style='color:red;'>" .. data .. '</span>')
        else
            writeToConsole(data)
        end
    end)

    projectRunnerProcess:setOnProcessStarted(function()
        writeToConsole('<strong>Starting app</strong>')

        runAppButton:disable()
        runAppButton:setText('Running')
        runProgress:setVisibility(true)

    end)

    projectRunnerProcess:setOnProcessFinished(function()
        writeToConsole('<strong>App closed</strong>')

        runAppButton:enable()
        runAppButton:setText('Run')
        runProgress:setVisibility(false)

    end)

    projectRunnerProcess:run()
end

-- The .require file in the user folder
function readPackagePaths()
    requirePathsFile = app.joinPaths(userProjectFolder, '.require')

    if app.exists(requirePathsFile) then
        local readTheFile = app.readFile(requirePathsFile)
        local splitted = app.splitString(readTheFile, '\n')

        pathsList:setItems(splitted)
    end
end
