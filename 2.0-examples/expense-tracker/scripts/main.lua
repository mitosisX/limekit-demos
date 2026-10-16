-- An expense tracker: entries in SQLite, a filtered table, two charts that
-- follow the filter, and a CSV export.
--
-- This is the first example split into modules, and that is the lesson:
--
--   store.lua    the data -- SQL lives here and nowhere else
--   report.lua   the charts -- pictures of whatever the store says
--   main.lua     the interface -- widgets, events, and `refresh`
--
-- Everything on screen is drawn by one `refresh()` from the store, through
-- the current filter. Add, edit and delete each change the store and call
-- refresh; nothing edits a table row and hopes the database agrees.
--
-- Editing happens in a Modal that is built once and refilled, rather than
-- rebuilt per use -- the pattern for any dialog that opens more than once.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")
local chart = require("limekit.chart")

local Store = require("store")
local Report = require("report")

local window = ui.Window { title = "Expense tracker - Limekit 2.0", size = { 1100, 680 } }

local DB_PATH = fs.FileSystem.joinPaths(sys.System.getStandardPath("temp"), "limekit-expenses.db")
Store.open(DB_PATH)
local seeded = Store.seedIfEmpty()

local status = ui.StatusBar()
window:setStatusbar(status)
local totalLabel = ui.Label("")
status:addPermanentChild(totalLabel)

-- STATE ----------------------------------------------------------------------

local filter = { month = nil, category = nil, text = "" }
local shown = {}            -- rows in the table, in table order (row index -> record)
local months = {}           -- Store.months(), for the month combo

-- WIDGETS: the filter row --------------------------------------------------

local monthPick = ui.ComboBox()
local categoryPick = ui.ComboBox()
local search = ui.LineEdit()
search:setHint("Search notes")

local filling = false       -- true while combos are being refilled

local function refillMonths()
    filling = true
    months = Store.months()
    monthPick:clear()
    monthPick:addItem("All months")
    for _, month in ipairs(months) do monthPick:addItem(month) end
    local index = 1
    for i, month in ipairs(months) do if month == filter.month then index = i + 1 end end
    monthPick:setCurrentIndex(index)
    filling = false
end

categoryPick:addItem("All categories")
categoryPick:addItems(Store.CATEGORIES)

-- WIDGETS: the table -------------------------------------------------------

local table_ = ui.Table(0, 4)
table_:setColumnHeaders({ "Date", "Category", "Amount", "Note" })
table_:setColumnWidth(1, 100)
table_:setColumnWidth(2, 110)
table_:setColumnWidth(3, 90)
table_:setStretchLastColumn(true)
table_:setSelectionBehavior("rows")
table_:setRowHeadersVisible(false)

-- WIDGETS: the charts ------------------------------------------------------

local categoryView = chart.ChartView(Report.categoryChart(filter, "By category"))
local monthView = chart.ChartView(Report.monthChart())

-- REFRESH --------------------------------------------------------------------

local function money(amount)
    return string.format("%.2f", amount)
end

