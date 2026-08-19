-- A file explorer.
--
-- The interesting problem here is not any one widget: it is keeping three
-- views of the same thing -- a folder tree, a listing, and a preview -- in
-- step as the user moves around, without any of them drifting out of sync
-- with the disk.
--
-- The answer is that there is exactly one piece of state, `currentPath`, and
-- one function, `navigate`, that everything else goes through. No handler
-- updates a view directly.
--
-- It starts in a sandbox it creates under your temp folder, so the file
-- operations have somewhere safe to work, but the path bar will take you
-- anywhere. Browsing is read-only; only New folder, Rename and Delete change
-- anything, and the last two live in the right-click menu behind a
-- confirmation.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

-- Bind the module classes to locals once, up front, and call through those.
--
-- This is ordinary Lua practice: a name resolved once beats the same lookup
-- repeated in a loop. It matters more than usual here, because `fs.FileSystem`
-- is a Python class reached across the bridge, so `FS.readFile` is
-- two boundary crossings every single time it appears.
local FS = fs.FileSystem
local System = sys.System

local window = ui.Window { title = "File Explorer - Limekit 2.0", size = { 1000, 620 } }

local SANDBOX = FS.joinPaths(
    System.getStandardPath("temp"), "limekit-explorer-example")

-- A little tree to look at, built once.
local function seed()
    if FS.exists(SANDBOX) then return end

    FS.createFolder(FS.joinPaths(SANDBOX, "documents", "invoices"))
    FS.createFolder(FS.joinPaths(SANDBOX, "documents", "letters"))
    FS.createFolder(FS.joinPaths(SANDBOX, "pictures"))
    FS.createFolder(FS.joinPaths(SANDBOX, "empty folder"))

    local FILES = {
        { "readme.txt", "A file explorer written with Limekit 2.0.\nEverything here is a real file on disk.\n" },
        { "notes.md", "# Notes\n\n- the tree, listing and preview share one path\n- nothing writes to a view directly\n" },
        { "documents/report.txt", "Quarterly report\n\nRevenue rose. Costs rose faster.\n" },
        { "documents/invoices/january.txt", "Invoice 001\nTotal: 1200\n" },
        { "documents/invoices/february.txt", "Invoice 002\nTotal: 980\n" },
        { "documents/letters/reply.txt", "Dear sir,\n\nNo.\n\nYours,\n" },
    }

    for _, file in ipairs(FILES) do
        FS.writeFile(FS.joinPaths(SANDBOX, file[1]), file[2])
    end
end

seed()

-- THE VIEWS ----------------------------------------------------------------

local tree = ui.TreeView()
tree:setHeaderLabels({ "Folders" })

local listing = ui.Table(0, 3)
listing:setColumnHeaders({ "Name", "Kind", "Size" })
listing:setColumnWidth(1, 240)
listing:setSelectionBehavior("rows")
listing:setCellsEditable(false)

local preview = ui.TextField()
preview:setReadOnly(true)
preview:setHint("Select a file to preview it.")

local pathBar = ui.LineEdit()
local status = ui.StatusBar()
window:setStatusbar(status)

local counts = ui.Label("")
status:addPermanentChild(counts)

-- THE ONE PIECE OF STATE ---------------------------------------------------

local currentPath = SANDBOX
local currentRows = {}          -- what the listing is showing, row by row

-- TEXT FILES ---------------------------------------------------------------
-- There is no "is this text?" call, and there should not be: guessing is the
-- caller's job. Extension first, then a read that is allowed to fail.

local TEXT_EXTENSIONS = {
    [".txt"] = true, [".md"] = true, [".lua"] = true, [".json"] = true,
    [".csv"] = true, [".log"] = true, [".ini"] = true, [".xml"] = true,
    [".html"] = true, [".css"] = true, [".py"] = true, [".yml"] = true,
}

local function describe(path, isFolder)
    if isFolder then return "Folder", "" end

    local extension = FS.getFileExt(path)
    local kind = extension ~= "" and (extension:sub(2):upper() .. " file") or "File"
    return kind, System.bytesToReadableSize(FS.getFileSize(path))
end

local function showPreview(path)
    local extension = FS.getFileExt(path):lower()

    if not TEXT_EXTENSIONS[extension] then
        preview:setText("(" .. FS.getFileName(path) ..
                        " is not a text file, so there is nothing to show.)")
        return
    end

    -- A file can vanish, be locked, or turn out not to be text after all.
    -- The error names the path rather than arriving as a Python traceback.
    local ok, contents = pcall(function() return FS.readFile(path) end)
    if not ok then
        preview:setText("Could not read it: " .. tostring(contents))
        return
    end

    preview:setText(contents)
end

-- NAVIGATION ---------------------------------------------------------------
-- Every path change in the whole application goes through this one function.
-- That is the reason the three views cannot disagree with each other.

