-- Creating a window
window = Window("TableGrid - Limekit")
window:setSize(520,310)
window:setIcon(images("lua.png"))

-- Creating a main horizontal layout
mainLay = VLayout()

theme = Theme("material")
theme:setTheme("light_blue")

-- Creating a table grid with dimensions 10x10
table = TableGrid(10, 10)
table:setColumnSorting(false)
-- table.setAltRowColors(true)
-- table.setCellsEditable(false)
combo = ComboBox()
combo:addImageItems({{'lua', images('lua.png') }, {'malawi', images('malawi.png')}, {'heart', images('heart.png') }});

-- combo.addDataItems({'Pass','Failed'})
-- ckbox.onClick(function()
--     print('Clicked')
-- end)
table:setCellChild(0, 2, combo)
-- table.setGridVisible(false) -- Hides the grid lines
-- table:setHeaderToolTip(1, 'Names go here')
table:setMaxColumns(4)
-- table.setRowLabelsVisible(false)
-- table.setColumnWidth(0,200)
table:setColumnHeaders({'Name','Surname','Age','Class','Grade'})
table:setRowHeaders({'Biology','Physics','Mathematics','English','Geography','Agriculture','Computer','Economics','Chemistry','Total'})

table:setColumnHeaderToolTip(0, 'Holds names')

-- Setting data in the table at row 1, column 0
table:setData(9, 0, "200")

-- Adding an event handler for when a cell edit is finished
table:onCellEditFinish(function (obj, row, column)
    -- Your code for handling cell edit finish goes here
end)

-- Creating a dock on the right side with title "Employees"
rightDock = Dock("Employees")

btnLay = HLayout()

table:deleteRows(2)

-- Adding the right dock to the window
-- window:addDock(rightDock, "right")

-- Setting the central child of the window as the table
window:setMainWidget(table)

-- Displaying the window
window:show()