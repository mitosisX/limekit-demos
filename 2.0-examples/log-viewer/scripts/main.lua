-- A log viewer that tails a file as it grows.
--
-- This is the example that makes the timer-versus-thread question concrete.
-- Watching a file means doing a little work, often, forever -- which is a
-- timer's job, not a thread's. A sys.Thread would hold the single Lua state
-- for as long as it ran and the interface would see nothing until it
-- finished; a sys.Timer runs on the interface thread in short slices, so
-- each batch of lines is drawn as it arrives.
--
-- There are two timers here: one pretending to be an application writing a
-- log, and one tailing it. In a real app you would only have the second.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local FS = fs.FileSystem
local System = sys.System

local window = ui.Window { title = "Log Viewer - Limekit 2.0", size = { 900, 620 } }

local LOGFILE = FS.joinPaths(System.getStandardPath("temp"), "limekit-example.log")

-- Start from empty each run, so the numbers on screen mean something.
FS.writeFile(LOGFILE, "")

local SEVERITIES = {
    DEBUG = "#7a7a7a",
    INFO  = "#2d7d46",
    WARN  = "#b8860b",
    ERROR = "#c0392b",
}

local ORDER = { "DEBUG", "INFO", "WARN", "ERROR" }

local MESSAGES = {
    "connection opened", "cache warm", "user signed in", "query took 42ms",
    "retrying request", "disk almost full", "token expired", "wrote 12 rows",
    "connection reset", "config reloaded",
}

-- THE VIEW -----------------------------------------------------------------

local out = ui.TextField()
out:setReadOnly(true)
out:setHint("Waiting for the first line...")

local status = ui.StatusBar()
window:setStatusbar(status)

local tally = ui.Label("")
status:addPermanentChild(tally)

local filterField = ui.LineEdit()
filterField:setHint("only show lines containing...")

local levelPicker = ui.ComboBox({ "All", "DEBUG and above", "INFO and above", "WARN and above", "ERROR only" })

-- STATE --------------------------------------------------------------------

local lines = {}                -- every line read so far
local consumed = 0              -- how many lines of the file we have taken
local counts = { DEBUG = 0, INFO = 0, WARN = 0, ERROR = 0 }
local follow = true             -- scroll to the bottom on new lines?
local minimumLevel = 1          -- index into ORDER

local function levelOf(line)
    for _, name in ipairs(ORDER) do
        if line:find("[" .. name .. "]", 1, true) then return name end
    end
    return "INFO"
end

local function escape(text)
    -- The view renders HTML, so anything from the log has to be neutralised
    -- before it goes in. A log line is untrusted input like any other.
    return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function passes(line)
    local level = levelOf(line)

    local rank = 1
    for index, name in ipairs(ORDER) do
        if name == level then rank = index end
    end
    if rank < minimumLevel then return false end

    local needle = filterField:getText()
    if needle == "" then return true end

    -- Plain find, so a filter with a dash or bracket in it is a literal
    -- rather than a pattern that quietly matches nothing.
    return line:lower():find(needle:lower(), 1, true) ~= nil
end

-- RENDERING ----------------------------------------------------------------
-- The whole visible log is rebuilt whenever the filter changes, and only the
-- new lines are appended otherwise. Rebuilding on every incoming line would
-- get slower the longer the app ran.

local function render(line)
    local level = levelOf(line)
    return string.format('<span style="color:%s">%s</span>', SEVERITIES[level], escape(line))
end

