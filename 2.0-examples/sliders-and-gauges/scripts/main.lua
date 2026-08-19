-- Numbers in and numbers out.
--
-- Everything here is the same number seen five ways: drag any one of them and
-- the rest follow.

local ui = require("limekit.ui")

local window = ui.Window { title = "Sliders & Gauges - Limekit 2.0", size = { 620, 500 } }

local MIN, MAX = 0, 100

-- A guard so that updating the others from inside a handler does not bounce
-- straight back. Every widget below reports changes, including the ones you
-- make in code.
local updating = false

local slider = ui.Slider()
slider:setOrientation("horizontal")
slider:setRange(MIN, MAX)
slider:setTickPosition("below")

local knob = ui.Knob()
knob:setRange(MIN, MAX)
knob:setNotchesVisible(true)

local spinner = ui.Spinner()
spinner:setRange(MIN, MAX)
spinner:setSuffix(" %")

local decimal = ui.DoubleSpinner()
decimal:setRange(MIN, MAX)
decimal:setPrefix("~ ")

local progress = ui.ProgressBar()
progress:setRange(MIN, MAX)

local lcd = ui.LCDNumber()
lcd:setDigitCount(3)
lcd:setSegmentStyle("flat")

-- AdvancedSlider is the styled one: it draws its own value, takes a prefix
-- and suffix, and can work in decimals.
local advanced = ui.AdvancedSlider()
advanced:setRange(MIN, MAX)
advanced:showValue(true)
advanced:setSuffix(" units")
advanced:setAccentColor("#2d7d46")
advanced:setBorderRadius(4)

local readout = ui.Label("")

local function apply(value)
    if updating then return end
    updating = true

    slider:setValue(value)
    knob:setValue(value)
    spinner:setValue(value)
    decimal:setValue(value)
    progress:setValue(value)
    lcd:setValue(value)
    advanced:setValue(value)
    readout:setText("Value: " .. value .. " of " .. MAX)

    updating = false
end

-- Each widget names its change event slightly differently -- setOnValueChange
-- on the plain ones, setOnValueChanged on Knob and AdvancedSlider.
slider:setOnValueChange(function(sender, value) apply(value) end)
spinner:setOnValueChange(function(sender, value) apply(value) end)
decimal:setOnValueChange(function(sender, value) apply(math.floor(value)) end)
knob:setOnValueChanged(function(sender, value) apply(value) end)
advanced:setOnValueChanged(function(sender, value) apply(math.floor(value)) end)

-- A vertical slider, to show the orientation is a property rather than a
-- different class.
local vertical = ui.Slider()
vertical:setOrientation("vertical")
vertical:setRange(MIN, MAX)
vertical:setOnValueChange(function(sender, value) apply(value) end)

local form = ui.FormLayout()
form:addChild("Slider", slider)
form:addChild("Advanced slider", advanced)
form:addChild("Spinner", spinner)
form:addChild("Decimal spinner", decimal)
form:addChild("Progress", progress)

local dials = ui.HLayout()
dials:addChild(knob)
dials:addChild(lcd)
dials:addChild(vertical)

local buttons = ui.HLayout()
for _, value in ipairs({ 0, 25, 50, 75, 100 }) do
    local button = ui.Button(tostring(value))
    button:setOnClick(function() apply(value) end)
    buttons:addChild(button)
end
buttons:addStretch(1)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(12)
layout:addLayout(form)
layout:addLayout(dials)
layout:addLayout(buttons)
layout:addChild(ui.HLine())
layout:addChild(readout)

apply(42)

window:setLayout(layout)
window:show()
