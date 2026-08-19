-- Accordion -- collapsible sections.
--
-- Like a Tab where the pages stack vertically and expand in place. Good for
-- settings panels, where each section is short and the user only cares about
-- one at a time.

local ui = require("limekit.ui")

local window = ui.Window { title = "Accordion - Limekit 2.0", size = { 420, 460 } }

local accordion = ui.Accordion()

-- addChild takes a single widget and the section label.
local intro = ui.Label("Each section opens and closes on its own. Only the label stays visible when a section is shut.")
intro:setWordWrap(true)
accordion:addChild(intro, "About")

-- addLayout takes a whole layout, which is what you want for anything with
-- more than one control in it.
local appearance = ui.VLayout()
appearance:setSpacing(8)
appearance:addChild(ui.CheckBox("Dark background"))
appearance:addChild(ui.CheckBox("Large text"))
appearance:addChild(ui.CheckBox("Show line numbers"))
accordion:addLayout(appearance, "Appearance")

local account = ui.FormLayout()
local user = ui.LineEdit()
user:setHint("username")
local secret = ui.LineEdit()
secret:setHint("password")
-- One of: normal, password, hideinput, passwordonedit.
secret:setInputMode("password")
account:addChild("User", user)
account:addChild("Password", secret)
accordion:addLayout(account, "Account")

local danger = ui.VLayout()
local warning = ui.Label("These cannot be undone.")
warning:setWordWrap(true)
danger:addChild(warning)
danger:addChild(ui.Button("Reset settings"))
danger:addChild(ui.Button("Delete everything"))
accordion:addLayout(danger, "Danger zone")

local status = ui.Label("Section 1 of " .. accordion:getCount())

accordion:setOnCurrentChange(function(sender, index)
    status:setText("Section " .. index .. " of " .. sender:getCount())
end)

-- 1-based, so this opens the first section.
accordion:setCurrentIndex(1)

local layout = ui.VLayout()
layout:setMargins(12, 12, 12, 12)
layout:addChild(accordion, 1)
layout:addChild(status)

window:setLayout(layout)
window:show()
