-- Window events.
--
-- Everything a window can tell you about itself. These are Qt virtual method
-- overrides rather than signals, but they cross the same guard as every
-- other handler: an error in one is reported and the app keeps running.

local ui = require("limekit.ui")

local window = ui.Window { title = "Window Events - Limekit 2.0", size = { 560, 420 } }

local log = ui.TextField()
log:setReadOnly(true)

local counts = {}
local function record(name, detail)
    counts[name] = (counts[name] or 0) + 1
    log:setText(name .. " x" .. counts[name] .. (detail and ("  " .. detail) or "") .. "\n" .. log:getText())
end

local position = ui.Label("Move the pointer over the window.")
local size = ui.Label("")

window:setOnShown(function()
    record("onShown")
end)

window:setOnResize(function(sender, width, height)
    size:setText("Now " .. width .. " x " .. height)
    record("onResize", width .. "x" .. height)
end)

window:setOnMouseMove(function(sender, x, y)
    -- Fires constantly, so update a label rather than the log.
    position:setText("Pointer at " .. x .. ", " .. y)
end)

window:setOnMousePress(function(sender, x, y)
    record("onMousePress", x .. "," .. y)
end)

window:setOnMouseRelease(function(sender, x, y)
    record("onMouseRelease", x .. "," .. y)
end)

window:setOnMouseDoubleClick(function(sender, x, y)
    record("onMouseDoubleClick", x .. "," .. y)
end)

window:setOnContextMenu(function(sender, x, y)
    record("onContextMenu", x .. "," .. y)
end)

window:setOnClose(function()
    -- Runs as the window goes away. Save your state here.
    record("onClose")
end)

local layout = ui.VLayout()
layout:setSpacing(8)
layout:setMargins(16, 16, 16, 16)

local heading = ui.Label("Resize the window, move the pointer, click, right-click.")
heading:setWordWrap(true)

layout:addChild(heading)
layout:addChild(position)
layout:addChild(size)
layout:addChild(ui.HLine())
layout:addChild(log, 1)

window:setLayout(layout)
window:show()
