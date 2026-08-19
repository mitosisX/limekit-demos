-- Table -- a grid of cells.
--
-- The one thing to carry over from 1.x: rows and columns start at 1 now.
-- setCellText(0, 0, ...) used to mean the top-left cell; today it raises and
-- says so, which is the whole point of the change.

local ui = require("limekit.ui")

local window = ui.Window { title = "Table - Limekit 2.0", size = { 720, 520 } }

local COLUMNS = { "Subject", "Term 1", "Term 2", "Grade" }
local ROWS = {
    { "Biology",     "72", "78", "B" },
    { "Chemistry",   "65", "61", "C" },
    { "English",     "88", "91", "A" },
    { "Geography",   "54", "60", "C" },
    { "Mathematics", "95", "93", "A" },
    { "Physics",     "70", "74", "B" },
}

local grid = ui.Table(#ROWS, #COLUMNS)
grid:setColumnHeaders(COLUMNS)
grid:setAlternatingRowColors(true)
grid:setSelectionBehavior("rows")

for row = 1, #ROWS do
    for column = 1, #COLUMNS do
        grid:setCellText(row, column, ROWS[row][column])
    end
end

-- Row headers are a separate list from the data.
local rowLabels = {}
for row = 1, #ROWS do rowLabels[row] = "S" .. row end
grid:setRowHeaders(rowLabels)

grid:setColumnWidth(1, 160)

local status = ui.Label("Click a cell.")
status:setWordWrap(true)

grid:setOnCellClick(function(sender, row, column)
    status:setText("Cell " .. row .. ", " .. column .. " = " .. sender:getCellItem(row, column):getText())
end)

grid:setOnCellDoubleClick(function(sender, row, column)
    -- getCellItem returns a TableItem, which is where the per-cell colours
    -- live. Empty cells have no item, so check before using it.
    local item = sender:getCellItem(row, column)
    if item then
        item:setBackgroundColour("#ff0076")
        item:setTextColour("white")
        status:setText("Marked " .. row .. ", " .. column)
    end
end)

grid:setOnCellChange(function(sender, row, column)
    status:setText("Edited " .. row .. ", " .. column)
end)

-- A widget can live inside a cell. It behaves normally; the table just gives
-- it the space.
local pick = ui.ComboBox({ "A", "B", "C", "D" })
grid:setCellChild(1, 4, pick)

local meter = ui.ProgressBar()
meter:setRange(0, 100)
meter:setValue(72)
grid:setCellChild(2, 4, meter)

-- Buttons ------------------------------------------------------------------
local buttons = ui.HLayout()

local addRow = ui.Button("Add a row")
addRow:setOnClick(function()
    grid:addRow()
    local row = grid:getRowCount()
    grid:setCellText(row, 1, "New subject")
    status:setText("Row " .. row .. " added.")
end)

local insert = ui.Button("Insert at the top")
insert:setOnClick(function()
    grid:insertRowAt(1)
    grid:setCellText(1, 1, "Inserted")
end)

local removeRow = ui.Button("Remove the current row")
removeRow:setOnClick(function()
    local row = grid:getCurrentRow()
    if row == 0 then
        status:setText("Nothing is selected -- getCurrentRow() returns 0, not Qt's -1.")
        return
    end
    grid:removeRowAt(row)
    status:setText("Removed row " .. row .. ".")
end)

local lock = ui.Button("Lock the cells")
lock:setOnClick(function(sender)
    grid:setCellsEditable(false)
    sender:setEnabled(false)
    status:setText("Cells are read-only.")
end)

-- Sorting goes on *after* the data is in, never before. With it on, Qt
-- re-sorts on every single setCellText, so rows move out from under the
-- filling loop and the values land in the wrong places -- or nowhere.
local sort = ui.Button("Enable sorting")
sort:setOnClick(function(sender)
    grid:setSortingEnabled(true)
    sender:setEnabled(false)
    status:setText("Click a column header to sort by it.")
end)

local total = ui.Button("Total Term 1")
total:setOnClick(function()
    local sum = 0
    for row = 1, grid:getRowCount() do
        local item = grid:getCellItem(row, 2)
        sum = sum + (item and tonumber(item:getText()) or 0)
    end
    status:setText("Term 1 total: " .. sum)
end)

buttons:addChild(addRow)
buttons:addChild(insert)
buttons:addChild(removeRow)
buttons:addChild(lock)
buttons:addChild(sort)
buttons:addChild(total)
buttons:addStretch(1)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(10)
layout:addChild(grid, 1)
layout:addLayout(buttons)
layout:addChild(status)

window:setLayout(layout)
window:show()
