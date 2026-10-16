-- A folder mirror: pick a source and a destination, and the destination
-- is kept a copy of the source -- at the press of a button, and then on
-- its own as files change.
--
-- Four pieces of the sys module, working together:
--
--   FileWatcher   watches the source tree and reports changed paths
--   Timer         debounces: one burst of changes becomes one sync
--   Thread        walks and copies off the GUI thread
--   Signal        says "done" from the worker, safely
--
-- The worker builds a plain Lua table of what it did -- copied, skipped,
-- failed -- and the signal handler, back on the GUI thread, pours that into
-- the log table. The worker never touches a widget: Limekit raises if it
-- tries, and it would be a crash in the making otherwise.
--
-- One honest limit, from the threads example: there is one Lua state, so
-- while the worker runs its loop your handlers wait. A sync of a few
-- hundred files takes well under a second; for a terabyte you would want
-- a separate process.
--
-- Nothing is ever deleted from the destination. A mirror that deletes is
-- a mirror that can delete the wrong thing.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local FS = fs.FileSystem
local window = ui.Window { title = "Folder mirror - Limekit 2.0", size = { 900, 620 } }

local SETTINGS = FS.joinPaths(sys.System.getStandardPath("temp"), "limekit-folder-mirror.json")

-- STATE ----------------------------------------------------------------------

local settings = { source = "", destination = "", watch = false, dryRun = false }
do
    local ok, saved = pcall(function() return FS.readJSON(SETTINGS) end)
    if ok and type(saved) == "table" then
        for key, value in pairs(saved) do settings[key] = value end
    end
end

local function saveSettings()
    pcall(function() FS.writeJSON(SETTINGS, settings, 2) end)
end

local report = {}           -- filled by the worker, read by the GUI
local totals = { copied = 0, skipped = 0, failed = 0, runs = 0 }

-- WIDGETS ----------------------------------------------------------------------

local sourceEdit = ui.LineEdit(settings.source)
sourceEdit:setReadOnly(true)
sourceEdit:setHint("The folder to copy from")
local destinationEdit = ui.LineEdit(settings.destination)
destinationEdit:setReadOnly(true)
destinationEdit:setHint("The folder to keep as a copy")

local watchCheck = ui.CheckBox("Watch the source and sync on changes")
watchCheck:setChecked(settings.watch)
local dryCheck = ui.CheckBox("Dry run: report, copy nothing")
dryCheck:setChecked(settings.dryRun)

local syncButton = ui.Button("Sync now")
local openButton = ui.Button("Open destination")

local log = ui.Table(0, 4)
log:setColumnHeaders({ "Time", "Action", "File", "Why" })
log:setColumnWidth(1, 80)
log:setColumnWidth(2, 80)
log:setColumnWidth(3, 420)
log:setStretchLastColumn(true)
log:setRowHeadersVisible(false)
log:setSelectionBehavior("rows")

local status = ui.StatusBar()
window:setStatusbar(status)
local summary = ui.Label("")
status:addPermanentChild(summary)
local busy = ui.ProgressBar()
busy:setRange(0, 0)
busy:setMaxWidth(120)
busy:setMaxHeight(10)
busy:setVisible(false)
status:addPermanentChild(busy)

-- THE WORK, OFF THE GUI THREAD -------------------------------------------------------

-- Compares by size. The file system module reports sizes but not
-- modification times, so a changed file that kept its size is missed by a
-- plain sync -- the watcher catches those, since it names the path.
local function needsCopy(from, to, force)
    if not FS.exists(to) then return true, "new" end
    if force then return true, "changed" end
    if FS.getFileSize(from) ~= FS.getFileSize(to) then return true, "size differs" end
    return false, "same size"
end

