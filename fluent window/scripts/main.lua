window = SplitWindow()
window:setTheme('dark')

mainLay = VLayout()
horizontalGroupBox = GroupBox("Horizontal layout")
horiLayout = HLayout()

for i = 0, 3 do
    button = Button("Button "..i + 1)
    horiLayout:addChild(button)
end

horizontalGroupBox:setLayout(horiLayout)
mainLay:addChild(horizontalGroupBox)

-- window:addMenu(mainLay)
-- window:setIcon(route('app_icon'))
-- window:setSize(280, 170)

-- window:s()

-- window:setLayout(mainLay)
window.show()