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

window:maximize()

mainLay = VLayout()
childMainLayout = HLayout()

segmentation = Segmenter('horizontal')

db = Sqlite3('D:/sandbox/limekit.db')

menubar = Menubar()
menubar:buildFromTemplate({{
    label = 'File',
    submenu = {{
        label = 'New Database...',
        icon = images('database_add.png'),
        shortcut = "Ctrl+N"
    }}
}, {
    label = 'View',
    name = 'View'
}})

-- menubar:addMenuItem(fileMenu)
-- menubar:addMenuItem(editMenu)
-- menubar:addMenuItem(viewMenu)
-- menubar:addMenuItem(toolsMenu)
-- menubar:addMenuItem(helpMenu)

window:setMenubar(menubar)

window:addToolbar(toolbar1)
window:addToolbar(toolbar2)
window:addToolbar(toolbar3)

segmentation:addChild(toolboxDock)

seg = Segmenter('vertical')

vLay = VLayout()

vLay:addChild(dbTab)
seg:addLayout(vLay)
seg:addChild(appLog)

segmentation:addChild(seg)
segmentation:addLayout(docksLay)

openDBToolbarButton:setOnClick(openDBFile)

mainLay:addChild(segmentation)

window:setLayout(mainLay)
window:show()
