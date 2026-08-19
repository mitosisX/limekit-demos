-- The file system.
--
-- 1.x scattered these across the `app` table -- app.readFile, app.exists,
-- app.joinPaths, app.createFolder. They are all static methods on
-- fs.FileSystem now, so you call them with a dot and no receiver.
--
-- Everything here works inside a folder this example creates in your temp
-- directory, so nothing you care about is at risk.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local window = ui.Window { title = "Files - Limekit 2.0", size = { 700, 520 } }

local SANDBOX = fs.FileSystem.joinPaths(sys.System.getStandardPath("temp"), "limekit-files-example")

-- createFolder makes any missing parents too, and does nothing if the folder
-- is already there.
fs.FileSystem.createFolder(SANDBOX)

local listing = ui.ListBox()
local viewer = ui.TextField()
viewer:setHint("Pick a file on the left.")

local status = ui.Label("")
status:setWordWrap(true)

local function pathOf(name)
    return fs.FileSystem.joinPaths(SANDBOX, name)
end

local function refresh()
    listing:clear()
    -- listFolder gives the names directly inside; walkDir recurses.
    for _, name in ipairs(fs.FileSystem.listFolder(SANDBOX)) do
        listing:addItem(name)
    end
    status:setText(listing:getItemsCount() .. " entries in " .. SANDBOX)
end

-- Seed a few files so there is something to look at.
if not fs.FileSystem.exists(pathOf("readme.txt")) then
    fs.FileSystem.writeFile(pathOf("readme.txt"),
        "Limekit 2.0 file example.\nThis file was written by fs.FileSystem.writeFile.\n")
    fs.FileSystem.writeFile(pathOf("notes.md"), "# Notes\n\n- one\n- two\n- three\n")
    -- writeJSON takes a Lua table and writes it as JSON.
    fs.FileSystem.writeJSON(pathOf("config.json"), {
        name = "example",
        version = "2.0",
        enabled = true,
    }, 2)
end

listing:setOnItemSelect(function(sender, name, row)
    local path = pathOf(name)

    if fs.FileSystem.isFolder(path) then
        viewer:setText("(a folder)")
        status:setText(name .. " is a folder.")
        return
    end

    viewer:setText(fs.FileSystem.readFile(path))
    status:setText(
        name ..
        "   " .. sys.System.bytesToReadableSize(fs.FileSystem.getFileSize(path)) ..
        "   extension: " .. fs.FileSystem.getFileExt(path)
    )
end)

-- Buttons ------------------------------------------------------------------

local nameField = ui.LineEdit()
nameField:setHint("new file name")

local create = ui.Button("Create")
create:setOnClick(function()
    local name = nameField:getText()
    if name == "" then
        status:setText("Give it a name first.")
        return
    end
    fs.FileSystem.writeFile(pathOf(name), "Created by the files example.\n")
    nameField:clear()
    refresh()
end)

local save = ui.Button("Save the editor")
save:setOnClick(function()
    local row = listing:getCurrentRow()
    if row == 0 then
        status:setText("Nothing is selected.")
        return
    end
    local name = listing:getItemAt(row)
    fs.FileSystem.writeFile(pathOf(name), viewer:getText())
    status:setText("Wrote " .. name .. ".")
end)

local append = ui.Button("Append a line")
append:setOnClick(function()
    local row = listing:getCurrentRow()
    if row == 0 then return end
    local name = listing:getItemAt(row)
    fs.FileSystem.appendFile(pathOf(name), "appended\n")
    viewer:setText(fs.FileSystem.readFile(pathOf(name)))
end)

local copy = ui.Button("Copy")
copy:setOnClick(function()
    local row = listing:getCurrentRow()
    if row == 0 then return end
    local name = listing:getItemAt(row)
    fs.FileSystem.copyFile(pathOf(name), pathOf("copy-of-" .. name))
    refresh()
end)

local delete = ui.Button("Delete")
delete:setOnClick(function()
    local row = listing:getCurrentRow()
    if row == 0 then return end
    local name = listing:getItemAt(row)
    -- Reading or deleting something that is not there raises a Limekit error
    -- naming the path, rather than a bare Python traceback.
    local ok, err = pcall(function() fs.FileSystem.deleteFile(pathOf(name)) end)
    status:setText(ok and ("Deleted " .. name) or tostring(err))
    refresh()
end)

local json = ui.Button("Read the JSON")
json:setOnClick(function()
    -- readJSON hands back a Lua table, so index it directly.
    local config = fs.FileSystem.readJSON(pathOf("config.json"))
    status:setText("config.json -> name=" .. tostring(config.name) ..
                   "  version=" .. tostring(config.version))
end)

local walk = ui.Button("Walk the folder")
walk:setOnClick(function()
    -- walkDir gives one level, folders first, and each entry is a table with
    -- name, path and is_dir -- exactly what a file tree needs. It does not
    -- recurse, despite the name: call it again on anything whose is_dir is
    -- true, which is what this does.
    local found = {}

    local function descend(folder, indent)
        for _, entry in ipairs(fs.FileSystem.walkDir(folder)) do
            table.insert(found, indent .. entry.name .. (entry.is_dir and "/" or ""))
            if entry.is_dir then
                descend(entry.path, indent .. "    ")
            end
        end
    end

    descend(SANDBOX, "")
    viewer:setText(table.concat(found, "\n"))
    status:setText(#found .. " entries found by walkDir.")
end)

local lines = ui.Button("Read as lines")
lines:setOnClick(function()
    local row = listing:getCurrentRow()
    if row == 0 then return end
    local read = fs.FileSystem.readFileLines(pathOf(listing:getItemAt(row)))
    status:setText(#read .. " lines.")
end)

-- Layout -------------------------------------------------------------------

local entry = ui.HLayout()
entry:addChild(nameField, 1)
entry:addChild(create)

local actions = ui.HLayout()
actions:addChild(save)
actions:addChild(append)
actions:addChild(copy)
actions:addChild(delete)
actions:addChild(lines)
actions:addChild(json)
actions:addChild(walk)
actions:addStretch(1)

local columns = ui.HLayout()
columns:addChild(listing, 1)
columns:addChild(viewer, 2)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(10)
layout:addLayout(entry)
layout:addLayout(columns, 1)
layout:addLayout(actions)
layout:addChild(ui.HLine())
layout:addChild(status)

refresh()

window:setLayout(layout)
window:show()
