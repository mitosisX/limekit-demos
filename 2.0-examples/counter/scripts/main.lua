-- Counter -- events, state, and the error guard.
--
-- Every handler you attach through a generated setOn* crosses one guarded
-- seam. In 1.x only Button did that; ComboBox, ListBox, Label and Window all
-- let an error escape into the Qt event loop and take the app with it. The
-- "Break on purpose" button below proves the difference: it raises, gets
-- reported, and the window keeps running.

local ui = require("limekit.ui")

local window = ui.Window { title = "Counter - Limekit 2.0", size = { 380, 260 } }

local count = 0

local display = ui.Label("0")
display:setTextAlignment("center")
display:setStyleSheet("font-size: 40px; font-weight: bold;")

local status = ui.Label("Press a button")
status:setTextAlignment("center")

local function render()
    display:setText(count)          -- coerce=str on the spec; no tostring() needed
    if count == 0 then
        status:setText("Back to zero")
    elseif count > 0 then
        status:setText("Counted up " .. count .. "x")
    else
        status:setText("Below zero")
    end
end

local minus = ui.Button("-")
minus:setOnClick(function()
    count = count - 1
    render()
end)

local plus = ui.Button("+")
plus:setOnClick(function()
    count = count + 1
    render()
end)

local reset = ui.Button("Reset")
reset:setOnClick(function()
    count = 0
    render()
end)

-- This handler raises every time. The guard catches it, reports it with the
-- widget and event name attached, and the app survives.
local boom = ui.Button("Break on purpose")
boom:setOnClick(function()
    error("this handler always fails - the app should not die")
end)

local buttons = ui.HLayout()
buttons:addChild(minus)
buttons:addChild(plus)
buttons:addChild(reset)

local layout = ui.VLayout()
layout:setSpacing(10)
layout:setMargins(20, 20, 20, 20)
layout:addChild(display)
layout:addChild(status)
layout:addLayout(buttons)
layout:addStretch(1)
layout:addChild(boom)

window:setLayout(layout)
window:show()
