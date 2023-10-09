fileMenu = Menu('File')

newDB = MenuItem("New Database...")
newDB:setShortcut('Ctrl+N')
newMemoryDB = MenuItem("New In-Menory Database")
openDB = MenuItem("New In-Menory Database")
openDBReadOnly = MenuItem("Open Database Read-Only...")
attachDB = MenuItem("Attach Database")
closeDB = MenuItem("Close Database")

writeChanges = MenuItem('Write Changes')
revertChanges = MenuItem('Revert Changes')

import = MenuItem('Import')
export = MenuItem('Export')

openProject = MenuItem('Open Project...')
saveProject = MenuItem('Save Project')
saveProjectAs = MenuItem('Save Project As...')

saveProjectAs = MenuItem('Save Project As...')

saveAll = MenuItem('Save All')
exit = MenuItem('Exit')
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