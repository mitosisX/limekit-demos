-- CSV explorer -- a file becomes a table becomes a chart.
--
-- This is the example that crosses every module: fs reads the file, sys
-- splits the lines, ui shows the grid, and chart draws whichever column you
-- pick. Nothing here knows about the others; they meet in Lua.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")
local chart = require("limekit.chart")

local FS = fs.FileSystem
local System = sys.System

local window = ui.Window { title = "CSV Explorer - Limekit 2.0", size = { 1000, 660 } }

local SAMPLE = FS.joinPaths(System.getStandardPath("temp"), "limekit-sales.csv")

-- A file to open, so the example works with nothing set up.
if not FS.exists(SAMPLE) then
    FS.writeFile(SAMPLE, table.concat({
        "Region,Quarter,Units,Revenue,Returns",
        "North,Q1,120,14400,4",
        "North,Q2,150,18000,6",
        "South,Q1,90,10800,3",
        "South,Q2,140,16800,9",
        "East,Q1,200,24000,11",
        "East,Q2,180,21600,7",
        "West,Q1,60,7200,1",
        "West,Q2,110,13200,5",
        "Central,Q1,95,11400,2",
        "Central,Q2,130,15600,8",
    }, "\n") .. "\n")
end

-- PARSING ------------------------------------------------------------------
-- A real CSV parser handles quoted fields with commas in them. This one does
-- not, and says so, because a half-honest parser is worse than an obvious
-- one: it fails on the row you did not test.

local function parse(path)
    local lines = FS.readFileLines(path)
    local rows = {}

    for _, line in ipairs(lines) do
        local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
        if trimmed ~= "" then
            table.insert(rows, System.splitString(trimmed, ","))
        end
    end

    if #rows == 0 then return nil, "the file has no rows" end

    local headers = table.remove(rows, 1)
    return { headers = headers, rows = rows }
end

-- STATE --------------------------------------------------------------------

local data = nil                -- { headers = {...}, rows = {{...}, ...} }
local numericColumns = {}       -- column index -> true

local grid = ui.Table(0, 1)
grid:setSelectionBehavior("rows")
grid:setCellsEditable(false)
grid:setAlternatingRowColors(true)

local summary = ui.TextField()
summary:setReadOnly(true)

local status = ui.StatusBar()
window:setStatusbar(status)

local columnPicker = ui.ComboBox()
local chartKind = ui.ComboBox({ "Bars", "Stacked bars", "Line" })

local plot = chart.Chart { title = "Pick a column" }
local view = chart.ChartView(plot)

-- A column counts as numeric only if every value in it is a number. One
-- stray "n/a" and it is text, which is the honest answer.
local function findNumericColumns()
    numericColumns = {}

    for column = 1, #data.headers do
        local numeric = #data.rows > 0

        for _, row in ipairs(data.rows) do
            if tonumber(row[column]) == nil then
                numeric = false
                break
            end
        end

        numericColumns[column] = numeric
    end
end

local function columnValues(column)
    local values = {}
    for index, row in ipairs(data.rows) do
        values[index] = tonumber(row[column]) or 0
    end
    return values
end

local function labels()
    -- The first non-numeric column makes the best category labels; failing
    -- that, number the rows.
    for column = 1, #data.headers do
        if not numericColumns[column] then
            local names = {}
            for index, row in ipairs(data.rows) do
                names[index] = tostring(row[column]) .. " " .. tostring(row[column + 1] or "")
            end
            return names
        end
    end

    local names = {}
    for index = 1, #data.rows do names[index] = tostring(index) end
    return names
end

-- THE CHART ----------------------------------------------------------------

