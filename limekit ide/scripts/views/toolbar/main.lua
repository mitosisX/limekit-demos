app.execute(scripts('views/dialogs/create_project.lua'))

-- ##### Toolbar 1
toolbar = Toolbar()
toolbar:setIconStyle('textbesideicon')

newProjectToolbarButton = ToolbarButton('New Project')
newProjectToolbarButton:setIcon(images('toolbar/new_project.png'))
newProjectToolbarButton:setOnClick(projectCreator)

openProjectToolbarButton = ToolbarButton('Open Project')
openProjectToolbarButton:setIcon(images('toolbar/open_project.png'))
openProjectToolbarButton:setOnClick(projectOpener)

homePageToolbarButton = ToolbarButton('Home Page')
homePageToolbarButton:setIcon(images('card_file_box_3d.png'))
homePageToolbarButton:setOnClick(returnHomePage)

recentlyOpenedToolbarButton = ToolbarButton('Recent Projects')
recentlyOpenedToolbarButton:setTooltip('Projects you just opened in the runner')
recentlyOpenedToolbarButton:setIcon(images('database_refresh.png'))

recentProjectsMenu = Menu()

-- recentProjectsMenu:buildFromTemplate({{
--     label = 'File'
-- }, {
--     label = 'sdsdsd'
-- }, {
--     label = 'sdsdsd'
-- }, {
--     label = 'sdsdsd'
-- }, {
--     label = 'sdsdsd'
-- }})

recentProjectsMenu:addMenuItem(MenuItem('Hello'))
recentProjectsMenu:addMenuItem(MenuItem('hello'))

recentlyOpenedToolbarButton:setMenu(recentProjectsMenu)

toolbar:addButton(newProjectToolbarButton)
toolbar:addButton(openProjectToolbarButton)
toolbar:addButton(ToolbarButton('-'))
toolbar:addButton(homePageToolbarButton)
toolbar:addButton(recentlyOpenedToolbarButton)