local function mirror(source, destination, dryRun, forced)
    local out = {}
    local function note(action, file, why)
        out[#out + 1] = { action = action, file = file, why = why }
    end
    local function walk(from, to)
        if not FS.exists(to) then
            if not dryRun then FS.createFolder(to) end
            note("folder", to, dryRun and "would create" or "created")
        end
        for _, entry in ipairs(FS.walkDir(from)) do
            local target = FS.joinPaths(to, entry.name)
            if entry.is_dir then
                walk(entry.path, target)
            else
                local copy, why = needsCopy(entry.path, target, forced[FS.normalPath(entry.path)])
                if not copy then
                    note("skip", entry.path, why)
                elseif dryRun then
                    note("would copy", entry.path, why)
                else
                    local ok, err = pcall(FS.copyFile, entry.path, target)
                    if ok then note("copied", entry.path, why) else note("failed", entry.path, tostring(err)) end
                end
            end
        end
    end
    walk(source, destination)
    return out
end

local pending = { forced = {} }       -- what the next run should do
local worker = sys.Thread()
local finished = sys.Signal()

worker:setOnThreadRun(function()
    -- Plain values in, plain values out. No widgets here.
    report = mirror(pending.source, pending.destination, pending.dryRun, pending.forced)
    finished:relay()
end)

-- BACK ON THE GUI THREAD -------------------------------------------------------

local function stamp()
    return os.date("%H:%M:%S")
end

finished:setOnSignal(function()
    local copied, skipped, failed = 0, 0, 0
    for _, entry in ipairs(report) do
        if entry.action == "skip" then
            skipped = skipped + 1
        else
            local row = log:getRowCount() + 1
            log:setRowCount(row)
            log:setCellText(row, 1, stamp())
            log:setCellText(row, 2, entry.action)
            log:setCellText(row, 3, entry.file)
            log:setCellText(row, 4, entry.why)
            if entry.action == "failed" then
                failed = failed + 1
                log:getCellItem(row, 2):setTextColour("#DC2626")
            elseif entry.action == "copied" then
                copied = copied + 1
                log:getCellItem(row, 2):setTextColour("#16A34A")
            end
        end
    end
    totals.copied = totals.copied + copied
    totals.skipped = totals.skipped + skipped
    totals.failed = totals.failed + failed
    totals.runs = totals.runs + 1
    summary:setText(string.format("%d runs   %d copied   %d unchanged   %d failed",
        totals.runs, totals.copied, totals.skipped, totals.failed))
    status:setText(string.format("Sync done: %d copied, %d unchanged, %d failed.", copied, skipped, failed), 5000)
    busy:setVisible(false)
    syncButton:setEnabled(true)
    pending.forced = {}
end)

-- STARTING A SYNC ------------------------------------------------------------------

local function ready()
    if settings.source == "" or settings.destination == "" then
        status:setText("Choose a source and a destination first.", 4000)
        return false
    end
    if not FS.isFolder(settings.source) then
        status:setText("The source folder does not exist.", 4000)
        return false
    end
    local s, d = FS.normalPath(settings.source):lower(), FS.normalPath(settings.destination):lower()
    if s == d or d:sub(1, #s + 1) == s .. "\\" or d:sub(1, #s + 1) == s .. "/" then
        status:setText("The destination cannot be the source or inside it -- that would copy forever.", 6000)
        return false
    end
    return true
end

local function sync()
    if worker:isRunning() then return end
    if not ready() then return end
    pending.source, pending.destination, pending.dryRun = settings.source, settings.destination, dryCheck:isChecked()
    busy:setVisible(true)
    syncButton:setEnabled(false)
    status:setText(pending.dryRun and "Checking..." or "Syncing...")
    worker:start()
end

-- WATCHING ---------------------------------------------------------------------------

local watcher = sys.FileWatcher()
local debounce = sys.Timer()
debounce:setSingleShot(true)
debounce:setInterval(800)
debounce:setOnTimeout(sync)

watcher:setOnChange(function(paths)
    -- The paths name what changed, so those files are copied even when
    -- their size did not change. One burst of saves becomes one sync.
    for _, p in ipairs(paths) do pending.forced[FS.normalPath(p)] = true end
    status:setText(#paths .. " change" .. (#paths > 1 and "s" or "") .. " in the source...")
    debounce:start()
end)

local function applyWatch()
    watcher:clear()
    if watchCheck:isChecked() and settings.source ~= "" and FS.isFolder(settings.source) then
        local count = watcher:watchTree(settings.source)
        status:setText("Watching " .. count .. " folder" .. (count ~= 1 and "s" or "") .. " under " .. settings.source, 4000)
    end
end

-- EVENTS -------------------------------------------------------------------------------

local function pick(edit, key, title)
    local folder = ui.Dialogs.pickFolder(window, title, settings[key] ~= "" and settings[key] or nil)
    if not folder or folder == "" then return end
    settings[key] = folder
    edit:setText(folder)
    saveSettings()
    applyWatch()
end

local sourceButton = ui.Button("Browse...")
sourceButton:setOnClick(function() pick(sourceEdit, "source", "Folder to copy from") end)
local destinationButton = ui.Button("Browse...")
destinationButton:setOnClick(function() pick(destinationEdit, "destination", "Folder to keep as a copy") end)

watchCheck:setOnCheck(function(_, checked)
    settings.watch = checked == true
    saveSettings()
    applyWatch()
end)
dryCheck:setOnCheck(function(_, checked)
    settings.dryRun = checked == true
    saveSettings()
end)
syncButton:setOnClick(sync)
openButton:setOnClick(function()
    if settings.destination ~= "" and FS.exists(settings.destination) then
        sys.System.openPath(settings.destination)
    end
end)
local clearButton = ui.Button("Clear log")
clearButton:setOnClick(function() log:setRowCount(0) end)

-- LAYOUT ---------------------------------------------------------------------------------

local form = ui.GridLayout()
form:setSpacing(8)
form:addChild(ui.Label("Source"), 1, 1)
form:addChild(sourceEdit, 1, 2)
form:addChild(sourceButton, 1, 3)
form:addChild(ui.Label("Destination"), 2, 1)
form:addChild(destinationEdit, 2, 2)
form:addChild(destinationButton, 2, 3)
form:setColumnStretch(2, 1)

local options = ui.HLayout()
options:setSpacing(16)
options:addChild(watchCheck)
options:addChild(dryCheck)
options:addStretch()
options:addChild(clearButton)
options:addChild(openButton)
options:addChild(syncButton)

local main = ui.VLayout()
main:setMargins(12, 12, 12, 8)
main:setSpacing(10)
main:addLayout(form)
main:addLayout(options)
main:addChild(log, 1)
window:setLayout(main)

summary:setText("No runs yet")
applyWatch()
window:show()
