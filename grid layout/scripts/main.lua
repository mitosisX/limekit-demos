-- Saving widget states
function saveWidgetValues()
    -- Collect and save the widget values
    local details = {
        focus = today_tedit:getText(),
        notes = notes_tedit:getText()
    }
    local remaining_todo = {}

    -- Check the values of the QCheckBox widgets
    for row = 2, 8 do
        -- Retrieve the QLayoutItem object
        local item = main_grid:getChildAt(row, 1)
        -- Retrieve the widget (QCheckBox)

        if item:getCheck() then
            -- Retrieve the QLayoutItem object
            item = main_grid:getChildAt(row, 2)
            -- Retrieve the widget (QLineEdit)
            local text = item:getText()

            if text ~= "" then
                table.insert(remaining_todo, text)
            end
        end
    end

    -- Save text from QLineEdit widgets
    details.todo = list(remaining_todo)

    app.writeJSON("D:/lua/details.txt", dict(details))
end

function loadWidgetValuesFromFile()
    -- Check if the file exists first
    local details = app.readJSON("D:/lua/details.txt")

    -- -- Set values for the widgets
    today_tedit:setText(details.focus)
    notes_tedit:setText(details.notes)

    -- Set the text for QLineEdit widgets
    for row = 0, len(details.todo) - 1 do
        -- Retrieve the QLayoutItem object
        local widget = main_grid:getChildAt(row, 2)
        -- Retrieve the widget (QLineEdit)
        widget.setText(details["todo"][row])
    end
end

window = Window("Grid Layout - Limekit")
window:setIcon(route('app_icon'))
window:setSize(500, 300)
-- window:setOnClose(saveWidgetValues)

main_grid = GridLayout()

header_label = Label("Simple Daily Planner")
header_label:setFont('Arial', 20)
header_label:setTextAlign('left')

today_label = Label("· Today's Focus")
today_label:setFont('Arial', 14)
today_tedit = TextEdit()

notes_label = Label("· Notes")
notes_label:setFont('Arial', 14)
notes_tedit = TextEdit()

main_grid:addChild(header_label, 0, 0)
main_grid:addChild(today_label, 1, 0)
main_grid:addChild(today_tedit, 2, 0, 3, 1)
main_grid:addChild(notes_label, 5, 0)
main_grid:addChild(notes_tedit, 6, 0, 3, 1)

-- Right side widgets

date_label = Label('29-09-2023')
date_label:setFont('Arial', 18)
date_label:setTextAlign('right')

todo_label = Label('· To Do')
todo_label:setFont('Arial', 14)

main_grid:addChild(date_label, 0, 2)
main_grid:addChild(todo_label, 1, 1, 1, 2)

for row = 2, 8 do
    local item_cb = CheckBox()
    local item_edit = LineEdit()

    main_grid:addChild(item_cb, row, 1)
    main_grid:addChild(item_edit, row, 2)
end

-- loadWidgetValuesFromFile()

window:setLayout(main_grid)
window:show()