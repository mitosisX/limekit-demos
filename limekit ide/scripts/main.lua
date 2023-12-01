--[[
				Limekit Runner

			Copyright: 
			Author: Omega Msiska

			(Note: This source code is provided unobfuscated and commented
			in the hope that it is useful for educational purposes. It remains the copyright of )

		v 1.0
		Development Time: 10 November, 2023

]] --
theme = Theme('darklight')
theme:setTheme('light')

json = require 'json'

-- System related
projectRunnerProcess = None -- The process handling the execution of user program

-- Path to documents
documentsFolder = app.getStandardPath('documents')
limekitProjectsFolder = app.joinPaths(documentsFolder, 'limekit projects/')
userProjectJSON = None -- The app.json for each projects
createdUserProjectFolder = "" -- The folder for the current project

-- Folders for user project
scriptsFolder = ""
imagesFolder = ""
miscFolder = ""

app.execute(scripts('views/homepage/welcome.lua'))
app.execute(scripts('commons/functions/main.lua'))
app.execute(scripts('commons/menus.lua'))
app.execute(scripts('views/toolbar/main.lua'))
app.execute(scripts('views/tabs/main.lua'))
app.execute(scripts('views/docks/main.lua'))

if not app.checkExists(limekitProjectsFolder) then
    app.createFolder(limekitProjectsFolder)
end

window = Window {
    title = "Limekit Runner",
    icon = route('app_icon'),
    size = {1000, 600}
}

window:setOnShown(function()
    window:maximize()
end)

app.setFontFile(misc('Comfortaa-Regular.ttf'), 8)

mainLay = VLayout() -- The master layout for the whole app

segmentation = Splitter('horizontal')

db = Sqlite3('D:/sandbox/limekit.db')

menubar = Menubar()
menubar:buildFromTemplate(appMenubarItems) -- derived from commons/menus.lua
window:setMenubar(menubar)

window:addToolbar(toolbar)

segmentation:addChild(toolboxDock)

seg = Splitter('vertical')

homeStackedWidget = SlidingStackedWidget() -- Holds the welcome page and app's page
homeStackedWidget:setOrientation('vertical')
homeStackedWidget:setAnimation('OutExpo')
-- homeStackedWidget.autoStart() -- should comment out this one

homeStackedWidget:addLayout(welcomeView)
homeStackedWidget:addChild(allAppTabs) -- The Tab holding App, Assets, Properties..

seg:addChild(homeStackedWidget) -- welcome page - from components
seg:addChild(appLog)

segmentation:addChild(seg)
segmentation:addLayout(docksLay)

mainLay:addChild(segmentation)

window:setLayout(mainLay)
window:show()
