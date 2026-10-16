-- Notes, in Markdown, with a live preview.
--
-- Three panes: the list of notes, the text, and the rendered result. The
-- preview re-renders on every keystroke -- the renderer in markdown.lua is
-- cheap enough -- but saving is *debounced*: a single-shot sys.Timer is
-- restarted on each change and only fires once typing has paused. That is
-- the pattern for "save as you type" without hammering the disk.
--
-- The list is searched as you type, across titles, text and tags, through
-- one SQL query. Notes are kept in SQLite in the temp folder; the title is
-- derived from the text (first heading, else first line) so there is
-- nothing to fill in -- just write.
--
-- Closing the window with a save pending flushes it first, so no note is
-- lost to the timer never getting its chance.

local ui = require("limekit.ui")
local db = require("limekit.db")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local Markdown = require("markdown")

local window = ui.Window { title = "Notes - Limekit 2.0", size = { 1180, 700 } }

local DB_PATH = fs.FileSystem.joinPaths(sys.System.getStandardPath("temp"), "limekit-notes.db")
local notes = db.Sqlite3(DB_PATH)
notes:createTable("notes", {
    id = "INTEGER PRIMARY KEY AUTOINCREMENT",
    title = "TEXT NOT NULL",
    body = "TEXT NOT NULL DEFAULT ''",
    tags = "TEXT NOT NULL DEFAULT ''",
    updated = "TEXT NOT NULL",
}, true)
notes:save()

local status = ui.StatusBar()
window:setStatusbar(status)
local counts = ui.Label("")
status:addPermanentChild(counts)

-- STATE ----------------------------------------------------------------------

local current = nil         -- id of the note being edited, or nil
local listed = {}           -- rows in the list, in list order
local dirty = false         -- edits not yet written
local loading = false       -- true while the editor is being filled

local function now()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- WIDGETS --------------------------------------------------------------------

local search = ui.LineEdit()
search:setHint("Search titles, text and tags")

local list = ui.ListBox()

local editor = ui.TextField()
editor:setHint("Write in Markdown. # for a heading, - for a list, **bold**, `code`...")
editor:setWrapMode("widget")
editor:setStyleSheet("font-family: Consolas, 'DejaVu Sans Mono', monospace; font-size: 13px;")

local tagsEdit = ui.LineEdit()
tagsEdit:setHint("tags, comma, separated")

local preview = ui.TextField()
preview:setReadOnly(true)

-- SAVE AND LOAD --------------------------------------------------------------

