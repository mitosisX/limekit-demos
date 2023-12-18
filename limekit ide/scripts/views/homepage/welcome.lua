welcomeView = VLayout()
welcomeView:setContentAlignment('vcenter', 'center')

welcomeText = Label('<strong>Welcome</strong> -')
welcomeText:setTextSize(25)

welcomeView:addChild(welcomeText)

welcomeContentLay = HLayout()

function makeHomepageCards(image_path, text)
    local group = GroupBox()

    local lay = VLayout()

    local image = Label()
    image:setTextAlign('center')
    image:setImage(image_path)
    image:resizeImage(80, 80)

    local label = Label(text)
    label:setTextAlign('center')

    lay:addChild(image)
    lay:addChild(label)
    group:setLayout(lay)

    welcomeContentLay:addChild(group)
end

makeHomepageCards(images('homepage/national_park_3d.png'), 'Develop modern UI')
makeHomepageCards(images('homepage/hundred.png'), 'Free to all users')
makeHomepageCards(images('homepage/battery.png'), 'Batteries Included')
makeHomepageCards(images('homepage/bug.png'), 'Please report bugs')
makeHomepageCards(images('homepage/support.png'), '<strong>Support the project<br>by puchasing a license</strong>')

welcomeView:addLayout(welcomeContentLay)

commandLay = HLayout()
commandLay:setContentAlignment('right')

commandCreateProject = CommandButton('Create a project')
commandCreateProject:setResizeRule('fixed', 'fixed')
commandCreateProject:setOnClick(projectCreator)

commandLay:addChild(commandCreateProject)

welcomeView:addLayout(commandLay)
