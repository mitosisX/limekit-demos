app.execute(scripts('views/app/database.lua'))
app.execute(scripts('views/app/apptab.lua'))

allAppTabs = Tab()

appTab = TabItem()
appTab:setLayout(appTabMainLay)

browseDataTab = TabItem()
browseDataTab:setLayout(browseLay)

editPragramsTab = TabItem()
executeSQLTab = TabItem()

allAppTabs:addTab(appTab, "App", images('tabs/app.png'))

allAppTabs:addTab(editPragramsTab, "Assets", images('tabs/resources.png'))
allAppTabs:addTab(executeSQLTab, "Properties", images('tabs/properties.png'))
allAppTabs:addTab(browseDataTab, "Sqlite Browser", images('tabs/Database.png'))
