docksLay = VLayout()

toolboxDock = Dock("Limekit Arsenal")
toolboxDock:setMagneticAreas(nil)
toolboxDock:setProperties(nil)

scroll = Scrollable()
l = VLayout()
scroll:setLayout(l)
l:setMargins(0,0,0,0)
coll = Collapsible()
l:addChild(coll)
coll.addChild(ListBox({"One","Two","Three"}), 'Toolbox')
coll.addChild(ListBox({"One","Two","Three"}), 'Toolbox')
coll.addChild(ListBox({"One","Two","Three"}), 'Toolbox')

toolboxDock:setChild(scroll)

editDBDocks = Dock("Edit Database Cell")

appLog = Dock("Application Log")
logConsole = TextField()
logConsole:setMaxHeight(150)

for a=0, 50 do
	txt = logConsole.getText()
	logConsole.setText(txt..py.str_format('\nLog Number {}', a))
end

appLog:setChild(logConsole)


docksLay:addChild(editDBDocks)