window = Window("Calculator - Miranda")
window:setIcon(route('app_icon'))
window:setSize(280, 150)

-- theme = Theme("material")
-- theme:setTheme("light_blue")

mainLay = VLayout()

button = Button('Hello')
button:onClick(function()
    print('Hello')
end)

cal = Calendar();
cal.setOnDateChaged(function(obj, date)
    print(date)
end)
-- cal:setDate("12/13/1996");

mainLay:addChild(cal)

-- window:setMainWidget(button)

-- window:setLayout(mainLay)
window:show()