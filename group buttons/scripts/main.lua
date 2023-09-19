window = Window("Group Buttons - Limekit")
window:setIcon(route('app_icon'))
window:setSize(350, 200)

theme = Theme("material")
theme:setTheme("light_blue")

mainLay = VLayout()

headerLabel = Label("Limekit UI")
headerLabel.setTextAlign('center')

questionLabel = Label("How would you rate Limekit?")
questionLabel.setTextAlign('center')

mainLay:addChild(headerLabel, questionLabel)

ratings = {"Brilliant", "Average", "Not Satisfied"}

ratingGroup = ButtonGroup()
ratingGroup:setOnClick(function(obj, button)
    print(button:getText())
end)

confirm = Button("Confirm")

for key,value in ipairs(ratings) do
    check = CheckBox(value)
    ratingGroup:addChild(check)
    mainLay:addChild(check)
end

mainLay:addChild(confirm)

window:setLayout(mainLay)
window:show()