local function describeFilter()
    local parts = {}
    parts[#parts + 1] = filter.month or "all months"
    if filter.category then parts[#parts + 1] = filter.category end
    if filter.text ~= "" then parts[#parts + 1] = '"' .. filter.text .. '"' end
    return table.concat(parts, ", ")
end

local function refresh()
    shown = Store.list(filter)
    table_:clearContent()
    table_:setRowCount(#shown)
    for row, record in ipairs(shown) do
        table_:setCellText(row, 1, record.day)
        table_:setCellText(row, 2, record.category)
        table_:setCellText(row, 3, money(record.amount))
        table_:setCellText(row, 4, record.note)
        -- Big entries stand out; the threshold is arbitrary but useful.
        if record.amount >= 100 then
            table_:getCellItem(row, 3):setTextColour("#DC2626")
        end
    end

    totalLabel:setText(string.format("%d entries   total %s   (%s)",
        #shown, money(Store.total(filter)), describeFilter()))

    categoryView:setChart(Report.categoryChart(filter, "By category -- " .. describeFilter()))
    monthView:setChart(Report.monthChart())
end

-- THE EDIT DIALOG ------------------------------------------------------------
-- One modal for both "add" and "edit": `editing` is the id being edited, or
-- nil for a new entry. Built once; opened as often as needed.

local modal = ui.Modal("Expense", window)
local editing = nil

local form = ui.FormLayout()
local dayPick = ui.DatePicker()
local catEdit = ui.ComboBox()
catEdit:addItems(Store.CATEGORIES)
local amountEdit = ui.DoubleSpinner()
amountEdit:setRange(0, 1000000)
amountEdit:setPrefix("$ ")
local noteEdit = ui.LineEdit()
noteEdit:setHint("What was it for?")
form:addChild("Date", dayPick)
form:addChild("Category", catEdit)
form:addChild("Amount", amountEdit)
form:addChild("Note", noteEdit)

local buttons = ui.HLayout()
buttons:addStretch()
local cancelButton = ui.Button("Cancel")
local saveButton = ui.Button("Save")
buttons:addChild(cancelButton)
buttons:addChild(saveButton)

local modalLayout = ui.VLayout()
modalLayout:setMargins(16, 16, 16, 12)
modalLayout:addLayout(form)
modalLayout:addLayout(buttons)
modal:setLayout(modalLayout)
cancelButton:setOnClick(function() modal:dismiss() end)

local function today()
    return os.date("%Y-%m-%d")
end

local function setDate(text)
    local y, m, d = text:match("^(%d+)%-(%d+)%-(%d+)$")
    if y then dayPick:setDate(tonumber(y), tonumber(m), tonumber(d)) end
end

-- DatePicker reports yyyy-M-d (no zero padding); the store wants it padded
-- so that dates sort as text.
local function pickedDate()
    local y, m, d = tostring(dayPick:getDate()):match("^(%d+)%-(%d+)%-(%d+)$")
    return string.format("%04d-%02d-%02d", tonumber(y), tonumber(m), tonumber(d))
end

local function openEditor(record)
    editing = record and record.id or nil
    modal:setTitle(record and "Edit expense" or "New expense")
    setDate(record and record.day or today())
    local index = 1
    for i, name in ipairs(Store.CATEGORIES) do
        if record and name == record.category then index = i end
    end
    catEdit:setCurrentIndex(index)
    amountEdit:setValue(record and record.amount or 0)
    noteEdit:setText(record and record.note or "")
    modal:show()
    noteEdit:setFocus()
end

saveButton:setOnClick(function()
    local amount = amountEdit:getValue()
    if amount <= 0 then
        ui.Dialogs.warning(modal, "Amount", "Enter an amount greater than zero.")
        return
    end
    local category = Store.CATEGORIES[catEdit:getCurrentIndex()] or Store.CATEGORIES[1]
    local note = noteEdit:getText()
    if editing then
        Store.update(editing, pickedDate(), category, amount, note)
        status:setText("Updated.", 3000)
    else
        Store.add(pickedDate(), category, amount, note)
        status:setText("Added " .. money(amount) .. " to " .. category .. ".", 3000)
    end
    modal:dismiss()
    refillMonths()
    refresh()
end)

-- COMMANDS -------------------------------------------------------------------

local function selectedRecord()
    local row = table_:getCurrentRow()
    return row and row >= 1 and shown[row] or nil
end

local function editSelected()
    local record = selectedRecord()
    if record then openEditor(record) else status:setText("Select an entry first.", 3000) end
end

local function deleteSelected()
    local record = selectedRecord()
    if not record then status:setText("Select an entry first.", 3000); return end
    if ui.Dialogs.question(window, "Delete", "Delete " .. money(record.amount)
            .. " (" .. record.category .. ", " .. record.day .. ")?") then
        Store.remove(record.id)
        refillMonths()
        refresh()
        status:setText("Deleted.", 3000)
    end
end

local function exportCSV()
    local path = ui.Dialogs.saveFile(window, "Export as CSV",
        fs.FileSystem.joinPaths(sys.System.getStandardPath("documents"), "expenses.csv"),
        { ["CSV"] = { "csv" } })
    if not path then return end
    local count = Store.exportCSV(path, filter)
    status:setText("Wrote " .. count .. " rows to " .. path, 6000)
end

-- EVENTS ---------------------------------------------------------------------

monthPick:setOnItemSelect(function(_, index)
    if filling then return end
    filter.month = index > 1 and months[index - 1] or nil
    refresh()
end)

categoryPick:setOnItemSelect(function(_, index)
    filter.category = index > 1 and Store.CATEGORIES[index - 1] or nil
    refresh()
end)

search:setOnTextChange(function()
    filter.text = search:getText()
    refresh()
end)

table_:setOnCellDoubleClick(function() editSelected() end)

-- CHROME ---------------------------------------------------------------------

local function item(text, shortcut, handler)
    local entry = ui.MenuItem(text)
    if shortcut then entry:setShortcut(shortcut) end
    entry:setOnClick(handler)
    return entry
end

local menubar = ui.Menubar()
local fileMenu = ui.Menu("&File")
fileMenu:addMenuItem(item("New expense", "Ctrl+N", function() openEditor(nil) end))
fileMenu:addMenuItem(item("Export CSV...", "Ctrl+E", exportCSV))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Quit", "Ctrl+Q", function() window:close() end))
local editMenu = ui.Menu("&Edit")
editMenu:addMenuItem(item("Edit selected", "Return", editSelected))
editMenu:addMenuItem(item("Delete selected", "Delete", deleteSelected))
menubar:addMenu(fileMenu)
menubar:addMenu(editMenu)
window:setMenubar(menubar)

local toolbar = ui.Toolbar()
toolbar:setToolButtonStyle("textbesideicon")
local function tool(text, handler)
    local button = ui.ToolbarButton(text)
    button:setOnClick(handler)
    toolbar:addButton(button)
end
tool("Add", function() openEditor(nil) end)
tool("Edit", editSelected)
tool("Delete", deleteSelected)
toolbar:addSeparator()
tool("Export CSV", exportCSV)
window:addToolbar(toolbar)

-- LAYOUT ---------------------------------------------------------------------

local filterRow = ui.HLayout()
filterRow:setSpacing(8)
filterRow:addChild(ui.Label("Show"))
filterRow:addChild(monthPick)
filterRow:addChild(categoryPick)
filterRow:addChild(search, 1)

local left = ui.VLayout()
left:setMargins(8, 8, 4, 8)
left:addLayout(filterRow)
left:addChild(table_, 1)
local leftBox = ui.Container()
leftBox:setLayout(left)

local charts = ui.VLayout()
charts:setMargins(4, 8, 8, 8)
charts:addChild(categoryView, 1)
charts:addChild(monthView, 1)
local chartBox = ui.Container()
chartBox:setLayout(charts)

local split = ui.Splitter("horizontal")
split:addChild(leftBox)
split:addChild(chartBox)
split:setStretchFactors({ 3, 2 })
window:setMainChild(split)

refillMonths()
refresh()
if seeded then
    status:setText("Seeded six months of sample spending into " .. DB_PATH, 8000)
end
window:show()
