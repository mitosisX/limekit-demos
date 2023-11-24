app.execute(scripts('views/dialogs/create_project.lua'))

-- ##### Toolbar 1
toolbar1 = Toolbar()
toolbar1:setIconStyle('textbesideicon')

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

toolbar1:addButton(newDBToolbarButton)
toolbar1:addButton(openDBToolbarButton)
toolbar1:addButton(ToolbarButton('-'))
toolbar1:addButton(welcomePageToolbar)
toolbar1:addButton(revertChangesToolbar)

-- ##### Toolbar 2
toolbar2 = Toolbar()
toolbar2:setIconStyle('textundericon')

openProjectToolbar = ToolbarButton('Open Project')
openProjectToolbar:setIcon(images('package_go.png'))

saveProjectToolbar = ToolbarButton('Welcome Page')
saveProjectToolbar:setIcon(images('package_save.png'))

toolbar2:addButton(openProjectToolbar)
toolbar2:addButton(saveProjectToolbar)

-- ##### Toolbar 3
toolbar3 = Toolbar()
toolbar3:setIconStyle('textbesideicon')

openProjectToolbar = ToolbarButton('Attach Database')
openProjectToolbar:setIcon(images('database_link.png'))

closeDBToolbar = ToolbarButton('Close Database')
closeDBToolbar:setIcon(images('cross.png'))

toolbar3:addButton(openProjectToolbar)
toolbar3:addButton(closeDBToolbar)
