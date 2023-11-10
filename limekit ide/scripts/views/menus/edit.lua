editMenu = Menu('Edit')

createTable = MenuItem('Create Table...')
createTable:setImage(images('table_add.png'))

createIndex = MenuItem('Create Index...')
createIndex:setImage(images('tag_blue_add.png'))

preferences = MenuItem('Preferences...')
preferences:setImage(images('wrench.png'))

editMenu:addMenuItem(createTable)
editMenu:addMenuItem(MenuItem('-'))
editMenu:addMenuItem(createIndex)
editMenu:addMenuItem(MenuItem('-'))
editMenu:addMenuItem(preferences)