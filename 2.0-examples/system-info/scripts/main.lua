-- sys.System -- the odds and ends.
--
-- In 1.x roughly forty of these hung off the `app` table, including a graph
-- algorithm and a battery monitor. What survived into 2.0 is what a GUI app
-- actually reaches for.

local ui = require("limekit.ui")
local sys = require("limekit.sys")

local window = ui.Window { title = "System - Limekit 2.0", size = { 640, 560 } }

local tabs = ui.Tab()

-- ABOUT THIS MACHINE -------------------------------------------------------

local about = ui.TabItem()
local aboutForm = ui.FormLayout()
aboutForm:setMargins(16, 16, 16, 16)

local FACTS = {
    { "Operating system", sys.System.getOSName },
    { "OS version",       sys.System.getOSVersion },
    { "Platform",         sys.System.getPlatformName },
    { "Processor",        sys.System.getProcessorName },
    { "CPU cores",        sys.System.getCPUCount },
}

for _, fact in ipairs(FACTS) do
    local value = ui.Label(tostring(fact[2]()))
    value:setWordWrap(true)
    aboutForm:addChild(fact[1], value)
end

-- Well-known folders, by name rather than by guessing at a path.
local paths = ui.ComboBox({ "desktop", "documents", "downloads", "home", "temp", "pictures", "music" })
local resolved = ui.Label("")
resolved:setWordWrap(true)

paths:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    local name = sender:getItemAt(index)
    local ok, path = pcall(function() return sys.System.getStandardPath(name) end)
    resolved:setText(ok and path or tostring(path))
end)

aboutForm:addChild("Standard path", paths)
aboutForm:addChild("", resolved)

about:setLayout(aboutForm)
tabs:addTab(about, "This machine")

-- HASHING ------------------------------------------------------------------

local hashing = ui.TabItem()
local hashLayout = ui.VLayout()
hashLayout:setMargins(16, 16, 16, 16)
hashLayout:setSpacing(10)

local subject = ui.TextField("The quick brown fox jumps over the lazy dog")
subject:setMaxHeight(90)

local kinds = { "md5", "sha1", "sha224", "sha256", "sha384", "sha512" }
local results = ui.Table(#kinds, 2)
results:setColumnHeaders({ "Algorithm", "Digest" })
results:setColumnWidth(2, 420)

local function rehash()
    local text = subject:getText()
    for row, kind in ipairs(kinds) do
        results:setCellText(row, 1, kind)
        results:setCellText(row, 2, sys.System.makeHash(kind, text))
    end
end

subject:setOnTextChange(rehash)

local copyHash = ui.Button("Copy the SHA-256 to the clipboard")
copyHash:setOnClick(function()
    sys.System.setClipboardText(sys.System.makeHash("sha256", subject:getText()))
end)

local pasteBack = ui.Button("Read the clipboard back")
local clipboard = ui.Label("")
clipboard:setWordWrap(true)
pasteBack:setOnClick(function()
    clipboard:setText(sys.System.getClipboardText())
end)

hashLayout:addChild(ui.Label("Type below; the digests update as you go."))
hashLayout:addChild(subject)
hashLayout:addChild(results, 1)
hashLayout:addChild(copyHash)
hashLayout:addChild(pasteBack)
hashLayout:addChild(clipboard)

hashing:setLayout(hashLayout)
tabs:addTab(hashing, "Hashes")

-- ODDS AND ENDS ------------------------------------------------------------

local misc = ui.TabItem()
local miscLayout = ui.FormLayout()
miscLayout:setMargins(16, 16, 16, 16)

local plain = ui.LineEdit("Limekit 2.0")
local encoded = ui.LineEdit()
encoded:setReadOnly(true)
local decoded = ui.LineEdit()
decoded:setReadOnly(true)

local function reencode()
    local base64 = sys.System.toBase64(plain:getText())
    encoded:setText(base64)
    decoded:setText(sys.System.fromBase64(base64))
end

plain:setOnTextChange(reencode)

miscLayout:addChild("Text", plain)
miscLayout:addChild("Base64", encoded)
miscLayout:addChild("Back again", decoded)

local sizes = ui.Label("")
local sizeSlider = ui.Slider()
sizeSlider:setOrientation("horizontal")
sizeSlider:setRange(0, 40)
sizeSlider:setOnValueChange(function(sender, value)
    -- 2^value bytes, printed the way a file manager would.
    sizes:setText(sys.System.bytesToReadableSize(2 ^ value))
end)
sizeSlider:setValue(20)

miscLayout:addChild("Bytes (2^n)", sizeSlider)
miscLayout:addChild("Readable", sizes)

local splitInput = ui.LineEdit("one,two,three,four")
local splitOutput = ui.Label("")
splitOutput:setWordWrap(true)
local function resplit()
    local parts = sys.System.splitString(splitInput:getText(), ",")
    splitOutput:setText(#parts .. " parts: " .. table.concat(parts, " | "))
end

splitInput:setOnTextChange(resplit)

miscLayout:addChild("Split on ','", splitInput)
miscLayout:addChild("Parts", splitOutput)

local emoji = ui.Label("")
local emojiButton = ui.Button("Random emoji")
emojiButton:setOnClick(function()
    local name = sys.System.randomChoice({ ":thumbs_up:", ":rocket:", ":sparkles:", ":fire:" })
    emoji:setText(name .. "  ->  " .. sys.System.emoji(name))
end)

miscLayout:addChild("Emoji", emojiButton)
miscLayout:addChild("", emoji)

-- execute() runs an external command and returns its output, bounded at
-- thirty seconds so a hung command cannot freeze the app forever.
local commandOutput = ui.TextField()
commandOutput:setReadOnly(true)
commandOutput:setMaxHeight(100)

local runCommand = ui.Button("Run a command")
runCommand:setOnClick(function()
    local ok, output = pcall(function()
        return sys.System.execute(sys.System.getOSName() == "Windows" and "ver" or "uname -a")
    end)
    commandOutput:setText(tostring(output))
end)

miscLayout:addChild("Shell", runCommand)
miscLayout:addChild("", commandOutput)

misc:setLayout(miscLayout)
tabs:addTab(misc, "Odds and ends")

-- Handlers only run on *change*, and setting a field to the value it already
-- holds is not a change -- Qt does not re-emit. So the startup pass calls the
-- same functions directly rather than trying to poke the widgets into firing.
rehash()
reencode()
resplit()

local layout = ui.VLayout()
layout:addChild(tabs)

window:setLayout(layout)
window:show()
