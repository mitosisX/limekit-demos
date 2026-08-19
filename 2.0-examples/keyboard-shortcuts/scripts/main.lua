-- Keyboard shortcuts.
--
-- Two different things, often confused:
--
--   ui.KeyboardShortcut  a sequence that works anywhere in a window
--   Container:setOnKeyPress  every key that reaches one widget

local ui = require("limekit.ui")

local window = ui.Window { title = "Shortcuts - Limekit 2.0", size = { 520, 400 } }

local log = ui.TextField()
log:setReadOnly(true)
log:setText("Try Ctrl+S, Ctrl+Q, F1, or type in the box below.")

local function say(message)
    log:appendText(message)
end

-- A shortcut is bound to a parent widget -- usually the window, so it works
-- wherever the focus happens to be.
local SHORTCUTS = {
    { "Ctrl+S", "Save" },
    { "Ctrl+O", "Open" },
    { "Ctrl+F", "Find" },
    { "F1",     "Help" },
}

-- Hold on to each one. A KeyboardShortcut that nothing references can be
-- collected, and then it silently stops firing.
local shortcuts = {}

for _, spec in ipairs(SHORTCUTS) do
    local sequence, label = spec[1], spec[2]
    local shortcut = ui.KeyboardShortcut(window, sequence)
    shortcut:setOnKeyPress(function()
        say(label .. "  (" .. sequence .. ")")
    end)
    table.insert(shortcuts, shortcut)
end

-- A Container is a plain widget that owns a layout, and it can report raw
-- key presses -- useful for games and editors, where you want the key rather
-- than a named command.
local keypad = ui.Container()
local keypadLayout = ui.VLayout()

local prompt = ui.Label("Click here, then press any key.")
prompt:setTextAlignment("center")
prompt:setMinHeight(60)
prompt:setStyleSheet("border: 1px dashed palette(mid);")

keypadLayout:addChild(prompt)
keypad:setLayout(keypadLayout)

-- The handler receives the key's name ("A", "Return", "F1") and the
-- character it typed, if any -- not a raw Qt event object, which Lua could
-- not have read anyway.
keypad:setOnKeyPress(function(sender, key, text)
    prompt:setText("Key: " .. key .. (text ~= "" and ("   typed " .. text) or ""))
    say("keypress " .. key)
end)

local rebind = ui.Button("Rebind F1 to F2")
rebind:setOnClick(function(sender)
    -- setSequence changes an existing shortcut in place.
    shortcuts[4]:setSequence("F2")
    sender:setEnabled(false)
    say("F1 is now F2.")
end)

local layout = ui.VLayout()
layout:setSpacing(10)
layout:setMargins(16, 16, 16, 16)
layout:addChild(log, 1)
layout:addChild(keypad)
layout:addChild(rebind)

window:setLayout(layout)
window:show()