local function navigate(path)
    if not FS.exists(path) or not FS.isFolder(path) then
        status:setText("Not a folder: " .. tostring(path), 5000)
        return
    end

    currentPath = FS.normalPath(path)
    pathBar:setText(currentPath)

    -- walkDir gives one level, folders first, each entry a table with name,
    -- path and is_dir. It does not recurse, despite the name.
    local ok, entries = pcall(function() return FS.walkDir(currentPath) end)
    if not ok then
        status:setText("Could not open it: " .. tostring(entries), 6000)
        return
    end

    currentRows = {}
    listing:clear()
    listing:setColumnHeaders({ "Name", "Kind", "Size" })
    listing:setRowCount(#entries)

    local folders, files, bytes = 0, 0, 0

    for row, entry in ipairs(entries) do
        local kind, size = describe(entry.path, entry.is_dir)

        listing:setCellText(row, 1, entry.name)
        listing:setCellText(row, 2, kind)
        listing:setCellText(row, 3, size)

        currentRows[row] = entry

        if entry.is_dir then
            folders = folders + 1
        else
            files = files + 1
            bytes = bytes + FS.getFileSize(entry.path)
        end
    end

    listing:setColumnWidth(1, 240)
    preview:setText("")

    counts:setText(folders .. " folders, " .. files .. " files, " ..
                   System.bytesToReadableSize(bytes))
    status:setText(currentPath)
end

-- THE TREE -----------------------------------------------------------------
-- TreeView reports clicks and double-clicks but not expansion, so a folder's
-- children are filled the first time you click it rather than when you open
-- it. One level at a time is the honest approach anyway: a recursive walk of
-- a real disk would block for as long as the disk took.
--
-- Each node is filled once and then left alone. A TreeViewItem can gain
-- children but not lose them -- there is no removeChild on the Limekit class
-- -- so the way to reflect a folder that changed on disk is to rebuild the
-- tree from the root, which is what Refresh does.

local nodes = {}                -- TreeViewItem -> { path, loaded }

local function addNode(parent, name, path)
    local item = ui.TreeViewItem({ name })
    nodes[item] = { path = path, loaded = false }

    if parent then
        parent:addChild(item)
    else
        tree:addTopItem(item)
    end

    return item
end

local function fill(item)
    local node = nodes[item]
    if not node or node.loaded then return end
    node.loaded = true

    local ok, entries = pcall(function() return FS.walkDir(node.path) end)
    if not ok then return end

    for _, entry in ipairs(entries) do
        if entry.is_dir then
            addNode(item, entry.name, entry.path)
        end
    end
end

local function rebuildTree(root)
    tree:clear()
    nodes = {}

    local top = addNode(nil, FS.getFileName(root) ~= "" and
                             FS.getFileName(root) or root, root)
    fill(top)
    top:setExpanded(true)
    return top
end

tree:setOnItemClick(function(sender, item, column)
    local node = nodes[item]
    if not node then return end

    fill(item)
    item:setExpanded(true)
    navigate(node.path)
end)

-- THE LISTING --------------------------------------------------------------

listing:setOnCellClick(function(sender, row, column)
    local entry = currentRows[row]
    if not entry then return end

    if entry.is_dir then
        preview:setText("(" .. entry.name .. " is a folder -- double-click to open it.)")
    else
        showPreview(entry.path)
    end

    status:setText(entry.path)
end)

listing:setOnCellDoubleClick(function(sender, row, column)
    local entry = currentRows[row]
    if not entry then return end

    if entry.is_dir then
        navigate(entry.path)
    else
        showPreview(entry.path)
    end
end)

-- COMMANDS -----------------------------------------------------------------

local function selectedEntry()
    local row = listing:getCurrentRow()
    -- 0 means nothing is selected. Qt would have said -1.
    if row == 0 then return nil end
    return currentRows[row]
end

local function goUp()
    local parent = FS.getDirName(currentPath)
    if parent == "" or parent == currentPath then
        status:setText("Already at the top of this drive.", 4000)
        return
    end
    navigate(parent)
end

local function refresh()
    rebuildTree(SANDBOX)
    navigate(currentPath)
    status:setText("Refreshed.", 3000)
end

local function newFolder()
    -- No dialog: create a folder with a free name and let the user rename
    -- it, which is what a file manager does. Asking first would mean a modal
    -- for something that can be undone with Delete.
    local name, path = "New folder", nil
    local attempt = 1

    repeat
        name = attempt == 1 and "New folder" or ("New folder " .. attempt)
        path = FS.joinPaths(currentPath, name)
        attempt = attempt + 1
    until not FS.exists(path)

    local ok, err = pcall(function() FS.createFolder(path) end)
    if not ok then
        status:setText("Could not create it: " .. tostring(err), 6000)
        return
    end

    navigate(currentPath)
    status:setText("Created " .. name, 4000)
end

local function renameSelected()
    local entry = selectedEntry()
    if not entry then
        status:setText("Select something first.", 4000)
        return
    end

    local name = ui.Dialogs.textInput(window, "Rename", "New name:", entry.name)
    -- nil is cancelled; an empty string is a real answer, and a bad one.
    if name == nil then return end
    if name == "" then
        status:setText("A name cannot be empty.", 4000)
        return
    end

    local target = FS.joinPaths(currentPath, name)
    if FS.exists(target) then
        ui.Dialogs.warning(window, "Already there", name .. " already exists.")
        return
    end

    local ok, err = pcall(function() FS.renameFile(entry.path, target) end)
    if not ok then
        ui.Dialogs.critical(window, "Could not rename it", tostring(err))
        return
    end

    navigate(currentPath)
    status:setText("Renamed to " .. name, 4000)
end

local function deleteSelected()
    local entry = selectedEntry()
    if not entry then
        status:setText("Select something first.", 4000)
        return
    end

    if entry.is_dir then
        -- deleteFile is for files. Removing a folder tree is not in the API,
        -- and quietly doing it with a recursive walk would be a surprising
        -- amount of destruction behind one confirmation.
        ui.Dialogs.warning(window, "Folders",
            "This example only deletes files. Removing a folder tree is a bigger " ..
            "decision than one dialog should carry.")
        return
    end

    if not ui.Dialogs.question(window, "Delete", "Delete " .. entry.name .. "?") then
        return
    end

    local ok, err = pcall(function() FS.deleteFile(entry.path) end)
    if not ok then
        ui.Dialogs.critical(window, "Could not delete it", tostring(err))
        return
    end

    navigate(currentPath)
    status:setText("Deleted " .. entry.name, 4000)
end

local function copyPath()
    local entry = selectedEntry()
    if not entry then
        status:setText("Select something first.", 4000)
        return
    end

    System.setClipboardText(entry.path)
    status:setText("Copied " .. entry.path, 4000)
end

-- CHROME -------------------------------------------------------------------

local toolbar = ui.Toolbar("Navigation")
toolbar:setToolButtonStyle("textbesideicon")

local TOOLS = {
    { "Up", "SP_FileDialogToParent", goUp },
    { "Home", "SP_DirHomeIcon", function() navigate(SANDBOX) end },
    { "Refresh", "SP_BrowserReload", refresh },
    { "New folder", "SP_FileDialogNewFolder", newFolder },
}

for _, tool in ipairs(TOOLS) do
    local button = ui.ToolbarButton(tool[1])
    button:setIcon(window:getStandardIcon(tool[2]))
    button:setStatusTip(tool[1])
    button:setOnClick(tool[3])
    toolbar:addButton(button)
end

window:addToolbar(toolbar, "top")

-- The destructive commands live in the right-click menu rather than the
-- toolbar, where a passing click could reach them.
window:setOnContextMenu(function(sender, x, y)
    local menu = ui.Menu()

    local entry = selectedEntry()
    local label = entry and entry.name or "nothing selected"

    local heading = ui.MenuItem(label)
    heading:setEnabled(false)
    menu:addMenuItem(heading)
    menu:addSeparator()

    local COMMANDS = {
        { "Copy path", copyPath },
        { "Rename...", renameSelected },
        { "Delete...", deleteSelected },
    }

    for _, command in ipairs(COMMANDS) do
        local item = ui.MenuItem(command[1])
        item:setEnabled(entry ~= nil)
        item:setOnClick(command[2])
        menu:addMenuItem(item)
    end

    menu:addSeparator()

    local newItem = ui.MenuItem("New folder")
    newItem:setOnClick(newFolder)
    menu:addMenuItem(newItem)

    menu:popupAt(sender, x, y)
end)

-- The path bar takes you anywhere, so the sandbox is a starting point rather
-- than a cage.
pathBar:setOnReturnPress(function(sender)
    navigate(sender:getText())
end)

local go = ui.Button("Go")
go:setOnClick(function() navigate(pathBar:getText()) end)

local home = ui.Button("Sandbox")
home:setOnClick(function() navigate(SANDBOX) end)

-- LAYOUT -------------------------------------------------------------------

local addressRow = ui.HLayout()
addressRow:addChild(ui.Label("Path:"))
addressRow:addChild(pathBar, 1)
addressRow:addChild(go)
addressRow:addChild(home)

-- Three panes the user can rebalance: tree, listing, preview.
local panes = ui.Splitter("horizontal")
panes:addChild(tree)
panes:addChild(listing)
panes:addChild(preview)
panes:setSizes({ 220, 440, 320 })
panes:setHandleWidth(6)

local root = ui.VLayout()
root:setMargins(10, 10, 10, 10)
root:setSpacing(8)
root:addLayout(addressRow)
root:addChild(panes, 1)

local body = ui.Container()
body:setLayout(root)

rebuildTree(SANDBOX)
navigate(SANDBOX)

window:setMainChild(body)
window:show()
