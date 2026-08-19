-- TreeView -- nested rows.
--
-- 1.x shipped two incompatible tree widgets under different names. The one
-- that worked survived as ui.TreeView; `TreeWidget` is still registered as an
-- alias for it, so old code keeps running.

local ui = require("limekit.ui")

local window = ui.Window { title = "TreeView - Limekit 2.0", size = { 620, 480 } }

local tree = ui.TreeView()
tree:setHeaderLabels({ "Name", "Kind", "Size" })
tree:setColumnWidth(1, 220)

-- A TreeViewItem takes one string per column.
local function node(name, kind, size)
    return ui.TreeViewItem({ name, kind, size or "" })
end

local DATA = {
    { "Documents", {
        { "report.pdf", "PDF", "2.1 MB" },
        { "notes.txt", "Text", "4 KB" },
        { "Invoices", {
            { "january.pdf", "PDF", "180 KB" },
            { "february.pdf", "PDF", "174 KB" },
        } },
    } },
    { "Pictures", {
        { "holiday.jpg", "Image", "3.4 MB" },
        { "avatar.png", "Image", "88 KB" },
    } },
    { "Music", {
        { "song.mp3", "Audio", "5.2 MB" },
    } },
}

-- Build recursively. `attach` is the only thing that differs between a top
-- level row and a nested one, so it is a parameter rather than two functions.
local function build(entries, attach)
    for _, entry in ipairs(entries) do
        local name = entry[1]
        local rest = entry[2]

        if type(rest) == "table" then
            local folder = node(name, "Folder")
            folder:setExpanded(true)
            attach(folder)
            build(rest, function(child) folder:addChild(child) end)
        else
            attach(node(name, rest, entry[3]))
        end
    end
end

build(DATA, function(item) tree:addTopItem(item) end)

local detail = ui.Label("Click a row.")
detail:setWordWrap(true)

tree:setOnItemClick(function(sender, item, column)
    -- Columns are 1-based, so the column you were handed goes straight back
    -- into getText.
    detail:setText(
        "Clicked column " .. column .. " of '" .. item:getText(1) ..
        "'  (" .. item:getText(2) .. ", " .. item:getText(3) .. ")"
    )
end)

tree:setOnItemDoubleClick(function(sender, item, column)
    -- An item is only editable if you say so, which is why double-clicking
    -- does nothing until this runs.
    item:setEditable(true)
    detail:setText("'" .. item:getText(1) .. "' is now editable -- type over it.")
end)

local buttons = ui.HLayout()

local expand = ui.Button("Expand all")
expand:setOnClick(function() tree:expandAll() end)

local collapse = ui.Button("Collapse all")
collapse:setOnClick(function() tree:collapseAll() end)

local add = ui.Button("Add a top-level row")
add:setOnClick(function()
    local count = tree:getTopItemCount()
    tree:addTopItem(node("New folder " .. (count + 1), "Folder"))
end)

local inspect = ui.Button("Count the first folder")
inspect:setOnClick(function()
    -- getTopItemAt is 1-based like everything else.
    local first = tree:getTopItemAt(1)
    detail:setText("'" .. first:getText(1) .. "' has " .. first:getChildCount() .. " children.")
end)

local selected = ui.Button("Read the selection")
selected:setOnClick(function()
    local item = tree:getCurrentItem()
    if item then
        detail:setText("Selected: " .. item:getText(1))
    else
        detail:setText("Nothing is selected.")
    end
end)

buttons:addChild(expand)
buttons:addChild(collapse)
buttons:addChild(add)
buttons:addChild(inspect)
buttons:addChild(selected)
buttons:addStretch(1)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(10)
layout:addChild(tree, 1)
layout:addLayout(buttons)
layout:addChild(detail)

window:setLayout(layout)
window:show()
