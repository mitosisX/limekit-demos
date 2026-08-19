-- Theming.
--
-- Two independent knobs, easy to confuse:
--
--   ui.Theme.setStyle(name)          the Qt *style* -- how widgets are drawn
--   ui.Theme.setTheme(family, name)  a palette or stylesheet on top of it
--
-- Neither one is guessed at. An unknown style or family raises and names the
-- valid options, where 1.x would carry on with the old look and say nothing.

local ui = require("limekit.ui")

local window = ui.Window { title = "Theming - Limekit 2.0", size = { 560, 460 } }

local form = ui.FormLayout()
form:setMargins(16, 16, 16, 16)
form:setSpacing(12)

local status = ui.Label("Pick a style or a theme.")
status:setWordWrap(true)

-- STYLES ------------------------------------------------------------------
-- getStyles() reports what this Qt build actually has, which differs between
-- platforms -- "windowsvista" exists on Windows and nowhere else.
local styles = ui.ComboBox(ui.Theme.getStyles())
styles:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    local name = sender:getItemAt(index)
    ui.Theme.setStyle(name)
    status:setText("Style: " .. name)
end)
form:addChild("Qt style", styles)

-- THEMES ------------------------------------------------------------------
-- Families that need an optional package raise when you pick them rather
-- than failing silently, so only offer the ones that answer.
local FAMILIES = { "darklight", "misc", "qtthemes", "material", "darkstyle" }

local families = ui.ComboBox()
local themes = ui.ComboBox()

local function loadThemes(family)
    local ok, names = pcall(function() return ui.Theme.getThemes(family) end)
    themes:clear()
    if not ok then
        status:setText(family .. " is not available: its optional package is not installed.")
        return
    end
    themes:setItems(names)
    status:setText(family .. " has " .. #names .. " themes.")
end

for _, family in ipairs(FAMILIES) do
    families:addItem(family)
end

families:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    loadThemes(sender:getItemAt(index))
end)

themes:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    local family = families:getText()
    local name = sender:getItemAt(index)
    local ok, err = pcall(function() ui.Theme.setTheme(family, name) end)
    status:setText(ok and ("Theme: " .. family .. " / " .. name) or tostring(err))
end)

form:addChild("Theme family", families)
form:addChild("Theme", themes)

-- STYLESHEETS -------------------------------------------------------------
-- Qt stylesheets are unchanged from 1.x, and they beat a theme for one-off
-- touches. `palette(...)` keeps a rule honest under whatever theme is on.
local accent = ui.Button("Styled button")
accent:setStyleSheet([[
    QPushButton {
        background: #2d7d46;
        color: white;
        border: none;
        border-radius: 4px;
        padding: 8px 18px;
    }
    QPushButton:hover { background: #35995a; }
]])
form:addChild("Stylesheet", accent)

-- STANDARD ICONS ----------------------------------------------------------
-- The platform's own icons, so you do not have to ship PNGs for the obvious
-- things. getStandardIcons() lists every name available here.
local icons = ui.HLayout()
for _, name in ipairs({ "SP_DialogSaveButton", "SP_DirIcon", "SP_TrashIcon", "SP_ComputerIcon" }) do
    local button = ui.Button("")
    button:setIcon(window:getStandardIcon(name))
    button:setToolTip(name)
    icons:addChild(button)
end
icons:addStretch(1)
form:addLayout("Standard icons", icons)

form:addChild("", ui.HLine())
form:addChild("", status)

-- Start somewhere reasonable.
loadThemes("darklight")

window:setLayout(form)
window:show()
