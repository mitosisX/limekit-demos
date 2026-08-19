-- Docking -- panels around the edge of the window.
--
-- A Dock is a panel the user can drag to another edge, float free of the
-- window, or close. The window keeps one central widget; docks surround it.

local ui = require("limekit.ui")

local window = ui.Window { title = "Docking - Limekit 2.0", size = { 760, 520 } }

-- The centre. setMainChild, not setLayout: docks attach around a central
-- widget, so the middle has to be one widget rather than a loose layout.
local editor = ui.TextField()
editor:setHint("The central widget. Docks live around it.")

-- LEFT: a file tree.
local tree = ui.TreeView()
tree:setHeaderHidden(true)

local project = ui.TreeViewItem({ "my-project" })
for _, name in ipairs({ "main.lua", "helpers.lua", "app.json" }) do
    project:addChild(ui.TreeViewItem({ name }))
end
project:setExpanded(true)
tree:addTopItem(project)

local explorer = ui.Dock("Explorer")
explorer:setChild(tree)
-- Names it does not recognise now raise. 1.x's setMagneticAreas silently
-- ignored them, so a typo cost you the restriction without telling you.
explorer:setAllowedAreas("left", "right")

-- RIGHT: properties, built from a layout rather than a single widget.
local properties = ui.Dock("Properties")
local propertyForm = ui.FormLayout()
propertyForm:addChild("Name", ui.LineEdit("main.lua"))
propertyForm:addChild("Type", ui.Label("Lua script"))
propertyForm:addChild("Lines", ui.Label("128"))
properties:setLayout(propertyForm)

-- BOTTOM: an output console.
local console = ui.Dock("Output")
local log = ui.TextField()
log:setReadOnly(true)
log:setText("Ready.")
console:setChild(log)
console:setAllowedAreas("bottom", "top")

window:addDockable(explorer, "left")
window:addDockable(properties, "right")
window:addDockable(console, "bottom")

local function note(message)
    log:appendText(message)
end

explorer:setOnLocationChange(function(sender, area)
    note("Explorer moved to the " .. tostring(area) .. ".")
end)

console:setOnVisibilityChange(function(sender, visible)
    if visible then note("Output shown.") end
end)

tree:setOnItemClick(function(sender, item, column)
    -- Columns are 1-based, so this hands getText exactly what it wants.
    editor:setText("-- " .. item:getText(column))
end)

window:setMainChild(editor)
window:show()
