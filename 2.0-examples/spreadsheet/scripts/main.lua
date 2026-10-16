-- A spreadsheet, small but real: formulas, references, ranges and
-- recalculation.
--
-- Two layers that must not be confused:
--
--   sheet[addr]   what the user typed: "12", "Rent", "=B2*12", "=SUM(B2:B7)"
--   the Table     what it is worth right now
--
-- Typing into a cell changes `sheet`; then every formula is evaluated
-- again and the Table is repainted. With a few hundred cells that takes
-- no time, and it is far simpler than tracking which cell depends on
-- which. Evaluation memoises within one recalculation and carries a
-- "visiting" set, so =A1 in A1 (or any longer loop) shows #CYCLE instead
-- of hanging.
--
-- Arithmetic is handed to sys.Expr.evalExpression after references have
-- been replaced by their values and functions expanded -- the same
-- sandboxed evaluator the calculator uses, which permits numbers and
-- operators and nothing else. Formula cells are tinted; errors are red.
--
-- Table:setCellText fires onCellChange like a user's edit does, so a
-- `painting` flag tells the two apart -- the same guard any editable grid
-- that also repaints itself needs.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local window = ui.Window { title = "Spreadsheet - Limekit 2.0", size = { 1000, 640 } }

local COLUMNS, ROWS = 10, 24

local function columnName(index)
    return string.char(64 + index)       -- 1 -> A
end

local function columnIndex(letter)
    return letter:byte() - 64
end

local function addr(row, column)
    return columnName(column) .. row
end

-- STATE ----------------------------------------------------------------------

local sheet = {}            -- addr -> raw text
local painting = false      -- true while the Table is being refilled
local values = {}           -- addr -> computed value for this recalculation
local visiting = {}         -- addr -> true while being evaluated (cycle check)
local path = nil            -- the open CSV, if any

-- EVALUATION -------------------------------------------------------------------

local evaluate -- forward

local function parseAddr(text)
    local letter, row = text:upper():match("^([A-Z])(%d+)$")
    if not letter then return nil end
    local column, r = columnIndex(letter), tonumber(row)
    if column < 1 or column > COLUMNS or r < 1 or r > ROWS then return nil end
    return r, column
end

