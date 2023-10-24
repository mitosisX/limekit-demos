-- theme = Theme("darklight")
-- theme:setTheme("light")
app.setStyle('Fusion')
-- Creating a window
window = Window{title="Hash Checker - Limekit", size={408, 270}}
window:setIcon(route('icon'))

window:setOnResize(function()
  window:setTitle('Width: '.. window:getSize()[0] .. ' Height: ' .. window:getSize()[1])
end)

-- Creating a main horizontal layout
mainLay = VLayout()

tab = Tab()

homeTab = TabItem()
homeVLay = VLayout()

hLay1 = HLayout()
check = Label("")
check:setImage(images('check.png'))

text1 = LineEdit()

selectButton = Button("Select file")
selectButton:setIcon(images("copy.png"))

hLay1:addChild(check)
hLay1:addChild(text1)
hLay1:addChild(selectButton)

homeVLay:addLayout(hLay1)
homeTab:setLayout(homeVLay)

aboutTab = TabItem()


tab:addTab(homeTab,'Home', images('home.png'))
tab:addTab(aboutTab,'About',images('info.png'))

mainLay:addChild(tab)

window:setLayout(mainLay)
window:show()
