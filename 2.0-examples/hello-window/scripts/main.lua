-- Hello Window -- the smallest complete Limekit 2.0 app.
--
-- Note what is NOT here: no globals. 1.x injected ~138 bare names into Lua,
-- plus Python's own eval, str, int and print. 2.0 gives you modules you
-- require, so nothing lands in your namespace that you did not ask for.

local ui = require("limekit.ui")

local window = ui.Window { title = "Hello - Limekit 2.0", size = { 380, 220 } }

local layout = ui.VLayout()
layout:setSpacing(12)
layout:setMargins(24, 24, 24, 24)

local heading = ui.Label("Limekit 2.0")
heading:setTextAlignment("center")
heading:setStyleSheet("font-size: 22px; font-weight: bold;")

local caption = ui.Label("Declarative widgets, generated accessors.")
caption:setTextAlignment("center")
caption:setWordWrap(true)

-- Every generated setter returns the widget, so calls chain.
local button = ui.Button("Say hello")
    :setToolTip("Updates the caption above")

button:setOnClick(function(self)
    caption:setText("Hello from the " .. self:getText() .. " button!")
end)

layout:addChild(heading)
layout:addChild(caption)
layout:addStretch(1)
layout:addChild(button)

window:setLayout(layout)
window:show()
