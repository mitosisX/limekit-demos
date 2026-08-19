-- SQLite.
--
-- db.Sqlite3 is a thin wrapper over Python's sqlite3. The rules that matter:
--
--   * pass parameters, never build SQL by string concatenation
--   * execute() runs the statement; fetchAll()/fetchOne() read the results
--   * save() commits -- nothing is written to disk until you call it
--
-- This example builds its own database in the temp folder, so it runs
-- anywhere without setup.

local ui = require("limekit.ui")
local db = require("limekit.db")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local window = ui.Window { title = "SQLite - Limekit 2.0", size = { 680, 500 } }

local PATH = fs.FileSystem.joinPaths(sys.System.getStandardPath("temp"), "limekit-example.db")

local connection = db.Sqlite3(PATH)

-- Column names mapped to SQL type definitions.
connection:createTable("fruits", {
    id = "INTEGER PRIMARY KEY AUTOINCREMENT",
    name = "TEXT NOT NULL UNIQUE",
    colour = "TEXT",
    stock = "INTEGER DEFAULT 0",
}, true)
connection:save()

local table_ = ui.Table(0, 3)
table_:setColumnHeaders({ "Name", "Colour", "Stock" })
table_:setColumnWidth(1, 180)
table_:setSelectionBehavior("rows")

local status = ui.Label("")
status:setWordWrap(true)

local function refresh()
    connection:execute("SELECT name, colour, stock FROM fruits ORDER BY name;")
    local rows = connection:fetchAll()

    table_:clear()
    table_:setColumnHeaders({ "Name", "Colour", "Stock" })
    table_:setRowCount(#rows)

    for index, row in ipairs(rows) do
        -- Rows come back as a list per row, 1-indexed like everything else.
        for column = 1, 3 do
            table_:setCellText(index, column, tostring(row[column]))
        end
    end

    status:setText(#rows .. " rows in " .. PATH)
end

-- Seed some data the first time this runs.
connection:execute("SELECT COUNT(*) FROM fruits;")

-- fetchOne returns the bare value when the row has a single column, and a
-- table of values otherwise -- so a COUNT(*) comes back as a number, not as
-- a one-item list.
if connection:fetchOne() == 0 then
    -- executeMany runs the same statement once per row -- far faster than a
    -- loop of execute calls, and it is one transaction.
    connection:executeMany("INSERT INTO fruits (name, colour, stock) VALUES (?, ?, ?);", {
        { "Apple", "red", 12 },
        { "Banana", "yellow", 40 },
        { "Cherry", "red", 8 },
        { "Mango", "orange", 15 },
    })
    connection:save()
end

-- Adding ------------------------------------------------------------------

local nameField = ui.LineEdit()
nameField:setHint("name")

local colourField = ui.LineEdit()
colourField:setHint("colour")

local stockField = ui.Spinner()
stockField:setRange(0, 9999)

local add = ui.Button("Add")
add:setOnClick(function()
    local name = nameField:getText()
    if name == "" then
        status:setText("A name is required.")
        return
    end

    -- insert() takes a table of column names to values and builds the
    -- parameterised statement for you.
    local ok, err = pcall(function()
        connection:insert("fruits", {
            name = name,
            colour = colourField:getText(),
            stock = stockField:getValue(),
        })
        connection:save()
    end)

    if not ok then
        -- name is UNIQUE, so a duplicate raises rather than silently doing
        -- nothing. 1.x swallowed failed queries.
        status:setText("Could not add it: " .. tostring(err))
        return
    end

    nameField:clear()
    colourField:clear()
    refresh()
end)

local remove = ui.Button("Remove selected")
remove:setOnClick(function()
    local row = table_:getCurrentRow()
    if row == 0 then
        status:setText("Nothing is selected.")
        return
    end

    local name = table_:getCellItem(row, 1):getText()
    -- The ? is the parameter. Never splice the name into the SQL.
    connection:execute("DELETE FROM fruits WHERE name = ?;", { name })
    connection:save()
    refresh()
end)

local search = ui.LineEdit()
search:setHint("filter by colour, then press Enter")
search:setOnReturnPress(function(sender)
    local colour = sender:getText()
    if colour == "" then
        refresh()
        return
    end

    connection:execute("SELECT name, colour, stock FROM fruits WHERE colour = ? ORDER BY name;", { colour })
    local rows = connection:fetchAll()

    table_:clear()
    table_:setColumnHeaders({ "Name", "Colour", "Stock" })
    table_:setRowCount(#rows)
    for index, row in ipairs(rows) do
        for column = 1, 3 do
            table_:setCellText(index, column, tostring(row[column]))
        end
    end
    status:setText(#rows .. " rows match '" .. colour .. "'")
end)

local schema = ui.Button("Show the schema")
schema:setOnClick(function()
    local lines = {}
    for _, name in ipairs(connection:fetchTables()) do
        table.insert(lines, name)
        -- getTableInfo returns each column as a table keyed by name --
        -- SQLite's own PRAGMA fields -- rather than a positional list.
        for _, column in ipairs(connection:getTableInfo(name)) do
            table.insert(lines, "   " .. tostring(column.name) .. "  " .. tostring(column.type))
        end
    end
    status:setText(table.concat(lines, "\n"))
end)

-- Layout -------------------------------------------------------------------

local entry = ui.HLayout()
entry:addChild(nameField)
entry:addChild(colourField)
entry:addChild(stockField)
entry:addChild(add)

local tools = ui.HLayout()
tools:addChild(search, 1)
tools:addChild(remove)
tools:addChild(schema)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(10)
layout:addLayout(entry)
layout:addLayout(tools)
layout:addChild(table_, 1)
layout:addChild(ui.HLine())
layout:addChild(status)

refresh()

window:setOnClose(function()
    connection:close()
end)

window:setLayout(layout)
window:show()
