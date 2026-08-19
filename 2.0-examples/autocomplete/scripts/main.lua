-- Autocomplete.
--
-- ui.AutoComplete holds the word list; a LineEdit borrows it. One list can be
-- shared by several fields, which is the reason it is a separate object
-- rather than a method on the field.

local ui = require("limekit.ui")

local window = ui.Window { title = "Autocomplete - Limekit 2.0", size = { 480, 300 } }

local COUNTRIES = {
    "Malawi", "Mali", "Mauritius", "Morocco", "Mozambique",
    "Namibia", "Nigeria", "Rwanda", "Senegal", "South Africa",
    "Tanzania", "Uganda", "Zambia", "Zimbabwe",
}

local completer = ui.AutoComplete(COUNTRIES)
-- Off by default, which is almost always what you want: typing "mal" should
-- still find "Malawi".
completer:setCaseSensitive(false)

local country = ui.LineEdit()
country:setHint("Start typing a country -- try 'ma'")
country:setAutoComplete(completer)

-- The same completer, attached to a second field.
local birthplace = ui.LineEdit()
birthplace:setHint("Same suggestions, different field")
birthplace:setAutoComplete(completer)

local chosen = ui.Label("")
country:setOnReturnPress(function(sender)
    chosen:setText("You picked: " .. sender:getText())
end)

-- A ComboBox can do the same job when the list is short and closed: make it
-- editable and it accepts typed input as well as a pick from the list.
local editable = ui.ComboBox(COUNTRIES)
editable:setEditable(true)

local form = ui.FormLayout()
form:setMargins(16, 16, 16, 16)
form:setSpacing(12)
form:addChild("Country", country)
form:addChild("Birthplace", birthplace)
form:addChild("Editable combo", editable)
form:addChild("", ui.HLine())
form:addChild("", chosen)

window:setLayout(form)
window:show()
