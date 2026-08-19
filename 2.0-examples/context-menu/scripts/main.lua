-- Context menus -- the menu that appears where you right-click.
--
-- Two pieces: setOnContextMenu tells you *where* the click landed, and
-- popupAt puts a menu there. The coordinates are relative to the widget you
-- pass in, so handing back the sender is almost always right.

local ui = require("limekit.ui")

local window = ui.Window { title = "Context Menu - Limekit 2.0", size = { 520, 380 } }

local log = ui.TextField()
log:setReadOnly(true)
log:setText("Right-click anywhere in this window.")

local function say(message)
    log:appendText(message)
end

-- Menus are built with addMenuItem and addMenu. Nothing stops you writing a
-- table-driven builder on top -- here is one in nine lines, which is what
-- 1.x's three competing buildFromTemplate implementations amounted to.
local function build(entries)
    local menu = ui.Menu()
    for _, entry in ipairs(entries) do
        if entry.separator then
            menu:addSeparator()
        elseif entry.submenu then
            local child = build(entry.submenu)
            child:setTitle(entry.label)
            menu:addMenu(child)
        else
            local item = ui.MenuItem(entry.label)
            if entry.shortcut then item:setShortcut(entry.shortcut) end
            if entry.checkable then item:setCheckable(true) end
            item:setOnClick(entry.click or function() say(entry.label) end)
            menu:addMenuItem(item)
        end
    end
    return menu
end

local TEMPLATE = {
    { label = "Cut",   shortcut = "Ctrl+X" },
    { label = "Copy",  shortcut = "Ctrl+C" },
    { separator = true },
    { label = "Paste as", submenu = {
        { label = "Plain text" },
        { label = "Formatted" },
        { label = "More", submenu = {
            { label = "Even deeper" },
        } },
    } },
    { separator = true },
    { label = "Word wrap", checkable = true },
    { label = "Clear", click = function() log:setText("") end },
}

window:setOnContextMenu(function(sender, x, y)
    say("Right-clicked at " .. x .. ", " .. y)

    -- Rebuilt each time. A menu you keep between clicks works too, but this
    -- way the entries can depend on what was actually clicked.
    build(TEMPLATE):popupAt(sender, x, y)
end)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:addChild(log)

window:setLayout(layout)
window:show()
