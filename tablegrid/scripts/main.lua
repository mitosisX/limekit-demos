-- Creating a window
window = Window("Table - Limekit")
window:setSize(558, 363)
window:setIcon(route('app_icon'))
window:setCustomCursor(images('pointer.png'))

-- app.setFont(misc('Oakle.ttf'), 10)

-- Creating a main horizontal layout
mainLay = VLayout()

theme = Theme("material")
theme:setTheme("light_blue")

-- Creating a table with dimensions 10x10
table = Table(10, 10)
table:setOnCellDoubleClicked(function(obj, row, column)
    item = TableItem(table:getItemAt(row, column))
    item:setText("400")
end)
table:setColumnSorting(false)
table:setTableData({
    ['text'] = 'Emoji ' .. app.emoji(':thumbs_up:'),
    ['row'] = 0,
    ['column'] = 1
})
-- table.setAltRowColors(true)
-- table.setCellsEditable(false)
combo = ComboBox()
combo:addImageItems({{'lua', images('lua.png')}, {'malawi', images('malawi.png')}, {'heart', images('heart.png')}});

table:setCellChild(0, 2, combo)
table:setImageData(images('down.png'), '23.19%', 1, 2)
table:setImageData(images('up.png'), '56.29%', 2, 2)
table:setImageData(images('down.png'), '12.75%', 3, 2)
-- table.setGridVisible(false) -- Hides the grid lines
-- table:setHeaderToolTip(1, 'Names go here')
table:setMaxColumns(4)
-- table.setRowLabelsVisible(false)
-- table.setColumnWidth(0,200)
table:setColumnHeaders({'Name', 'Surname', 'Age', 'Class', 'Grade'})
table:setRowHeaders({'Biology', 'Physics', 'Mathematics', 'English', 'Geography', 'Agriculture', 'Computer',
                     'Economics', 'Chemistry', 'Total'})

table:setColumnHeaderToolTip(0, 'Holds names')

-- Setting data in the table at row 1, column 0
table:setDataItem(9, 0, "200")
-- Adding an event handler for when a cell edit is finished
table:setOnCellEditFinished(function(obj, row, column)
    -- Your code for handling cell edit finish goes here
    print('done at' .. row .. ', ' .. column)
end)
table:setOnCellClicked(function(obj, row, column)
    print(row, column)
end)


-- Creating a dock on the right side with title "Employees"
rightDock = Dock("Employees")

btnLay = HLayout()

-- Adding the right dock to the window
-- window:addDock(rightDock, "right")

-- Setting the central child of the window as the table
mainLay:addChild(table)
window:setLayout(mainLay)

-- Displaying the window
window:show()
