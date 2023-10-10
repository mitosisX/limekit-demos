-- ##### Toolbar 1
toolbar1 = Toolbar()
toolbar1:setImageStyle('textbesideicon')

newDBToolbarButton = ToolbarButton('New Database')
newDBToolbarButton:setImage(images('database_add.png'))

openDBToolbarButton = ToolbarButton('Open Database')
openDBToolbarButton:setImage(images('database_go.png'))

writeChangesToolbar = ToolbarButton('Write Changes')
writeChangesToolbar:setImage(images('database_save.png'))

revertChangesToolbar = ToolbarButton('Revert Changes')
revertChangesToolbar:setImage(images('database_refresh.png'))

toolbar1:addButton(newDBToolbarButton)
toolbar1:addButton(openDBToolbarButton)
toolbar1:addButton(ToolbarButton('-'))
toolbar1:addButton(writeChangesToolbar)
toolbar1:addButton(revertChangesToolbar)

-- ##### Toolbar 2
toolbar2 = Toolbar()
toolbar2:setImageStyle('textbesideicon')

openProjectToolbar = ToolbarButton('Open Project')
openProjectToolbar:setImage(images('package_go.png'))

saveProjectToolbar = ToolbarButton('Save Project')
saveProjectToolbar:setImage(images('package_save.png'))

toolbar2:addButton(openProjectToolbar)
toolbar2:addButton(saveProjectToolbar)

-- ##### Toolbar 3
toolbar3 = Toolbar()
toolbar3:setImageStyle('textbesideicon')

openProjectToolbar = ToolbarButton('Attach Database')
openProjectToolbar:setImage(images('database_link.png'))

closeDBToolbar = ToolbarButton('Close Database')
closeDBToolbar:setImage(images('cross.png'))

toolbar3:addButton(openProjectToolbar)
toolbar3:addButton(closeDBToolbar)