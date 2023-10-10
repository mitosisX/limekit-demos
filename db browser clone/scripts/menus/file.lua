fileMenu = Menu('File')

newDB = MenuItem("New Database...")
newDB:setImage(images('database_add.png'))
newDB:setShortcut('Ctrl+N')

newMemoryDB = MenuItem("New In-Menory Database")

openDB = MenuItem("Open Database")
openDB:setImage(images('database_go.png'))

openDBReadOnly = MenuItem("Open Database Read-Only...")
openDBReadOnly:setImage(images('database_go.png'))

attachDB = MenuItem("Attach Database")
attachDB:setImage(images('database_link.png'))

closeDB = MenuItem("Close Database")
closeDB:setImage(images('cross.png'))

writeChanges = MenuItem('Write Changes')
writeChanges:setImage(images('database_save.png'))

revertChanges = MenuItem('Revert Changes')
revertChanges:setImage(images('database_refresh.png'))

import = MenuItem('Import')
export = MenuItem('Export')

openProject = MenuItem('Open Project...')
openProject:setImage(images('package_go.png'))

saveProject = MenuItem('Save Project')
saveProject:setImage(images('package_save.png'))

saveProjectAs = MenuItem('Save Project As...')

saveAll = MenuItem('Save All')
saveAll:setImage(images('package_save.png'))

exit = MenuItem('Exit')
exit:setShortcut(images('cross.png'))
exit:setShortcut('Ctrl+Q')

fileMenu:addMenuItem(newDB)
fileMenu:addMenuItem(newMemoryDB)
fileMenu:addMenuItem(openDB)
fileMenu:addMenuItem(openDBReadOnly)
fileMenu:addMenuItem(attachDB)
fileMenu:addMenuItem(MenuItem('-'))

fileMenu:addMenuItem(closeDB)
fileMenu:addMenuItem(MenuItem('-'))

fileMenu:addMenuItem(writeChanges)
fileMenu:addMenuItem(revertChanges)
fileMenu:addMenuItem(MenuItem('-'))

fileMenu:addMenuItem(import)
fileMenu:addMenuItem(export)
fileMenu:addMenuItem(MenuItem('-'))

fileMenu:addMenuItem(openProject)
fileMenu:addMenuItem(saveProject)
fileMenu:addMenuItem(saveProjectAs)
fileMenu:addMenuItem(MenuItem('-'))

fileMenu:addMenuItem(saveAll)
fileMenu:addMenuItem(exit)