-- Every address in A1:C3, row by row.
local function expandRange(from, to)
    local r1, c1 = parseAddr(from)
    local r2, c2 = parseAddr(to)
    if not r1 or not r2 then return nil end
    local out = {}
    for r = math.min(r1, r2), math.max(r1, r2) do
        for c = math.min(c1, c2), math.max(c1, c2) do out[#out + 1] = addr(r, c) end
    end
    return out
end

local FUNCTIONS = {
    SUM = function(list) local s = 0; for _, v in ipairs(list) do s = s + v end; return s end,
    AVG = function(list) if #list == 0 then return 0 end; local s = 0; for _, v in ipairs(list) do s = s + v end; return s / #list end,
    MIN = function(list) local m = list[1] or 0; for _, v in ipairs(list) do if v < m then m = v end end; return m end,
    MAX = function(list) local m = list[1] or 0; for _, v in ipairs(list) do if v > m then m = v end end; return m end,
    COUNT = function(list) return #list end,
}

-- Errors travel as strings starting with "#", so a formula that refers to
-- a broken cell shows the same error rather than a misleading number.
local function isError(value)
    return type(value) == "string" and value:sub(1, 1) == "#"
end

-- The numeric value of one address, for use inside another formula.
local function valueOf(address)
    local value = evaluate(address)
    if isError(value) then return nil, value end
    if type(value) == "number" then return value end
    if value == "" or value == nil then return 0 end
    return nil, "#VALUE"                 -- text in arithmetic
end

local function evaluateFormula(formula)
    local expression = formula:sub(2):upper():gsub("%s+", "")
    if expression == "" then return "#ERR" end
    local failure = nil

    -- 1. Functions over ranges: SUM(A1:B3) -> a number.
    expression = expression:gsub("([A-Z]+)%(([A-Z]%d+):([A-Z]%d+)%)", function(name, from, to)
        local fn = FUNCTIONS[name]
        local cellsIn = expandRange(from, to)
        if not fn or not cellsIn then failure = failure or "#NAME"; return "0" end
        local list = {}
        for _, a in ipairs(cellsIn) do
            local v, err = valueOf(a)
            if err then failure = failure or err; return "0" end
            local raw = sheet[a]
            if raw and raw ~= "" then list[#list + 1] = v end     -- blanks do not count
        end
        return string.format("(%.10g)", fn(list))
    end)

    -- 2. Plain references: B2 -> its value.
    expression = expression:gsub("([A-Z]%d+)", function(a)
        if not parseAddr(a) then failure = failure or "#REF"; return "0" end
        local v, err = valueOf(a)
        if err then failure = failure or err; return "0" end
        return string.format("(%.10g)", v)
    end)
    if failure then return failure end

    -- 3. Arithmetic, in the sandbox. ^ is Lua's power; the evaluator's is **.
    expression = expression:gsub("%^", "**")
    local ok, result = pcall(sys.Expr.evalExpression, expression)
    if not ok then
        local why = tostring(result):lower()
        return (why:find("division") or why:find("zero")) and "#DIV/0" or "#ERR"
    end
    local number = tonumber(tostring(result))
    if not number then return "#ERR" end
    if number ~= number or number == math.huge or number == -math.huge then return "#DIV/0" end
    return number
end

function evaluate(address)
    if values[address] ~= nil then return values[address] end
    if visiting[address] then return "#CYCLE" end
    local raw = sheet[address] or ""
    local value
    if raw:sub(1, 1) == "=" then
        visiting[address] = true
        value = evaluateFormula(raw)
        visiting[address] = nil
    else
        value = tonumber(raw) or raw
    end
    values[address] = value
    return value
end

-- THE TABLE ----------------------------------------------------------------------

local table_ = ui.Table(ROWS, COLUMNS)
local headers = {}
for c = 1, COLUMNS do headers[c] = columnName(c) end
table_:setColumnHeaders(headers)
local rowHeaders = {}
for r = 1, ROWS do rowHeaders[r] = tostring(r) end
table_:setRowHeaders(rowHeaders)
table_:setCellsEditable(true)
table_:setAlternatingRowColors(false)
for c = 1, COLUMNS do table_:setColumnWidth(c, 90) end

local formulaBar = ui.LineEdit()
formulaBar:setHint("Select a cell, type a value or a formula such as =SUM(B2:B6), press Enter")
formulaBar:setStyleSheet("font-family: Consolas, monospace;")
local cellLabel = ui.Label("A1")
cellLabel:setBold(true)
cellLabel:setMinWidth(36)

local status = ui.StatusBar()
window:setStatusbar(status)

local function shown(value)
    if type(value) == "number" then
        if value == math.floor(value) and math.abs(value) < 1e15 then return string.format("%d", value) end
        return string.format("%.4g", value)
    end
    return tostring(value or "")
end

local function recalculate()
    values, visiting = {}, {}
    painting = true
    local errors = 0
    for r = 1, ROWS do
        for c = 1, COLUMNS do
            local a = addr(r, c)
            local value = evaluate(a)
            table_:setCellText(r, c, shown(value))
            local item = table_:getCellItem(r, c)
            if isError(value) then
                errors = errors + 1
                item:setTextColour("#DC2626")
                item:setBackgroundColour("#FEE2E2")
            elseif (sheet[a] or ""):sub(1, 1) == "=" then
                -- Both colours set: a tinted cell with the theme's text
                -- colour is unreadable in a dark theme.
                item:setBackgroundColour("#DBEAFE")
                item:setTextColour("#1E3A8A")
            end
        end
    end
    painting = false
    status:setText(errors == 0 and "" or (errors .. " cell" .. (errors > 1 and "s" or "") .. " with errors"), 0)
end

local function setCell(row, column, raw)
    raw = raw:match("^%s*(.-)%s*$")
    if raw == "" then sheet[addr(row, column)] = nil else sheet[addr(row, column)] = raw end
    recalculate()
end

-- Typing into the grid.
table_:setOnCellChange(function(_, row, column)
    if painting then return end
    local item = table_:getCellItem(row, column)
    setCell(row, column, item and item:getText() or "")
end)

-- Clicking shows the cell's *raw* text in the formula bar -- the formula,
-- not the number it made.
local selected = { 1, 1 }
table_:setOnCellClick(function(_, row, column)
    selected = { row, column }
    cellLabel:setText(addr(row, column))
    formulaBar:setText(sheet[addr(row, column)] or "")
end)

formulaBar:setOnReturnPress(function()
    setCell(selected[1], selected[2], formulaBar:getText())
    table_:setCurrentCell(selected[1], selected[2])
end)

-- FILES ------------------------------------------------------------------------
-- Raw text is saved, so formulas survive the round trip.

local function csvField(text)
    if text:find('[,"\n]') then return '"' .. text:gsub('"', '""') .. '"' end
    return text
end

local function csvSplit(line)
    local fields, field, quoted, i = {}, "", false, 1
    while i <= #line do
        local ch = line:sub(i, i)
        if quoted then
            if ch == '"' and line:sub(i + 1, i + 1) == '"' then field = field .. '"'; i = i + 1
            elseif ch == '"' then quoted = false
            else field = field .. ch end
        elseif ch == '"' then quoted = true
        elseif ch == "," then fields[#fields + 1] = field; field = ""
        else field = field .. ch end
        i = i + 1
    end
    fields[#fields + 1] = field
    return fields
end

local function serialise()
    local lines = {}
    local last = 1
    for r = 1, ROWS do
        for c = 1, COLUMNS do if sheet[addr(r, c)] then last = r end end
    end
    for r = 1, last do
        local fields = {}
        for c = 1, COLUMNS do fields[c] = csvField(sheet[addr(r, c)] or "") end
        lines[r] = table.concat(fields, ",")
    end
    return table.concat(lines, "\n") .. "\n"
end

local function saveAs()
    local chosen = ui.Dialogs.saveFile(window, "Save sheet", path or
        fs.FileSystem.joinPaths(sys.System.getStandardPath("documents"), "sheet.csv"), { ["CSV"] = { "csv" } })
    if not chosen then return end
    fs.FileSystem.writeFile(chosen, serialise())
    path = chosen
    window:setTitle(fs.FileSystem.getFileName(path) .. " - Spreadsheet - Limekit 2.0")
    status:setText("Saved " .. path, 4000)
end

local function save()
    if path then
        fs.FileSystem.writeFile(path, serialise())
        status:setText("Saved " .. path, 3000)
    else
        saveAs()
    end
end

local function open()
    local chosen = ui.Dialogs.openFile(window, "Open sheet", nil, { ["CSV"] = { "csv" } })
    if not chosen then return end
    sheet = {}
    for r, line in ipairs(fs.FileSystem.readFileLines(chosen)) do
        if r > ROWS then break end
        for c, field in ipairs(csvSplit(line)) do
            if c <= COLUMNS and field ~= "" then sheet[addr(r, c)] = field end
        end
    end
    path = chosen
    window:setTitle(fs.FileSystem.getFileName(path) .. " - Spreadsheet - Limekit 2.0")
    recalculate()
end

local function clearAll()
    if ui.Dialogs.question(window, "Clear", "Clear every cell?") then
        sheet = {}
        recalculate()
    end
end

-- CHROME -----------------------------------------------------------------------

local function item(text, shortcut, handler)
    local entry = ui.MenuItem(text)
    if shortcut then entry:setShortcut(shortcut) end
    entry:setOnClick(handler)
    return entry
end
local menubar = ui.Menubar()
local fileMenu = ui.Menu("&File")
fileMenu:addMenuItem(item("Open CSV...", "Ctrl+O", open))
fileMenu:addMenuItem(item("Save", "Ctrl+S", save))
fileMenu:addMenuItem(item("Save as...", "Ctrl+Shift+S", saveAs))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Clear all", nil, clearAll))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Quit", "Ctrl+Q", function() window:close() end))
menubar:addMenu(fileMenu)
local helpMenu = ui.Menu("&Help")
helpMenu:addMenuItem(item("Formulas", "F1", function()
    ui.Dialogs.info(window, "Formulas", table.concat({
        "Start a cell with = to make it a formula.",
        "",
        "  =B2*12          arithmetic with + - * / ^ and ( )",
        "  =B2+C2-D2       references to other cells",
        "  =SUM(B2:B7)     SUM, AVG, MIN, MAX, COUNT over a range",
        "",
        "Blue cells hold formulas. Click one to see it in the bar.",
        "A formula that refers to itself, however indirectly, shows #CYCLE.",
    }, "\n"))
end))
menubar:addMenu(helpMenu)
window:setMenubar(menubar)

-- LAYOUT -----------------------------------------------------------------------

local bar = ui.HLayout()
bar:setSpacing(8)
bar:addChild(cellLabel)
bar:addChild(formulaBar, 1)

local main = ui.VLayout()
main:setMargins(8, 8, 8, 8)
main:addLayout(bar)
main:addChild(table_, 1)
window:setLayout(main)

-- A STARTER SHEET ----------------------------------------------------------------
-- A household budget: enough formulas to show references, a range, a
-- percentage, and what happens when a cell is cleared.

local starter = {
    A1 = "Budget", B1 = "Monthly", C1 = "Yearly", D1 = "Share",
    A2 = "Rent", B2 = "1200", C2 = "=B2*12", D2 = "=B2/B9",
    A3 = "Food", B3 = "450", C3 = "=B3*12", D3 = "=B3/B9",
    A4 = "Transport", B4 = "160", C4 = "=B4*12", D4 = "=B4/B9",
    A5 = "Power", B5 = "90", C5 = "=B5*12", D5 = "=B5/B9",
    A6 = "Internet", B6 = "45", C6 = "=B6*12", D6 = "=B6/B9",
    A7 = "Fun", B7 = "120", C7 = "=B7*12", D7 = "=B7/B9",
    A9 = "Total", B9 = "=SUM(B2:B7)", C9 = "=SUM(C2:C7)", D9 = "=SUM(D2:D7)",
    A10 = "Average", B10 = "=AVG(B2:B7)", C10 = "=AVG(C2:C7)",
    A11 = "Biggest", B11 = "=MAX(B2:B7)", C11 = "=MAX(C2:C7)",
    A13 = "Income", B13 = "2600",
    A14 = "Left over", B14 = "=B13-B9", C14 = "=B14*12",
    A16 = "Try it:", B16 = "=B14/0", C16 = "=C16+1",
}
for a, raw in pairs(starter) do sheet[a] = raw end
recalculate()
formulaBar:setText(sheet.A1 or "")
window:show()
