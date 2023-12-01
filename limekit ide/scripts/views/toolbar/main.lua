app.execute(scripts('views/dialogs/create_project.lua'))

-- ##### Toolbar 1
toolbar = Toolbar()
toolbar:setIconStyle('textbesideicon')

newDBToolbarButton = ToolbarButton('New Project')
newDBToolbarButton:setIcon(images('toolbar/new_project.png'))
newDBToolbarButton:setOnClick(projectCreator)

openDBToolbarButton = ToolbarButton('Open Project')
openDBToolbarButton:setIcon(images('toolbar/open_project.png'))
openDBToolbarButton:setOnClick(openProject)

welcomePageToolbar = ToolbarButton('Welcome Page')
welcomePageToolbar:setIcon(images('card_file_box_3d.png'))
welcomePageToolbar:setOnClick(function()
    homeStackedWidget:slidePrev()
end)

revertChangesToolbar = ToolbarButton('Revert Changes')
revertChangesToolbar:setIcon(images('database_refresh.png'))

toolbar:addButton(newDBToolbarButton)
toolbar:addButton(openDBToolbarButton)
toolbar:addButton(ToolbarButton('-'))
toolbar:addButton(welcomePageToolbar)
toolbar:addButton(revertChangesToolbar)
