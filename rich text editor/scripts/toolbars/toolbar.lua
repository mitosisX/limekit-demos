toolbar = Toolbar('Options')

newAction = ToolbarButton("New")
newAction:setIcon(images("new.png"))
-- newAction:.setStatusTip("Create a new document from scratch.")
newAction:setShortcut("Ctrl+N")

openAction = ToolbarButton("Open file")
openAction:setIcon(images("open.png"))
-- openAction:setStatusTip("Open existing document")
openAction:setShortcut("Ctrl+O")
openAction:setOnClick(function()
    filename = app.openFileDialog(window, 'Open file', '', {
        ['Lime Text'] = {'.limetxt'}
    })

    if (filename ~= "") then
        textEditor:setText(app.readFile(filename))
    end
end)

saveAction = ToolbarButton("Save")
saveAction:setIcon(images("save.png"))
-- saveAction:.setStatusTip("Save document")
saveAction:setShortcut("Ctrl+S")
saveAction:setOnClick(function()
    filename = app.saveFileDialog(window, 'Save file', '', {
        ['Lime Text'] = {'.limetxt'}
    })

    if (filename ~= "") then
        app.writeFile(filename, textEditor:getHtmlText())
    end
end)

toolbar:addButton(newAction)
toolbar:addButton(openAction)
toolbar:addButton(saveAction)

toolbar:addSeparator()

cutAction = ToolbarButton("Cut to clipboard")
cutAction:setIcon(images("cut.png"))
-- cutAction:.setStatusTip("Delete and copy text to clipboard")
cutAction:setShortcut("Ctrl+X")
cutAction:setOnClick(function()
    textEditor:cut()
end)

copyAction = ToolbarButton("Copy to clipboard")
copyAction:setIcon(images("copy.png"))
-- copyAction:.setStatusTip("Copy text to clipboard")
copyAction:setShortcut("Ctrl+C")
copyAction:setOnClick(function()
    textEditor:copy()
end)

pasteAction = ToolbarButton("Paste from clipboard")
pasteAction:setIcon(images("paste.png"))
-- pasteAction:.setStatusTip("Paste text from clipboard")
pasteAction:setShortcut("Ctrl+V")
pasteAction:setOnClick(function()
    textEditor:paste()
end)

undoAction = ToolbarButton("Undo last action")
undoAction:setIcon(images("undo.png"))
-- undoAction:.setStatusTip("Undo last action")
undoAction:setShortcut("Ctrl+Z")
undoAction:setOnClick(function()
    textEditor:undo()
end)

redoAction = ToolbarButton("Redo last undone thing")
redoAction:setIcon(images("redo.png"))
-- redoAction:.setStatusTip("Redo last undone thing")
redoAction:setShortcut("Ctrl+Y")
redoAction:setOnClick(function()
    textEditor:redo()
end)

toolbar:addButton(cutAction)
toolbar:addButton(copyAction)
toolbar:addButton(pasteAction)
toolbar:addButton(undoAction)
toolbar:addButton(redoAction)

toolbar:addSeparator()

tableAction = ToolbarButton("Insert table")
tableAction:setIcon(images('table.png'))
tableAction:setOnClick(function()
    tableModal:show()
end)

toolbar:addButton(tableAction)

toolbar:addSeparator()

bulletAction = ToolbarButton("Insert bullet List")
bulletAction:setIcon(images("bulleted.png"))
bulletAction.setStatusTip("Insert bullet list")
bulletAction:setShortcut("Ctrl+Shift+B")
bulletAction:setOnClick(function(self)
    textEditor:setCursorTextFormat('listdisc')
end)

numberedAction = ToolbarButton("Insert numbered List")
numberedAction:setIcon(images("numbered.png"))
-- numberedAction.setStatusTip("Insert numbered list")
numberedAction:setShortcut("Ctrl+Shift+L")
numberedAction:setOnClick(function(self)
    textEditor:setCursorTextFormat('listdecimal')
end)

toolbar:addButton(bulletAction)
toolbar:addButton(numberedAction)