local function refreshList()
    local needle = "%" .. search:getText():lower() .. "%"
    notes:execute("SELECT id, title, tags, updated FROM notes WHERE LOWER(title) LIKE ? "
        .. "OR LOWER(body) LIKE ? OR LOWER(tags) LIKE ? ORDER BY updated DESC;",
        { needle, needle, needle })
    listed = notes:fetchAll(true)
    list:clear()
    local selected = 1
    for index, note in ipairs(listed) do
        local tags = note.tags ~= "" and ("   #" .. note.tags:gsub(",%s*", " #")) or ""
        list:addItem(note.title .. tags)
        if note.id == current then selected = index end
    end
    if #listed > 0 then list:setCurrentRow(selected) end
    notes:execute("SELECT COUNT(*) FROM notes;")
    local total = notes:fetchOne()
    counts:setText(#listed == total and (total .. " notes") or (#listed .. " of " .. total .. " notes"))
end

local function save()
    if not current or not dirty then return end
    local body = editor:getText()
    notes:execute("UPDATE notes SET title = ?, body = ?, tags = ?, updated = ? WHERE id = ?;",
        { Markdown.title(body), body, tagsEdit:getText(), now(), current })
    notes:save()
    dirty = false
    status:setText("Saved " .. os.date("%H:%M:%S"), 2000)
    refreshList()
end

-- The debounce: every edit restarts this; it fires once typing has paused.
local saveTimer = sys.Timer()
saveTimer:setSingleShot(true)
saveTimer:setInterval(900)
saveTimer:setOnTimeout(save)

local function renderPreview()
    local body = editor:getText()
    preview:setHtml(Markdown.toHtml(body))
    status:setText(Markdown.wordCount(body) .. " words" .. (dirty and "   (unsaved)" or ""))
end

local function load(id)
    save()                           -- whatever was open, first
    saveTimer:stop()
    notes:execute("SELECT id, body, tags FROM notes WHERE id = ?;", { id })
    local note = notes:fetchOne(true)
    if not note then return end
    loading = true
    current = note.id
    editor:setText(note.body)
    tagsEdit:setText(note.tags)
    loading = false
    dirty = false
    renderPreview()
    editor:setFocus()
end

local function newNote()
    save()
    notes:insert("notes", { title = "Untitled", body = "", tags = "", updated = now() })
    notes:save()
    notes:execute("SELECT MAX(id) FROM notes;")
    local id = notes:fetchOne()
    search:setText("")
    refreshList()
    load(id)
    status:setText("New note -- start with a # heading to name it.", 4000)
end

local function deleteNote()
    if not current then return end
    local title = Markdown.title(editor:getText())
    if not ui.Dialogs.question(window, "Delete note", 'Delete "' .. title .. '"?') then return end
    saveTimer:stop()
    dirty = false
    notes:execute("DELETE FROM notes WHERE id = ?;", { current })
    notes:save()
    current = nil
    refreshList()
    if listed[1] then load(listed[1].id) else
        loading = true; editor:setText(""); tagsEdit:setText(""); loading = false
        preview:setHtml("")
    end
    status:setText("Deleted.", 3000)
end

local function exportHtml()
    if not current then return end
    local path = ui.Dialogs.saveFile(window, "Export as HTML",
        fs.FileSystem.joinPaths(sys.System.getStandardPath("documents"),
            Markdown.title(editor:getText()):gsub("[^%w%- ]", "") .. ".html"),
        { ["HTML"] = { "html" } })
    if not path then return end
    fs.FileSystem.writeFile(path, "<!doctype html><meta charset='utf-8'><body style='font-family:sans-serif;max-width:720px;margin:2em auto'>"
        .. Markdown.toHtml(editor:getText()) .. "</body>")
    status:setText("Exported to " .. path, 6000)
end

-- EVENTS ---------------------------------------------------------------------

editor:setOnTextChange(function()
    if loading or not current then return end
    dirty = true
    renderPreview()
    saveTimer:start()
end)

tagsEdit:setOnTextChange(function()
    if loading or not current then return end
    dirty = true
    saveTimer:start()
end)

search:setOnTextChange(function() refreshList() end)

list:setOnItemSelect(function()
    local row = list:getCurrentRow()
    local note = listed[row]
    if note and note.id ~= current then load(note.id) end
end)

window:setOnClose(function() save() end)

-- CHROME ---------------------------------------------------------------------

local function item(text, shortcut, handler)
    local entry = ui.MenuItem(text)
    if shortcut then entry:setShortcut(shortcut) end
    entry:setOnClick(handler)
    return entry
end
local menubar = ui.Menubar()
local noteMenu = ui.Menu("&Note")
noteMenu:addMenuItem(item("New", "Ctrl+N", newNote))
noteMenu:addMenuItem(item("Save now", "Ctrl+S", function() dirty = true; save() end))
noteMenu:addMenuItem(item("Export as HTML...", "Ctrl+E", exportHtml))
noteMenu:addSeparator()
noteMenu:addMenuItem(item("Delete", "Ctrl+Delete", deleteNote))
noteMenu:addSeparator()
noteMenu:addMenuItem(item("Quit", "Ctrl+Q", function() window:close() end))
menubar:addMenu(noteMenu)
window:setMenubar(menubar)

local toolbar = ui.Toolbar()
toolbar:setToolButtonStyle("textbesideicon")
for _, spec in ipairs({ { "New", newNote }, { "Delete", deleteNote }, { "Export HTML", exportHtml } }) do
    local button = ui.ToolbarButton(spec[1])
    button:setOnClick(spec[2])
    toolbar:addButton(button)
end
window:addToolbar(toolbar)

-- LAYOUT ---------------------------------------------------------------------

local sidebar = ui.VLayout()
sidebar:setMargins(6, 6, 2, 6)
sidebar:addChild(search)
sidebar:addChild(list, 1)
local sidebarBox = ui.Container()
sidebarBox:setLayout(sidebar)
sidebarBox:setMinWidth(180)

local editing = ui.VLayout()
editing:setMargins(2, 6, 2, 6)
editing:addChild(editor, 1)
local tagRow = ui.HLayout()
tagRow:addChild(ui.Label("Tags"))
tagRow:addChild(tagsEdit, 1)
editing:addLayout(tagRow)
local editBox = ui.Container()
editBox:setLayout(editing)

local previewLayout = ui.VLayout()
previewLayout:setMargins(2, 6, 6, 6)
previewLayout:addChild(preview, 1)
local previewBox = ui.Container()
previewBox:setLayout(previewLayout)

local split = ui.Splitter("horizontal")
split:addChild(sidebarBox)
split:addChild(editBox)
split:addChild(previewBox)
split:setStretchFactors({ 1, 2, 2 })
split:setSizes({ 240, 470, 470 })
window:setMainChild(split)

-- FIRST RUN ------------------------------------------------------------------

notes:execute("SELECT COUNT(*) FROM notes;")
if notes:fetchOne() == 0 then
    notes:insert("notes", {
        title = "Welcome to Notes", tags = "help, markdown", updated = now(),
        body = table.concat({
            "# Welcome to Notes",
            "",
            "Everything you type is **saved as you go** -- the status bar says when.",
            "",
            "## What the preview understands",
            "",
            "- `# Heading`, `## Smaller heading`",
            "- *italic*, **bold**, `code`",
            "- bullet lists and",
            "1. numbered lists",
            "",
            "> Quotes look like this.",
            "",
            "```",
            "local ui = require(\"limekit.ui\")   -- fenced code keeps its spacing",
            "```",
            "",
            "A [link](https://limekit.readthedocs.io) and a rule:",
            "",
            "---",
            "",
            "Search on the left looks through titles, text and tags.",
        }, "\n"),
    })
    notes:insert("notes", {
        title = "Shopping", tags = "home", updated = now(),
        body = "# Shopping\n\n- Coffee\n- Lemons\n- **Batteries** for the remote\n",
    })
    notes:save()
end

refreshList()
if listed[1] then load(listed[1].id) end
window:show()
