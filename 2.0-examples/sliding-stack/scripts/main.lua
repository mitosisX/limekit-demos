-- SlidingStackedWidget -- a stack of pages that animates between them.
--
-- Same idea as a Tab without the tab strip: you drive which page is showing.
-- Useful for wizards, onboarding, and anything with a Next button.

local ui = require("limekit.ui")

local window = ui.Window { title = "Sliding Stack - Limekit 2.0", size = { 520, 380 } }

local stack = ui.SlidingStackedWidget()
stack:setSpeed(400)
stack:setOrientation("horizontal")

local PAGES = {
    { "Welcome", "This is a stack of pages. Only one is visible at a time." },
    { "How it works", "slideNext() and slidePrev() move between pages and animate the change." },
    { "Animations", "setAnimation picks the easing curve. An unknown name raises rather than doing nothing quietly, which is what 1.x did." },
    { "Done", "That is the whole widget." },
}

for _, page in ipairs(PAGES) do
    local card = ui.Container()

    local layout = ui.VLayout()
    layout:setMargins(28, 28, 28, 28)
    layout:setSpacing(12)

    local heading = ui.Label(page[1])
    heading:setTextSize(20)
    heading:setBold(true)

    local body = ui.Label(page[2])
    body:setWordWrap(true)

    layout:addChild(heading)
    layout:addChild(body)
    layout:addStretch(1)

    card:setLayout(layout)
    stack:addChild(card)
end

-- getAnimations() returns the names this widget accepts, so the ComboBox can
-- never fall out of step with what the widget supports.
local animation = ui.ComboBox(stack:getAnimations())

-- A ComboBox handler receives the 1-based *position*, not the text -- unlike
-- ListBox, which hands you both. getItemAt turns one into the other.
animation:setOnItemSelect(function(sender, index)
    if index == 0 then return end          -- 0 means nothing is selected
    stack:setAnimation(sender:getItemAt(index))
end)

local position = ui.Label("")
local function refresh()
    position:setText("Page " .. stack:getCurrentIndex() .. " of " .. stack:getCount())
end

local previous = ui.Button("< Back")
previous:setOnClick(function()
    stack:slidePrev()
    refresh()
end)

local nextPage = ui.Button("Next >")
nextPage:setOnClick(function()
    stack:slideNext()
    refresh()
end)

local controls = ui.HLayout()
controls:addChild(ui.Label("Animation:"))
controls:addChild(animation)
controls:addStretch(1)
controls:addChild(position)
controls:addStretch(1)
controls:addChild(previous)
controls:addChild(nextPage)

local root = ui.VLayout()
root:setMargins(12, 12, 12, 12)
root:addChild(stack, 1)
root:addChild(ui.HLine())
root:addLayout(controls)

stack:setCurrentIndex(1)
refresh()

window:setLayout(root)
window:show()
