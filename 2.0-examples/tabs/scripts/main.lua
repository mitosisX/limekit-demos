-- Tabs.
--
-- ui.Tab is the strip plus the page area. Each page is a widget; TabItem is
-- a blank one that owns a layout, which is what you usually want.

local ui = require("limekit.ui")

local window = ui.Window { title = "Tabs - Limekit 2.0", size = { 560, 400 } }

local tabs = ui.Tab()
tabs:setMovable(true)
tabs:setTabsClosable(true)

local function makePage(title, body)
    local page = ui.TabItem()

    local layout = ui.VLayout()
    layout:setSpacing(10)
    layout:setMargins(16, 16, 16, 16)

    local heading = ui.Label(title)
    heading:setBold(true)
    heading:setTextSize(15)

    local text = ui.Label(body)
    text:setWordWrap(true)

    layout:addChild(heading)
    layout:addChild(text)
    layout:addStretch(1)

    page:setLayout(layout)
    return page
end

tabs:addTab(makePage("Overview", "Tab pages are ordinary widgets. Anything you can put in a window goes here too."), "Overview")
tabs:addTab(makePage("Details", "setMovable(true) lets the user drag tabs into a different order."), "Details")
tabs:addTab(makePage("Settings", "setTabsClosable(true) puts a close button on each tab -- but Qt only draws it. Removing the page is your job, in setOnTabClose."), "Settings")

local status = ui.Label("")

tabs:setOnTabChange(function(sender, index)
    -- Indexes are 1-based, so this is the tab the user can see.
    status:setText("Now on tab " .. index .. ": " .. sender:getTabText(index))
end)

tabs:setOnTabClose(function(sender, index)
    -- Qt draws the button; closing is a decision, so you make it.
    if sender:getCount() <= 1 then
        status:setText("Keeping the last tab.")
        return
    end
    status:setText("Closed " .. sender:getTabText(index))
    sender:removeTab(index)
end)

local layout = ui.VLayout()
layout:addChild(tabs, 1)
layout:addChild(status)

window:setLayout(layout)
window:show()
