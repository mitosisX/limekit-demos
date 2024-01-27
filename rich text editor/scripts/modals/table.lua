tableModal = Modal(window, "Insert Table")
tableModal:setSize(200, 100)

rowsLabel = Label("Rows: ")

rows = Spinner()

colsLabel = Label("Columns")

cols = Spinner()

spaceLabel = Label("Cell spacing")

space = Spinner()

padLabel = Label("Cell padding")

pad = Spinner()

pad:setValue(10)

insertButton = Button("Insert")
insertButton:setOnClick(function()
    theRows = rows.getValue()

    theCols = cols.getValue()

    if theRows == 0 or theCols == 0 then
        app.warningAlertDialog(window, "Parameter error", "Row and column numbers may not be zero!")

    else
        thePadding = pad.getValue()

        theSpace = space.getValue()

        textEditor:addCursorTable(theRows, theCols, thePadding, theSpace)
        tableModal:dismiss()
    end

end)

layout = GridLayout()

layout:addChild(rowsLabel, 0, 0)
layout:addChild(rows, 0, 1)

layout:addChild(colsLabel, 1, 0)
layout:addChild(cols, 1, 1)

layout:addChild(padLabel, 2, 0)
layout:addChild(pad, 2, 1)

layout:addChild(spaceLabel, 3, 0)
layout:addChild(space, 3, 1)

layout:addChild(insertButton, 4, 0, 1, 2)

tableModal:setLayout(layout)
