window = Window("Calculator - Miranda")
window:setIcon(images("calc.png"))
window:setSize(280, 80)

theme = Theme("material")
theme:setTheme("light_blue")

mainLay = VLayout()

button = Button('Hello')
button:onClick(function()
    print('Hello')
end)
mainLay.addChild(button)

window:setLayout(mainLay)
window:show()