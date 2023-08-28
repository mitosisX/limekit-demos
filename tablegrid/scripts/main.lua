-- Creating a window
window = Window()
window:setIcon(images("javascript.png"))

-- Creating a main horizontal layout
mainLay = VLayout()

theme = Theme("material")
theme:setTheme("light_blue")

app.setClipboardText('Clipboard')

-- Creating a table grid with dimensions 10x10
table = TableGrid(10, 10)
-- table.setCellsEditable(false)
ckbox=Calendar()
-- ckbox.onClick(function()
--     print('Clicked')
-- end)
table.setCellWidget(0, 2, ckbox)
-- table.setGridVisible(false) -- Hides the grid lines
-- table:setHeaderToolTip(1, 'Names go here')
table:setColumns(4)
table.setRowLabelsVisible(false)
-- table.setColumnWidth(0,200)
table:setColumnHeaders({'Name','Surname'})

table.setHeaderToolTip(0, 'Holds names')

-- Setting data in the table at row 1, column 0
table:setData(1, 0, "Text")
table:setData(9, 0, "Text")

-- Adding an event handler for when a cell edit is finished
table:onCellEditFinish(function (obj, row, column)
    -- Your code for handling cell edit finish goes here
end)

-- Creating a dock on the right side with title "Employees"
rightDock = Dock("Employees")

btnLay = HLayout()

table.deleteRows(2)

-- Adding the right dock to the window
-- window:addDock(rightDock, "right")

-- Setting the central child of the window as the table
window:setMainWidget(table)

-- Displaying the window
window:show()