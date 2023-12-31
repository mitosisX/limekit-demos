window = Window("Group Buttons - Limekit")
window:setIcon(route('app_icon'))
window:setSize(350, 200)

-- theme = Theme("material")
-- theme:setTheme("light_blue")

mainLay = VLayout()

headerLabel = Label("Limekit UI")
headerLabel.setTextAlign('center')

questionLabel = Label("How would you rate Limekit?")
questionLabel.setTextAlign('center')

mainLay:addChild(headerLabel)
mainLay:addChild(questionLabel)

ratings = {"Brilliant", "Average", "Not Satisfied"}

ratingGroup = ButtonGroup()
-- ratingGroup:setOnClick(function(obj, button)
--     print(button:getText())
-- end)

for key,value in ipairs(ratings) do
    check = CheckBox(value)
    check:setOnCheck(function(sender, state)
        print(state)
    end)
    ratingGroup:addButton(check)
    mainLay:addChild(check)
end

confirm = Button("Confirm")
mainLay:addChild(confirm)

window:setLayout(mainLay)
window:show()