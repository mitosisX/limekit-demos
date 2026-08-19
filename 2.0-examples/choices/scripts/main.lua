-- Ways of choosing.
--
--   CheckBox     independent on/off
--   RadioButton  one of several, when you want them all visible
--   ButtonGroup  makes a set of buttons exclusive, and reports as one
--   ComboBox     one of several, when the list is long

local ui = require("limekit.ui")

local window = ui.Window { title = "Choices - Limekit 2.0", size = { 600, 480 } }

local report = ui.TextField()
report:setReadOnly(true)

local function say(message)
    report:appendText(message)
end

-- CHECK BOXES -------------------------------------------------------------
local toppings = ui.GroupBox("Toppings (any number)")
local toppingsLayout = ui.VLayout()

local chosen = {}
for _, name in ipairs({ "Cheese", "Bacon", "Mushrooms", "Olives" }) do
    local box = ui.CheckBox(name)
    box:setOnCheck(function(sender, checked)
        chosen[name] = checked or nil
        local list = {}
        for topping in pairs(chosen) do table.insert(list, topping) end
        table.sort(list)
        say("Toppings: " .. (#list > 0 and table.concat(list, ", ") or "none"))
    end)
    toppingsLayout:addChild(box)
end

toppings:setLayout(toppingsLayout)

-- RADIO BUTTONS -----------------------------------------------------------
-- Radios inside the same parent are exclusive automatically. A ButtonGroup
-- makes that explicit, and gives you one handler instead of N.
local size = ui.GroupBox("Size (exactly one)")
local sizeLayout = ui.VLayout()

local sizeGroup = ui.ButtonGroup()
sizeGroup:setExclusive(true)

for index, name in ipairs({ "Small", "Medium", "Large" }) do
    local radio = ui.RadioButton(name)
    if index == 2 then radio:setChecked(true) end
    sizeGroup:addButton(radio)
    sizeLayout:addChild(radio)
end

sizeGroup:setOnClick(function(sender, button)
    say("Size: " .. button:getText())
end)

size:setLayout(sizeLayout)

-- A GroupBox can itself be checkable, which switches its contents on and off.
local delivery = ui.GroupBox("Delivery")
delivery:setCheckable(true)
delivery:setChecked(false)

local deliveryLayout = ui.FormLayout()
deliveryLayout:addChild("Address", ui.LineEdit())
deliveryLayout:addChild("Notes", ui.LineEdit())
delivery:setLayout(deliveryLayout)

-- COMBO BOXES -------------------------------------------------------------
local drink = ui.ComboBox({ "Water", "Coffee", "Tea", "Juice" })

-- The handler receives the 1-based position, not the text. 0 means nothing
-- is selected, which happens after clear().
drink:setOnItemSelect(function(sender, index)
    if index == 0 then
        say("Drink: nothing selected")
        return
    end
    say("Drink: " .. sender:getItemAt(index))
end)

-- The font picker is a ComboBox that fills itself from the installed fonts.
local font = ui.FontComboBox()
font:setOnItemSelect(function(sender, text, index)
    -- FontComboBox hands you both the name and the position.
    say("Font: " .. text .. " (" .. index .. ")")
end)

local clear = ui.Button("Clear the drink list")
clear:setOnClick(function()
    drink:clear()
end)

local refill = ui.Button("Refill it")
refill:setOnClick(function()
    drink:setItems({ "Water", "Coffee", "Tea", "Juice" })
end)

-- LAYOUT ------------------------------------------------------------------
local columns = ui.HLayout()
columns:addChild(toppings)
columns:addChild(size)

local form = ui.FormLayout()
form:addChild("Drink", drink)
form:addChild("Font", font)

local buttons = ui.HLayout()
buttons:addChild(clear)
buttons:addChild(refill)
buttons:addStretch(1)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(12)
layout:addLayout(columns)
layout:addChild(delivery)
layout:addLayout(form)
layout:addLayout(buttons)
layout:addChild(ui.HLine())
layout:addChild(report, 1)

window:setLayout(layout)
window:show()