local function rebuild()
    local visible = {}
    for _, line in ipairs(lines) do
        if passes(line) then table.insert(visible, render(line)) end
    end

    out:setHtml(table.concat(visible, "<br>"))
    status:setText(#visible .. " of " .. #lines .. " lines shown")

    if follow then out:scrollToEnd() end
end

local function showTally()
    local parts = {}
    for _, name in ipairs(ORDER) do
        table.insert(parts, name .. " " .. counts[name])
    end
    tally:setText(table.concat(parts, "   "))
end

-- TAILING ------------------------------------------------------------------
-- Read the file, take whatever is past the point we reached last time. The
-- file only ever grows here; a real tail would also notice truncation and
-- start again, which is a length comparison away.

local function poll()
    local ok, all = pcall(function() return FS.readFileLines(LOGFILE) end)
    if not ok then return end

    if #all < consumed then
        -- The file shrank, so it was rotated or truncated: start over.
        lines, consumed = {}, 0
        for _, name in ipairs(ORDER) do counts[name] = 0 end
    end

    if #all == consumed then return end

    local fresh = {}
    for index = consumed + 1, #all do
        local line = all[index]
        table.insert(lines, line)
        table.insert(fresh, line)
        local level = levelOf(line)
        counts[level] = counts[level] + 1
    end
    consumed = #all

    -- Append only what is new, unless a filter is on, in which case each new
    -- line still has to be tested.
    local additions = {}
    for _, line in ipairs(fresh) do
        if passes(line) then table.insert(additions, render(line)) end
    end

    if #additions > 0 then
        out:setHtml(out:getHtml() .. "<br>" .. table.concat(additions, "<br>"))
        if follow then out:scrollToEnd() end
    end

    status:setText(#lines .. " lines")
    showTally()
end

-- THE PRODUCER -------------------------------------------------------------
-- Stands in for whatever program is writing the log. In a real app this is
-- somebody else's process and none of your business.

local written = 0

local producer = sys.Timer()
producer:setInterval(400)
producer:setOnTimeout(function()
    written = written + 1
    local level = System.randomChoice({ "DEBUG", "INFO", "INFO", "INFO", "WARN", "ERROR" })
    local message = System.randomChoice(MESSAGES)
    FS.appendFile(LOGFILE, string.format("%05d [%s] %s\n", written, level, message))
end)

local tailer = sys.Timer()
tailer:setInterval(250)
tailer:setOnTimeout(poll)

-- CONTROLS -----------------------------------------------------------------

local running = ui.Button("Stop")
running:setOnClick(function(sender)
    if tailer:isActive() then
        producer:stop()
        tailer:stop()
        sender:setText("Start")
        status:setText("Stopped at " .. #lines .. " lines")
    else
        producer:start()
        tailer:start()
        sender:setText("Stop")
    end
end)

local followBox = ui.CheckBox("Follow")
followBox:setChecked(true)
followBox:setOnCheck(function(sender, checked)
    follow = checked
    if follow then out:scrollToEnd() end
end)

filterField:setOnTextChange(rebuild)

levelPicker:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    -- "All" and "DEBUG and above" are the same thing; the rest step up.
    minimumLevel = math.max(1, index - 1)
    rebuild()
end)

local burst = ui.Button("Write 200 lines at once")
burst:setOnClick(function()
    local batch = {}
    for i = 1, 200 do
        local level = System.randomChoice({ "DEBUG", "INFO", "WARN", "ERROR" })
        written = written + 1
        table.insert(batch, string.format("%05d [%s] %s", written, level, System.randomChoice(MESSAGES)))
    end
    FS.appendFile(LOGFILE, table.concat(batch, "\n") .. "\n")
    status:setText("Wrote a burst -- the next poll picks it all up.")
end)

local clear = ui.Button("Clear")
clear:setOnClick(function()
    FS.writeFile(LOGFILE, "")
    lines, consumed, written = {}, 0, 0
    for _, name in ipairs(ORDER) do counts[name] = 0 end
    out:setHtml("")
    showTally()
    status:setText("Cleared.")
end)

-- LAYOUT -------------------------------------------------------------------

local controls = ui.HLayout()
controls:addChild(running)
controls:addChild(burst)
controls:addChild(clear)
controls:addChild(ui.VLine())
controls:addChild(ui.Label("Filter:"))
controls:addChild(filterField, 1)
controls:addChild(ui.Label("Level:"))
controls:addChild(levelPicker)
controls:addChild(followBox)

local note = ui.Label(
    "Two timers: one writes the log, one tails it. Both run on the interface " ..
    "thread in short slices, which is why the window stays live -- a sys.Thread " ..
    "doing the same loop would hold the Lua state and deliver nothing until it " ..
    "finished. The file is " .. LOGFILE
)
note:setWordWrap(true)
note:setTextColor("#7a7a7a")

local root = ui.VLayout()
root:setMargins(10, 10, 10, 10)
root:setSpacing(8)
root:addLayout(controls)
root:addChild(out, 1)
root:addChild(note)

local body = ui.Container()
body:setLayout(root)

showTally()
producer:start()
tailer:start()

window:setOnClose(function()
    producer:stop()
    tailer:stop()
end)

window:setMainChild(body)
window:show()
