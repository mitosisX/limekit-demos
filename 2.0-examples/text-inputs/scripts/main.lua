-- Text input.
--
-- Two widgets, and the difference matters:
--
--   ui.LineEdit   one line. Has a real `text` property.
--   ui.TextField  many lines. Qt's setText on it guesses whether the string
--                 is HTML, so Limekit gives you setPlainText and setHtml
--                 explicitly rather than leaving that to chance.

local ui = require("limekit.ui")

local window = ui.Window { title = "Text Input - Limekit 2.0", size = { 560, 520 } }

local form = ui.FormLayout()
form:setMargins(16, 16, 16, 16)
form:setSpacing(10)

local report = ui.Label("Type in any field.")
report:setWordWrap(true)

-- A plain field.
local name = ui.LineEdit()
name:setHint("shown while the field is empty")
name:setOnTextChange(function(sender, text)
    report:setText("name is now " .. #text .. " characters")
end)
form:addChild("Name", name)

-- Return submits. Handy for search boxes and command lines.
local search = ui.LineEdit()
search:setHint("press Enter")
search:setOnReturnPress(function(sender)
    report:setText("searched for: " .. sender:getText())
    sender:clear()
end)
form:addChild("Search", search)

-- Echo modes: normal, password, hideinput, passwordonedit.
local password = ui.LineEdit()
password:setInputMode("password")
password:setMaxLength(32)
form:addChild("Password", password)

local pin = ui.LineEdit()
pin:setInputMode("passwordonedit")
pin:setHint("visible until you stop typing")
form:addChild("PIN", pin)

local readonly = ui.LineEdit("You cannot change this.")
readonly:setReadOnly(true)
form:addChild("Read only", readonly)

-- Selection. The handler fires whenever the selection changes, and the
-- getters read it back.
local selectable = ui.LineEdit("Select some of this text.")
selectable:setOnTextSelection(function(sender)
    if sender:checkTextSelected() then
        report:setText(
            "selected " .. sender:getSelectionLength() .. " chars: '"
            .. sender:getSelectedText() .. "' (from "
            .. sender:getStartSelection() .. ")"
        )
    end
end)
form:addChild("Selection", selectable)

-- Multi-line.
local notes = ui.TextField()
notes:setHint("Several lines. setPlainText never guesses HTML.")
notes:setWrapMode("widget")
notes:setOnTextChange(function(sender)
    report:setText("notes: " .. sender:getLineCount() .. " lines")
end)
form:addChild("Notes", notes)

-- The same widget can hold formatted text, but you have to say so.
local rich = ui.TextField()
rich:setHtml("<b>Bold</b>, <i>italic</i>, and <span style='color:#2d7d46'>colour</span>.")
rich:setMaxHeight(70)
form:addChild("Rich text", rich)

local buttons = ui.HLayout()

local select = ui.Button("Select all")
select:setOnClick(function() selectable:selectAll() end)

local undo = ui.Button("Undo")
undo:setOnClick(function() selectable:undo() end)

local redo = ui.Button("Redo")
redo:setOnClick(function() selectable:redo() end)

local append = ui.Button("Append a line")
append:setOnClick(function()
    notes:appendText("added at " .. notes:getLineCount())
    notes:scrollToEnd()
end)

buttons:addChild(select)
buttons:addChild(undo)
buttons:addChild(redo)
buttons:addChild(append)
buttons:addStretch(1)

form:addLayout("", buttons)
form:addChild("", ui.HLine())
form:addChild("", report)

window:setLayout(form)
window:show()
