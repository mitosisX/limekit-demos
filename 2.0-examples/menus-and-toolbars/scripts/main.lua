-- Menus, toolbars and the status bar -- the chrome around an application.
--
-- 1.x had three mutually inconsistent buildFromTemplate implementations for
-- turning a Lua table into a menu tree. 2.0 has none: you call addMenuItem
-- and addMenu, which is what the templating code bottomed out in anyway. If
-- you want the table-driven version, it is a dozen lines of your own Lua --
-- and this example writes them.

local ui = require("limekit.ui")

local window = ui.Window { title = "Menus & Toolbars - Limekit 2.0", size = { 640, 440 } }

local editor = ui.TextField()
editor:setHint("Pick something from the menu.")

local status = ui.StatusBar()
status:setText("Ready")
window:setStatusbar(status)

local function say(message)
    status:setText(message, 4000)
    editor:appendText(message)
end

-- Building a menu by hand -------------------------------------------------

local function item(text, shortcut, handler)
    local menuItem = ui.MenuItem(text)
    if shortcut then
        menuItem:setShortcut(shortcut)
        menuItem:setStatusTip(text .. "  (" .. shortcut .. ")")
    end
    menuItem:setOnClick(handler)
    return menuItem
end

local fileMenu = ui.Menu("&File")
fileMenu:addMenuItem(item("New", "Ctrl+N", function() say("New file") end))
fileMenu:addMenuItem(item("Open", "Ctrl+O", function() say("Open file") end))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Save", "Ctrl+S", function() say("Saved") end))

local editMenu = ui.Menu("&Edit")
editMenu:addMenuItem(item("Cut", "Ctrl+X", function() say("Cut") end))
editMenu:addMenuItem(item("Copy", "Ctrl+C", function() say("Copied") end))

-- Submenus are just menus added to menus, as deep as you like.
local pasteMenu = ui.Menu("Paste as")
pasteMenu:addMenuItem(item("Plain text", nil, function() say("Pasted plain") end))
pasteMenu:addMenuItem(item("Formatted", nil, function() say("Pasted formatted") end))
editMenu:addMenu(pasteMenu)

-- A checkable item keeps its own state; isChecked() reads it back.
local wrap = ui.MenuItem("Word wrap")
wrap:setCheckable(true)
wrap:setChecked(true)
wrap:setOnClick(function(sender)
    say("Word wrap " .. (sender:isChecked() and "on" or "off"))
end)

local viewMenu = ui.Menu("&View")
viewMenu:addMenuItem(wrap)

local menubar = ui.Menubar()
menubar:addMenu(fileMenu)
menubar:addMenu(editMenu)
menubar:addMenu(viewMenu)
window:setMenubar(menubar)

-- The toolbar -------------------------------------------------------------

-- ToolbarButton is the same shape as MenuItem -- both wrap a Qt action -- so
-- the same helper builds either.
local toolbar = ui.Toolbar("Main")
toolbar:setMovable(true)
toolbar:setToolButtonStyle("textbesideicon")

for _, spec in ipairs({ { "New", "Ctrl+N" }, { "Open", "Ctrl+O" }, { "Save", "Ctrl+S" } }) do
    local button = ui.ToolbarButton(spec[1])
    button:setStatusTip(spec[1])
    button:setOnClick(function() say(spec[1] .. " from the toolbar") end)
    toolbar:addButton(button)
end

toolbar:addSeparator()

-- A toolbar button can own a drop-down menu of its own.
local exportMenu = ui.DropMenu("Export")
exportMenu:addMenuItem(item("As PDF", nil, function() say("Exported PDF") end))
exportMenu:addMenuItem(item("As HTML", nil, function() say("Exported HTML") end))

local export = ui.ToolbarButton("Export")
export:setMenu(exportMenu)
toolbar:addButton(export)

window:addToolbar(toolbar, "top")

-- A permanent status widget sits on the right and is never overwritten by a
-- message, unlike setText.
local clock = ui.Label("no edits yet")
status:addPermanentChild(clock)
editor:setOnTextChange(function(sender)
    clock:setText(sender:getLineCount() .. " lines")
end)

window:setMainChild(editor)
window:show()
