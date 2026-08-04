-- List Manager -- collections, 1-indexing, and uniform argument handling.
--
-- Two things 1.x got wrong that this demo depends on:
--
-- 1. setItems took a Lua table on ComboBox but crashed on a plain list in
--    ListBox, because each widget converted its own arguments. Both now go
--    through one shared conversion, so either form works on either widget.
--
-- 2. Indexing was inconsistent *within the framework*: layouts subtracted one
--    from the index, item widgets did not. Everything Lua-facing is 1-indexed
--    now, including getCurrentRow(), which returns 0 for "nothing selected"
--    rather than leaking Qt's -1.

local ui = require("limekit.ui")

local window = ui.Window { title = "List Manager - Limekit 2.0", size = { 520, 300 } }

local groceries = ui.ListBox()
groceries:setItems({ "cheese", "bacon", "eggs", "rice", "soda" })

local category = ui.ComboBox()
category:setItems({ "Dairy", "Meat", "Pantry", "Drinks" })

local newItem = ui.TextField("")
newItem:setHint("Type an item, then Add")
newItem:setFixedSize(180, 60)

local status = ui.Label("5 items")

local function refresh()
    local count = groceries:getItemsCount()
    local row = groceries:getCurrentRow()
    if row == 0 then
        status:setText(count .. " items - nothing selected")
    else
        status:setText(count .. " items - row " .. row .. " selected: "
            .. groceries:getItemAt(row))
    end
end

groceries:setOnItemSelect(function() refresh() end)

local add = ui.Button("Add")
add:setOnClick(function()
    local text = newItem:getText()
    if text == "" then return end
    groceries:addItem(category:getText() .. ": " .. text)
    newItem:setText("")
    refresh()
end)

local insert = ui.Button("Insert above")
insert:setOnClick(function()
    local row = groceries:getCurrentRow()
    if row == 0 then return end
    groceries:insertItemAt(row, "-- inserted --")
    refresh()
end)

local remove = ui.Button("Remove")
remove:setOnClick(function()
    local row = groceries:getCurrentRow()
    if row == 0 then return end
    groceries:removeItemAt(row)
    refresh()
end)

local clear = ui.Button("Clear")
clear:setOnClick(function()
    groceries:clear()
    refresh()
end)

local showSelection = ui.CheckBox("Announce selection")
showSelection:setChecked(true)

local controls = ui.VLayout()
controls:setSpacing(6)
controls:addChild(category)
controls:addChild(newItem)
controls:addChild(add)
controls:addChild(insert)
controls:addChild(remove)
controls:addChild(clear)
controls:addChild(showSelection)
controls:addStretch(1)

local columns = ui.HLayout()
columns:setSpacing(12)
columns:addChild(groceries, 2)
columns:addLayout(controls, 1)

local layout = ui.VLayout()
layout:setSpacing(8)
layout:setMargins(12, 12, 12, 12)
layout:addLayout(columns, 1)
layout:addChild(status)

window:setLayout(layout)
window:show()

refresh()
