--[[
				Limekit IDE

			Copyright: 
			Author:

			(Note: This source code is provided unobfuscated and commented
			in the hope that it is useful for educational purposes. It remains
		the copyright of )

		v 1.0
		Development Time: 10 November, 2023

]] --
Theme('darklight'):setTheme('light')

function fectchData()
    db:execute('SELECT * FROM Fruits;')
    data = db:fetchAll()

    return data
end

database = nil

-- app.joinTables({a = 1,b = 2},{c = 3},{d = 4,e = 5},{f = 6})

-- app.execute(scripts('menus/file.lua'))
-- app.execute(scripts('menus/edit.lua'))
-- app.execute(scripts('menus/view.lua'))
-- app.execute(scripts('menus/tools.lua'))
-- app.execute(scripts('menus/help.lua'))

-- app.execute(scripts('views/homepage/welcome.lua'))
app.execute(scripts('commons/functions/main.lua'))
app.execute(scripts('commons/menus.lua'))
app.execute(scripts('views/toolbar/main.lua'))
app.execute(scripts('views/tab/main.lua'))
app.execute(scripts('views/docks/main.lua'))

function openDBFile()
    file = app.openFile(window, "Choose a database file", "D:/sandbox", {
        ["SQLite database files"] = {".db", ".sqlite", ".sqlite3", ".db3"}
    })
    database = Sqlite3(file)

    getTables()
end

function getTables()
    tables = database:fetchTables()

    for index = 1, #tables do
        item = tables[index]
        tablesCombo:addItem(item)
    end
end

window = Window {
    title = "Limekit IDE",
    icon = route('app_icon'),
    size = {1000, 600}
}

app.setFontFile(misc('CeraPro-Regular.ttf'), 8)

window:maximize()

mainLay = VLayout() -- The master layout for the whole app

segmentation = Splitter('horizontal')

db = Sqlite3('D:/sandbox/limekit.db')

function changeTheme(obj)

    print(obj)
    -- theme = obj:getText()
    -- if theme == 'Light' then
    --     print('light')
    -- elseif theme == 'Dark' then
    --     print('dark')
    -- end
end

menubar = Menubar()
menubar:buildFromTemplate(appMenubarItems) -- derived from commons/menus.lua

window:setMenubar(menubar)

window:addToolbar(toolbar1)
window:addToolbar(toolbar2)
window:addToolbar(toolbar3)

segmentation:addChild(toolboxDock)

seg = Splitter('vertical')

stackLay = SlidingStackedWidget()
stackLay:setOrientation('vertical')
stackLay:setAnimation('OutExpo')
-- stackLay.autoStart() -- should comment out this one

stackLay:addChild(dbTab)
stackLay:addChild(Label('Something'))

seg:addChild(stackLay) -- welcome page - from components
seg:addChild(appLog)

segmentation:addChild(seg)
segmentation:addLayout(docksLay)

mainLay:addChild(segmentation)

window:setLayout(mainLay)
window:show()
