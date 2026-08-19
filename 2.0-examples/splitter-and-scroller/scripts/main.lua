-- Splitter and Scroller -- two ways to deal with not enough room.
--
-- A Splitter hands the decision to the user: drag the divider and the panes
-- resize. A Scroller keeps the widget at its natural size and moves a
-- viewport over it.

local ui = require("limekit.ui")

local window = ui.Window { title = "Splitter & Scroller - Limekit 2.0", size = { 720, 460 } }

-- LEFT PANE: a list.
local files = ui.ListBox()
files:addItems({ "notes.txt", "report.md", "budget.csv", "todo.txt", "readme.md" })

-- MIDDLE PANE: a scroller holding more rows than can possibly fit.
local tall = ui.VLayout()
tall:setSpacing(6)
for row = 1, 40 do
    local line = ui.Label("Row " .. row .. " -- scroll to see the rest")
    line:setMargins(8, 4, 8, 4)
    tall:addChild(line)
end

local scroller = ui.Scroller()
-- Without this the inner widget keeps its size hint and never fills the
-- viewport's width, which looks like a bug but is Qt's default.
scroller:setResizable(true)
scroller:setLayout(tall)
scroller:setHorizontalScrollBarBehavior("hidden")

-- RIGHT PANE: a detail view.
local detail = ui.TextField()
detail:setHint("Pick a file on the left.")
detail:setReadOnly(true)

files:setOnItemSelect(function(sender, text, row)
    -- Rows are 1-based, so this reads the way it looks.
    detail:setText("Selected: " .. text .. "\nRow: " .. row)
end)

-- A Splitter takes widgets, not layouts, and gives each divider a drag
-- handle. setSizes seeds the starting proportions.
local splitter = ui.Splitter("horizontal")
splitter:addChild(files)
splitter:addChild(scroller)
splitter:addChild(detail)
splitter:setSizes({ 160, 300, 260 })
splitter:setHandleWidth(6)

-- setMainChild rather than setLayout: the whole window *is* this one widget.
window:setMainChild(splitter)
window:show()
