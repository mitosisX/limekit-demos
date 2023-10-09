editMenu = Menu('Edit')

createTable = MenuItem('Create Table...')
createIndex = MenuItem('Create Index...')
preferences = MenuItem('Preferences...')

editMenu:addMenuItem(createTable)
editMenu:addMenuItem(MenuItem('-'))
editMenu:addMenuItem(createIndex)
editMenu:addMenuItem(MenuItem('-'))
editMenu:addMenuItem(preferences)