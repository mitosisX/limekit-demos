-- Notepad -- a complete small application.
--
-- Everything the other examples show in isolation, wired together: a menubar,
-- a toolbar, a status bar, file dialogs, keyboard shortcuts, and a dirty flag
-- that stops you losing work.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local window = ui.Window { title = "Untitled - Notepad", size = { 780, 560 } }

local editor = ui.TextField()
editor:setHint("Start typing, or open a file.")

local status = ui.StatusBar()
window:setStatusbar(status)

local position = ui.Label("")
status:addPermanentChild(position)

-- STATE --------------------------------------------------------------------

local currentPath = nil
local dirty = false

local FILTERS = {
    ["Text files"] = { "txt", "md", "lua" },
    ["All files"] = { "*" },
}

local function retitle()
    local name = currentPath and fs.FileSystem.getFileName(currentPath) or "Untitled"
    window:setTitle((dirty and "*" or "") .. name .. " - Notepad")
end

local function markDirty()
    if not dirty then
        dirty = true
        retitle()
    end
end

local function markClean()
    dirty = false
    retitle()
end

editor:setOnTextChange(function(sender)
    markDirty()
    position:setText(sender:getLineCount() .. " lines")
end)

-- Returns false if the user cancels, so callers can abandon what they were
-- about to do.
local function confirmDiscard()
    if not dirty then return true end
    return ui.Dialogs.question(
        window, "Unsaved changes",
        "You have unsaved changes. Throw them away?"
    )
end

-- COMMANDS -----------------------------------------------------------------

local function newFile()
    if not confirmDiscard() then return end
    editor:setText("")
    currentPath = nil
    markClean()
    status:setText("New file", 3000)
end

local function openFile()
    if not confirmDiscard() then return end

    local path = ui.Dialogs.openFile(window, "Open", nil, FILTERS)
    if not path then return end          -- nil means cancelled

    -- Reading a file that has gone away raises a Limekit error naming the
    -- path, rather than a raw Python traceback, so this is worth catching.
    local ok, contents = pcall(function() return fs.FileSystem.readFile(path) end)
    if not ok then
        ui.Dialogs.critical(window, "Could not open it", tostring(contents))
        return
    end

    editor:setText(contents)
    currentPath = path
    markClean()
    status:setText("Opened " .. path, 4000)
end

local function saveAs()
    local path = ui.Dialogs.saveFile(window, "Save as", nil, FILTERS)
    if not path then return false end

    fs.FileSystem.writeFile(path, editor:getText())
    currentPath = path
    markClean()
    status:setText("Saved to " .. path, 4000)
    return true
end

local function save()
    if not currentPath then return saveAs() end
    fs.FileSystem.writeFile(currentPath, editor:getText())
    markClean()
    status:setText("Saved", 3000)
    return true
end

local function findText()
    local needle = ui.Dialogs.textInput(window, "Find", "Look for:")
    if not needle or needle == "" then return end

    local haystack = editor:getText()
    local at = haystack:find(needle, 1, true)
    if at then
        -- Count the newlines before the hit to report a line number.
        local _, line = haystack:sub(1, at):gsub("\n", "")
        status:setText("Found at line " .. (line + 1), 4000)
    else
        status:setText("'" .. needle .. "' is not in the document.", 4000)
    end
end

local function wordCount()
    local text = editor:getText()
    local words = 0
    for _ in text:gmatch("%S+") do words = words + 1 end

    ui.Dialogs.info(window, "Statistics",
        editor:getLineCount() .. " lines\n" ..
        words .. " words\n" ..
        #text .. " characters")
end

local function about()
    ui.Dialogs.info(window, "About",
        "Notepad, written with Limekit 2.0.\n\nRunning on " ..
        sys.System.getOSName() .. " " .. sys.System.getOSVersion() .. ".")
end

-- MENUS --------------------------------------------------------------------

local function item(text, shortcut, handler)
    local menuItem = ui.MenuItem(text)
    if shortcut then menuItem:setShortcut(shortcut) end
    menuItem:setStatusTip(text)
    menuItem:setOnClick(handler)
    return menuItem
end

local fileMenu = ui.Menu("&File")
fileMenu:addMenuItem(item("New", "Ctrl+N", newFile))
fileMenu:addMenuItem(item("Open...", "Ctrl+O", openFile))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Save", "Ctrl+S", save))
fileMenu:addMenuItem(item("Save as...", "Ctrl+Shift+S", saveAs))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Exit", "Ctrl+Q", function()
    if confirmDiscard() then window:close() end
end))

local editMenu = ui.Menu("&Edit")
editMenu:addMenuItem(item("Find...", "Ctrl+F", findText))
editMenu:addMenuItem(item("Select all", "Ctrl+A", function()
    editor:setFocus()
end))
editMenu:addSeparator()
editMenu:addMenuItem(item("Word count", nil, wordCount))

local wrap = ui.MenuItem("Word wrap")
wrap:setCheckable(true)
wrap:setChecked(true)
wrap:setOnClick(function(sender)
    editor:setWrapMode(sender:isChecked() and "widget" or "none")
end)

local viewMenu = ui.Menu("&View")
viewMenu:addMenuItem(wrap)

local helpMenu = ui.Menu("&Help")
helpMenu:addMenuItem(item("About", "F1", about))

local menubar = ui.Menubar()
menubar:addMenu(fileMenu)
menubar:addMenu(editMenu)
menubar:addMenu(viewMenu)
menubar:addMenu(helpMenu)
window:setMenubar(menubar)

-- TOOLBAR ------------------------------------------------------------------

local toolbar = ui.Toolbar("Main")
toolbar:setToolButtonStyle("textbesideicon")

local TOOLS = {
    { "New", "SP_FileIcon", newFile },
    { "Open", "SP_DirOpenIcon", openFile },
    { "Save", "SP_DialogSaveButton", save },
}

for _, tool in ipairs(TOOLS) do
    local button = ui.ToolbarButton(tool[1])
    button:setIcon(window:getStandardIcon(tool[2]))
    button:setStatusTip(tool[1])
    button:setOnClick(tool[3])
    toolbar:addButton(button)
end

window:addToolbar(toolbar, "top")

-- A right-click menu on the editor itself.
window:setOnContextMenu(function(sender, x, y)
    local menu = ui.Menu()
    menu:addMenuItem(item("Find...", nil, findText))
    menu:addMenuItem(item("Word count", nil, wordCount))
    menu:addSeparator()
    menu:addMenuItem(item("Save", nil, save))
    menu:popupAt(sender, x, y)
end)

-- The window's own close, as distinct from File > Exit. There is no way to
-- veto a close from Lua, so this reports rather than blocks.
window:setOnClose(function()
    if dirty then
        status:setText("Closed with unsaved changes.")
    end
end)

retitle()

window:setMainChild(editor)
window:show()