local function redraw()
    if not data then return end

    -- The picker only ever holds numeric columns, so map the name it is
    -- showing back to the real column number.
    local index = nil
    local numeric = {}
    for c = 1, #data.headers do
        if numericColumns[c] then table.insert(numeric, c) end
    end

    local pick = columnPicker:getText()
    for _, c in ipairs(numeric) do
        if data.headers[c] == pick then index = c end
    end

    if not index then
        status:setText("No numeric column to chart.", 4000)
        return
    end

    local values = columnValues(index)
    local kind = chartKind:getText()

    local fresh = chart.Chart { title = data.headers[index], animation = "series" }
    fresh:setLegendVisibility(true)
    fresh:setLegendAlignment("bottom")

    if kind == "Line" then
        local line = chart.LineChart()
        line:setName(data.headers[index])
        for x, y in ipairs(values) do line:append(x, y) end
        fresh:addSeries(line)

        local xAxis = chart.ValueAxis()
        xAxis:setRange(1, math.max(2, #values))
        xAxis:setTitleText("Row")
        fresh:addAxis(xAxis, "bottom")

        local yAxis = chart.ValueAxis()
        yAxis:setRange(0, math.max(table.unpack(values)) * 1.1)
        yAxis:setTitleText(data.headers[index])
        fresh:addAxis(yAxis, "left")

        line:attachAxis(xAxis)
        line:attachAxis(yAxis)
    else
        local series = kind == "Stacked bars" and chart.StackedBarChart() or chart.BarChart()

        local set = chart.BarSet(data.headers[index])
        set:append(values)
        series:append(set)
        fresh:addSeries(series)

        local categories = chart.CategoryAxis(labels())
        fresh:addAxis(categories, "bottom")

        local yAxis = chart.ValueAxis()
        yAxis:setRange(0, math.max(table.unpack(values)) * 1.1)
        yAxis:setTitleText(data.headers[index])
        fresh:addAxis(yAxis, "left")

        series:attachAxis(categories)
        series:attachAxis(yAxis)
    end

    -- setChart swaps the whole graph, which is simpler and safer than trying
    -- to mutate the old one's series and axes in place.
    view:setChart(fresh)
    plot = fresh
end

-- SUMMARY ------------------------------------------------------------------

local function summarise()
    local lines = { "" .. #data.rows .. " rows, " .. #data.headers .. " columns", "" }

    for column, header in ipairs(data.headers) do
        if numericColumns[column] then
            local values = columnValues(column)
            local total, low, high = 0, values[1], values[1]

            for _, value in ipairs(values) do
                total = total + value
                if value < low then low = value end
                if value > high then high = value end
            end

            table.insert(lines, string.format(
                "%-10s  total %-10s  mean %-10s  min %-8s  max %s",
                header, total, string.format("%.1f", total / #values), low, high))
        else
            -- Count the distinct values -- the useful summary for a text
            -- column, and it needs no type guessing.
            local seen, distinct = {}, 0
            for _, row in ipairs(data.rows) do
                local value = tostring(row[column])
                if not seen[value] then
                    seen[value] = true
                    distinct = distinct + 1
                end
            end
            table.insert(lines, string.format("%-10s  text, %d distinct values", header, distinct))
        end
    end

    summary:setText(table.concat(lines, "\n"))
end

-- LOADING ------------------------------------------------------------------

local function load(path)
    local parsed, problem = parse(path)
    if not parsed then
        ui.Dialogs.critical(window, "Could not read it", tostring(problem))
        return
    end

    data = parsed
    findNumericColumns()

    grid:clear()
    grid:setColumnCount(#data.headers)
    grid:setColumnHeaders(data.headers)
    grid:setRowCount(#data.rows)

    for row, values in ipairs(data.rows) do
        for column = 1, #data.headers do
            grid:setCellText(row, column, tostring(values[column] or ""))
        end
    end

    -- Sorting goes on after the data, never before: with it on, Qt re-sorts
    -- on every setCellText and the rows move out from under the loop. Note
    -- that switching it on sorts immediately, so the first view is ordered
    -- rather than in file order -- click a header to choose the column.
    grid:setSortingEnabled(true)

    columnPicker:clear()
    for column, header in ipairs(data.headers) do
        if numericColumns[column] then columnPicker:addItem(header) end
    end

    summarise()
    redraw()

    status:setText(FS.getFileName(path) .. " -- " .. #data.rows .. " rows")
end

-- CONTROLS -----------------------------------------------------------------

columnPicker:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    redraw()
end)

chartKind:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    redraw()
end)

local open = ui.Button("Open a CSV...")
open:setOnClick(function()
    local path = ui.Dialogs.openFile(window, "Open a CSV", nil, {
        ["CSV files"] = { "csv" },
        ["Text files"] = { "txt" },
        ["All files"] = { "*" },
    })
    if path then load(path) end
end)

local reload = ui.Button("Reload the sample")
reload:setOnClick(function() load(SAMPLE) end)

local export = ui.Button("Save the summary...")
export:setOnClick(function()
    local path = ui.Dialogs.saveFile(window, "Save summary", nil, { ["Text"] = { "txt" } })
    if not path then return end
    FS.writeFile(path, summary:getText())
    status:setText("Wrote " .. path, 5000)
end)

-- LAYOUT -------------------------------------------------------------------

local controls = ui.HLayout()
controls:addChild(open)
controls:addChild(reload)
controls:addChild(export)
controls:addChild(ui.VLine())
controls:addChild(ui.Label("Chart column:"))
controls:addChild(columnPicker)
controls:addChild(ui.Label("as"))
controls:addChild(chartKind)
controls:addStretch(1)

local rightPane = ui.Splitter("vertical")
rightPane:addChild(view)
rightPane:addChild(summary)
rightPane:setSizes({ 340, 200 })

local panes = ui.Splitter("horizontal")
panes:addChild(grid)
panes:addChild(rightPane)
panes:setSizes({ 460, 520 })
panes:setHandleWidth(6)

local root = ui.VLayout()
root:setMargins(10, 10, 10, 10)
root:setSpacing(8)
root:addLayout(controls)
root:addChild(panes, 1)

local body = ui.Container()
body:setLayout(root)

load(SAMPLE)

window:setMainChild(body)
window:show()
