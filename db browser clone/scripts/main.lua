function fectchData()
	db:execute('SELECT * FROM Fruits;')
	data = db:fetchAll()

	return data
end

app.execute(scripts('menus/file.lua'))
app.execute(scripts('menus/edit.lua'))
app.execute(scripts('menus/view.lua'))
app.execute(scripts('menus/tools.lua'))
app.execute(scripts('menus/help.lua'))

app.execute(scripts('toolbar/toolbar.lua'))

window = Window("DB Browser for SQLite - Limekit")
window:setIcon(route('app_icon'))
window:setSize(1000, 600)

main_lay = HLayout()

db = Sqlite3('D:/sandbox/limekit.db')

menubar = Menubar()
menubar:addMenuItem(fileMenu)
menubar:addMenuItem(editMenu)
menubar:addMenuItem(viewMenu)
menubar:addMenuItem(toolsMenu)
menubar:addMenuItem(helpMenu)

window:setMenubar(menubar)

window:addToolbar(toolbar1)
window:addToolbar(toolbar2)
window:addToolbar(toolbar3)

window:setLayout(main_lay)
window:show()