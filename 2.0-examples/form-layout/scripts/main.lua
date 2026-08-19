-- FormLayout -- label on the left, field on the right.
--
-- You could build this out of a GridLayout, but FormLayout already knows the
-- platform's conventions for label alignment and row spacing, so a form built
-- with it looks native without any tuning.

local ui = require("limekit.ui")

local window = ui.Window { title = "Form Layout - Limekit 2.0", size = { 460, 460 } }

local form = ui.FormLayout()
form:setSpacing(10)
form:setMargins(20, 20, 20, 20)

local heading = ui.Label("Appointment request")
heading:setFont("Arial", 16)
heading:setTextAlignment("center")

-- An empty title gives a row that spans the whole width -- useful for
-- headings and separators.
form:addChild("", heading)
form:addChild("", ui.HLine())

-- Two fields sharing one row: build a nested layout and add that instead of
-- a widget.
local firstName = ui.LineEdit()
firstName:setHint("First")

local lastName = ui.LineEdit()
lastName:setHint("Last")

local nameRow = ui.HLayout()
nameRow:addChild(firstName)
nameRow:addChild(lastName)
form:addLayout("Name", nameRow)

local gender = ui.ComboBox({ "Prefer not to say", "Female", "Male" })
form:addChild("Gender", gender)

local email = ui.LineEdit()
email:setHint("you@example.com")
form:addChild("Email", email)

local phone = ui.LineEdit()
phone:setHint("+265 000 000 000")
phone:setMaxLength(20)
form:addChild("Phone", phone)

local preferred = ui.DatePicker()
form:addChild("Preferred date", preferred)

local notes = ui.TextField()
notes:setHint("Anything we should know beforehand?")
notes:setMaxHeight(90)
form:addChild("Notes", notes)

local feedback = ui.Label("Fill in a name to continue.")
feedback:setWordWrap(true)

local submit = ui.Button("Submit")
submit:setOnClick(function()
    local first = firstName:getText()
    local last = lastName:getText()

    if first == "" or last == "" then
        feedback:setText("Both name fields are required.")
        return
    end

    local date = preferred:getDate()
    feedback:setText(
        "Booked for " .. first .. " " .. last .. " on " .. tostring(date) .. "."
    )
end)

local buttonRow = ui.HLayout()
buttonRow:addChild(feedback, 1)
buttonRow:addChild(submit)

form:addChild("", ui.HLine())
form:addLayout("", buttonRow)

window:setLayout(form)
window:show()
