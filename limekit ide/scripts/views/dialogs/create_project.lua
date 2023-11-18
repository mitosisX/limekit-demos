function projectCreator()
    modal = Modal(window, 'Project creator - Limekit')
    modal:setSize(300, 200)

    createLayout = VLayout()

    createImage = Label()
    createImage:setImage(images('homepage/create_project/package.png'))
    createImage:setTextAlign('center')

    createHeader = Label('<strong>Create your project</strong>')
    createHeader:setTextAlign('center')

    createName = Label('Name')
    createNameLineEdit = LineEdit()

    createVersion = Label('Version')
    createVersionLineEdit = LineEdit()

    createIcon = Label('Icon')
    createIconImage = Label()
    createIconImage:setImage(route('app_icon'))
    createIconImage:setCursor('forbidden')

    createButton = Button('Create')
    createButton:setIcon(images('homepage/create_project/done.png'))
    createButton:setOnClick(createUserProject)

    -- Now, display everything all together
    createLayout:addChild(createImage)
    createLayout:addChild(createHeader)

    createLayout:addChild(createName)
    createLayout:addChild(createNameLineEdit)

    createLayout:addChild(createVersion)
    createLayout:addChild(createVersionLineEdit)

    createLayout:addChild(createIcon)
    createLayout:addChild(createIconImage)

    createLayout:addChild(createButton)

    -- buttons = modal:getButtons({'ok', 'cancel'})
    -- v:addChild(buttons)

    modal:setLayout(createLayout)
    createNameLineEdit:setText('tester')

    print(modal:show())
end

projectJsonStruct = {
    project = {
        name = "Button Group",
        author = "Limekit",
        description = "Brief project description",
        copyright = "© 2023 Limekit. All Rights Reserved",
        version = "1.0.1",
        email = "limekit@lua.gui",
        lua_require = ""
    }
}

-- This handles all the user project creation
function createUserProject()

    createdUserProjectFolder = app.joinPaths(limekitProjectsFolder, createNameLineEdit:getText())

    if not app.checkExists(createdUserProjectFolder) then
        app.createFolder(createdUserProjectFolder) -- create the folder for the new project

        scriptsFolder = app.joinPaths(createdUserProjectFolder, 'scripts')
        imagesFolder = app.joinPaths(createdUserProjectFolder, 'images')
        miscFolder = app.joinPaths(createdUserProjectFolder, 'misc')

        -- Create all requir project folders
        app.createFolder(scriptsFolder)
        app.createFolder(imagesFolder)
        app.createFolder(miscFolder)

        mainLuaStruct =
            "-- Welcome to the new era for modern lua gui development\nwindow = Window{title='New app - Limekit', icon = images('app.png'), size={400, 200}}\nwindow:show()"

        -- Now write to the main.lua
        app.writeFile(app.joinPaths(scriptsFolder, 'main.lua'), mainLuaStruct)
        app.writeFile(app.joinPaths(createdUserProjectFolder, 'app.json'), json.stringify(projectJsonStruct))
    else
        writeToConsole('Already exists')
        app.criticalAlert(window, 'Error!', 'Could not create the project. Project already exists.')
    end

end
