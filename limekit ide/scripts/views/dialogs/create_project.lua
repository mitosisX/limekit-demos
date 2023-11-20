selIconPath = "" -- The path for the app icon, the user selected

function projectCreator()
    modal = Modal(window, "Let's get you started - Limekit")
    modal:setSize(550, 350)

    createMainLayout = HLayout()

    groupB = GroupBox()
    groupB:setBackgroundColor('#307DE1')

    gBLayo = VLayout()
    gBLayo:setContentAlignment('center')

    title1 = Label('<strong>Quick setup</strong>')
    title1:setTextColor('white')

    subTitle1 = Label('Takes seconds to get an app running\n')
    subTitle1:setTextColor('white')

    gBLayo:addChild(title1)
    gBLayo:addChild(subTitle1)

    title2 = Label('<strong>Cross-platform solution</strong>')
    title2:setTextColor('white')
    subTitle2 = Label('Same code for Window, Linux and macOS\n')
    subTitle2:setTextColor('white')

    gBLayo:addChild(title2)
    gBLayo:addChild(subTitle2)

    title3 = Label('<strong>Intuitive API</strong>')
    title3:setTextColor('white')
    subTitle3 = Label('Our API is friendly even to newbies\n')
    subTitle3:setTextColor('white')

    gBLayo:addChild(title3)
    gBLayo:addChild(subTitle3)

    title4 = Label('<strong>Modern GUI</strong>')
    title4:setTextColor('white')
    subTitle4 = Label('Develop modern looking programs in no time')
    subTitle4:setTextColor('white')

    gBLayo:addChild(title4)
    gBLayo:addChild(subTitle4)

    groupB:setLayout(gBLayo)
    createMainLayout:addChild(groupB)

    createLayout = VLayout()
    createLayout:setMargins(10, 0, 0, 0)
    createMainLayout:addLayout(createLayout)

    createImage = Label()
    createImage:setImage(images('homepage/create_project/package.png'))
    createImage:setTextAlign('center')

    createHeader = Label('<strong>Create your project</strong>')
    createHeader:setTextAlign('center')

    createName = Label('Name')
    createNameLineEdit = LineEdit()

    createVersion = Label('Version')
    createVersionLineEdit = LineEdit()
    createVersionLineEdit:setText('1.0.0')

    createIcon = Label('Icon')
    createIconImage = Label()
    createIconImage:setImage(images('homepage/create_project/pick_image.png'))
    createIconImage:setCursor('pointinghand')
    createIconImage:setOnClick(function(obj)
        selIcon = app.openFile(window, "Pick and image for the app", "", {
            ["App Icon"] = {".png"}
        })

        if selIcon ~= "" then
            selIconPath = selIcon

            -- set the image picked and do some resize
            if selIconPath then
                obj:setImage(selIconPath)
                obj:resizeImage(50, 50)
            end
        end
    end)

    createButton = Button('Create')
    createButton:setIcon(images('homepage/create_project/done.png'))
    createButton:setOnClick(processProjectCreation)

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

    modal:setLayout(createMainLayout)

    modal:show()
end

projectJsonStruct = {
    project = {
        name = "",
        author = "",
        description = "",
        copyright = "",
        version = "",
        email = ""
        -- lua_require = ""
    }
}

function processProjectCreation()
    userProjectNamePicked = createNameLineEdit:getText()
    userProjectVersionPicked = createVersionLineEdit:getText()

    if userProjectNamePicked ~= "" and userProjectVersionPicked ~= "" then
        if selIconPath ~= "" then
            createUserProject(userProjectNamePicked, userProjectVersionPicked)
        else
            app.warningAlert(window, 'Not complete', 'Please select an image for your app')
        end
    else
        app.warningAlert(window, 'Not complete', 'Make sure all fields are filled')
    end
end

-- This handles all the user project creation
function createUserProject(userProjectNamePicked, userProjectVersionPicked)

    createdUserProjectFolder = app.joinPaths(limekitProjectsFolder, userProjectNamePicked)

    if not app.checkExists(createdUserProjectFolder) then
        projectJsonStruct.name = userProjectNamePicked
        projectJsonStruct.version = userProjectVersionPicked

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

        app.copyFile(selIconPath, app.joinPaths(imagesFolder, 'app.png'))

        modal:dismiss()
    else
        app.criticalAlert(window, 'Error!', 'Could not create the project. Project already exists.')
    end

end
